import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/result.dart';
import '../models/location_ping.dart';
import 'tracking_repository.dart';

class DemoTrackingRepository implements TrackingRepository {
  DemoTrackingRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  Future<Result<void>> recordPing({
    required String jobPostId,
    required double lat,
    required double lng,
    double? accuracyM,
    double? speedKmh,
    double? headingDeg,
  }) async {
    _store.addPing(jobPostId, lat, lng);
    return const Success(null);
  }

  @override
  Future<Result<List<LocationPing>>> fetchPings(String jobPostId) async {
    return Success(_store.state.pingsByJob[jobPostId] ?? []);
  }

  @override
  Future<Result<LocationPing?>> fetchLatestPing(String jobPostId) async {
    final pings = _store.state.pingsByJob[jobPostId] ?? [];
    if (pings.isEmpty) return const Success(null);
    return Success(pings.last);
  }

  @override
  Stream<List<LocationPing>> watchPings(String jobPostId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return _store.state.pingsByJob[jobPostId] ?? [];
    });
  }
}
