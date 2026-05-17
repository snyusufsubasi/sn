import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/location_ping.dart';
import '../../data/repositories/demo_tracking_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../data/services/location_broadcaster_service.dart';

part 'tracking_controller.g.dart';

@Riverpod(keepAlive: true)
TrackingRepository trackingRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoTrackingRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTrackingRepository(client);
}

@Riverpod(keepAlive: true)
LocationBroadcasterService locationBroadcaster(Ref ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  return LocationBroadcasterService(repo);
}

/// Bir iş için son konum (polling değil, realtime).
@riverpod
Stream<List<LocationPing>> jobLocationPings(Ref ref, String jobPostId) {
  final repo = ref.watch(trackingRepositoryProvider);
  return repo.watchPings(jobPostId);
}

/// Tek seferlik son ping (snapshot için).
@riverpod
Future<LocationPing?> latestJobPing(Ref ref, String jobPostId) async {
  final repo = ref.watch(trackingRepositoryProvider);
  final r = await repo.fetchLatestPing(jobPostId);
  return r.valueOrNull;
}
