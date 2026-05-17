import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../jobs/data/models/job_post.dart';
import '../../../jobs/presentation/controllers/jobs_controller.dart';
import '../../data/models/location_ping.dart';
import '../controllers/tracking_controller.dart';

/// Canlı taşıma takip ekranı.
///
/// İçerik:
/// - Tam ekran Google Maps
/// - Kırmızı pin = origin
/// - Mavi pin = destination
/// - Turuncu kamyon = nakliyeci canlı konumu (son ping)
/// - Polyline = ping'lerin geçtiği rota (eskiden yeniye)
/// - Alt sayfada özet kart (mesafe, hız, son güncelleme)
class JobTrackingScreen extends ConsumerStatefulWidget {
  const JobTrackingScreen({required this.jobId, super.key});
  final String jobId;

  @override
  ConsumerState<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends ConsumerState<JobTrackingScreen> {
  final Completer<GoogleMapController> _mapCompleter = Completer();
  bool _didInitialFit = false;

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));
    final pingsAsync = ref.watch(jobLocationPingsProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Takip')),
      body: jobAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorView(message: e.toString()),
        data: (job) {
          if (job == null) {
            return const AppEmptyState(
              icon: Icons.search_off,
              title: 'İlan bulunamadı',
            );
          }
          return pingsAsync.when(
            loading: () => _MapView(job: job, pings: const []),
            error: (e, _) => _MapView(job: job, pings: const []),
            data: (pings) => _MapView(
              job: job,
              pings: pings,
              onMapReady: _onMapReady,
              didInitialFit: _didInitialFit,
              onInitialFitted: () => _didInitialFit = true,
            ),
          );
        },
      ),
    );
  }

  void _onMapReady(GoogleMapController c) {
    if (!_mapCompleter.isCompleted) _mapCompleter.complete(c);
  }
}

class _MapView extends StatefulWidget {
  const _MapView({
    required this.job,
    required this.pings,
    this.onMapReady,
    this.didInitialFit = false,
    this.onInitialFitted,
  });

  final JobPost job;
  final List<LocationPing> pings;
  final ValueChanged<GoogleMapController>? onMapReady;
  final bool didInitialFit;
  final VoidCallback? onInitialFitted;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  GoogleMapController? _controller;

  LatLng? get _originPos =>
      widget.job.originLat != null && widget.job.originLng != null
          ? LatLng(widget.job.originLat!, widget.job.originLng!)
          : null;

  LatLng? get _destPos =>
      widget.job.destinationLat != null && widget.job.destinationLng != null
          ? LatLng(widget.job.destinationLat!, widget.job.destinationLng!)
          : null;

  LatLng? get _carrierPos => widget.pings.isEmpty
      ? null
      : LatLng(widget.pings.last.lat, widget.pings.last.lng);

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_originPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: _originPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Çıkış',
            snippet: '${widget.job.originCity}, ${widget.job.originDistrict}',
          ),
        ),
      );
    }
    if (_destPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destPos!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: 'Varış',
            snippet:
                '${widget.job.destinationCity}, ${widget.job.destinationDistrict}',
          ),
        ),
      );
    }
    if (_carrierPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('carrier'),
          position: _carrierPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(title: 'Nakliyeci'),
          rotation: widget.pings.last.headingDeg ?? 0,
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (widget.pings.length < 2) return const {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.ink900,
        width: 4,
        points: widget.pings
            .map((p) => LatLng(p.lat, p.lng))
            .toList(growable: false),
      ),
    };
  }

  LatLng _initialTarget() {
    return _carrierPos ??
        _originPos ??
        _destPos ??
        const LatLng(39, 35); // Türkiye merkez
  }

  Future<void> _fitBounds() async {
    if (_controller == null) return;
    final points = <LatLng>[
      if (_originPos != null) _originPos!,
      if (_destPos != null) _destPos!,
      ...widget.pings.map((p) => LatLng(p.lat, p.lng)),
    ];
    if (points.isEmpty) return;
    if (points.length == 1) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 12),
      );
      return;
    }
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  void didUpdateWidget(covariant _MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.didInitialFit &&
        (widget.pings.isNotEmpty || _originPos != null || _destPos != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fitBounds();
        widget.onInitialFitted?.call();
      });
    }
  }

  bool get _useEmbeddedMap => !kIsWeb;

  @override
  Widget build(BuildContext context) {
    if (!_useEmbeddedMap) {
      return _WebMapFallback(
        job: widget.job,
        pings: widget.pings,
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialTarget(),
            zoom: 6,
          ),
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onMapCreated: (c) {
            _controller = c;
            widget.onMapReady?.call(c);
            WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
          },
        ),

        // Fit-to-bounds floating action
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'fit',
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.ink900,
            onPressed: _fitBounds,
            child: const Icon(Icons.center_focus_strong),
          ),
        ),

        // Alt sayfa özet kart
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _SummaryCard(
            job: widget.job,
            pings: widget.pings,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.job,
    required this.pings,
  });

  final JobPost job;
  final List<LocationPing> pings;

  @override
  Widget build(BuildContext context) {
    final last = pings.isEmpty ? null : pings.last;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayLight,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: last == null
                        ? AppColors.ink400
                        : AppColors.ink900,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  last == null ? 'Konum bekleniyor' : 'Canlı',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (last?.speedKmh != null)
                  Text(
                    '${last!.speedKmh!.toStringAsFixed(0)} km/h',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${job.originCity} → ${job.destinationCity}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (last != null) ...[
              const SizedBox(height: 4),
              Text(
                'Son güncelleme: ${_relative(last.recordedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.ink500,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds} sn önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }
}

class _WebMapFallback extends StatelessWidget {
  const _WebMapFallback({
    required this.job,
    required this.pings,
  });

  final JobPost job;
  final List<LocationPing> pings;

  @override
  Widget build(BuildContext context) {
    final latest = pings.isEmpty ? null : pings.last;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Web takip görünümü',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bu ortamda gömülü harita yerine güvenli yedek görünüm '
                'kullanılıyor.',
              ),
              const SizedBox(height: 12),
              Text('${job.originCity} → ${job.destinationCity}'),
              const SizedBox(height: 8),
              Text('Toplam ping: ${pings.length}'),
              if (latest != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Son konum: ${latest.lat.toStringAsFixed(4)}, '
                  '${latest.lng.toStringAsFixed(4)}',
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Canlı takip bu ekranda uygulama içi olarak devam eder.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.ink500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
