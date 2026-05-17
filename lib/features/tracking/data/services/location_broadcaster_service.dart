import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/logger.dart';
import '../repositories/tracking_repository.dart';

/// Aktif taşıma sırasında nakliyecinin konumunu periyodik kaydeder.
///
/// Çalışma şekli:
/// - `start(jobPostId)` çağrıldığında her 30 saniyede bir konum alıp
///   `tracking_repository.recordPing` ile DB'ye yazar
/// - `stop()` çağrıldığında durur
/// - Job status `loaded` / `onRoad` / `deliveryApproval` aşamalarında aktif
///   olmalı, diğerlerinde durmalı (UI tarafında yönetilir)
///
/// Sınırlamalar:
/// - Background location şu an aktif değil; uygulama açıkken yayın yapılır.
///   Background için ek setup gerekiyor (workmanager + background_locator vb.)
class LocationBroadcasterService {
  LocationBroadcasterService(this._repo);

  final TrackingRepository _repo;
  Timer? _timer;
  String? _activeJobId;
  bool _broadcasting = false;

  static const _interval = Duration(seconds: 30);

  bool get isBroadcasting => _broadcasting;
  String? get activeJobId => _activeJobId;

  Future<bool> start(String jobPostId) async {
    if (_broadcasting && _activeJobId == jobPostId) return true;
    await stop();

    // İzin kontrolü
    final hasPermission = await _ensurePermission();
    if (!hasPermission) {
      AppLogger.w('Konum izni reddedildi');
      return false;
    }

    _activeJobId = jobPostId;
    _broadcasting = true;
    AppLogger.i('Konum yayını başladı: jobId=$jobPostId');

    // İlk ping'i hemen at
    await _recordOnce();

    // Periyodik
    _timer = Timer.periodic(_interval, (_) async => _recordOnce());
    return true;
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _broadcasting = false;
    final wasActive = _activeJobId;
    _activeJobId = null;
    if (wasActive != null) {
      AppLogger.i('Konum yayını durdu: jobId=$wasActive');
    }
  }

  Future<void> _recordOnce() async {
    if (_activeJobId == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _repo.recordPing(
        jobPostId: _activeJobId!,
        lat: pos.latitude,
        lng: pos.longitude,
        accuracyM: pos.accuracy,
        speedKmh: pos.speed >= 0 ? pos.speed * 3.6 : null,
        headingDeg: pos.heading >= 0 ? pos.heading : null,
      );
    } catch (e, st) {
      AppLogger.e('Ping alınamadı/kaydedilemedi', e, st);
    }
  }

  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.w('Konum servisi kapalı');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
