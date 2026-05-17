import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/location_ping.dart';

abstract class TrackingRepository {
  /// Nakliyecinin kendi konum ping'ini kaydet.
  Future<Result<void>> recordPing({
    required String jobPostId,
    required double lat,
    required double lng,
    double? accuracyM,
    double? speedKmh,
    double? headingDeg,
  });

  /// Bir iş için tüm ping'leri getir (eskiden yeniye).
  Future<Result<List<LocationPing>>> fetchPings(String jobPostId);

  /// Bir iş için son ping'i getir.
  Future<Result<LocationPing?>> fetchLatestPing(String jobPostId);

  /// Realtime — yeni ping'ler stream'le.
  Stream<List<LocationPing>> watchPings(String jobPostId);
}

class SupabaseTrackingRepository implements TrackingRepository {
  SupabaseTrackingRepository(this._client);
  final SupabaseClientWrapper _client;

  @override
  Future<Result<void>> recordPing({
    required String jobPostId,
    required double lat,
    required double lng,
    double? accuracyM,
    double? speedKmh,
    double? headingDeg,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      await _client.from('location_pings').insert({
        'job_post_id': jobPostId,
        'carrier_id': uid,
        'lat': lat,
        'lng': lng,
        if (accuracyM != null) 'accuracy_m': accuracyM,
        if (speedKmh != null) 'speed_kmh': speedKmh,
        if (headingDeg != null) 'heading_deg': headingDeg,
      });
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('recordPing error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<LocationPing>>> fetchPings(String jobPostId) async {
    try {
      final rows = await _client
          .from('location_pings')
          .select()
          .eq('job_post_id', jobPostId)
          .order('recorded_at', ascending: true);
      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(LocationPing.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchPings error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<LocationPing?>> fetchLatestPing(String jobPostId) async {
    try {
      final row = await _client
          .from('location_pings')
          .select()
          .eq('job_post_id', jobPostId)
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) return const Success(null);
      return Success(LocationPing.fromJson(row));
    } catch (e, st) {
      AppLogger.e('fetchLatestPing error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<LocationPing>> watchPings(String jobPostId) {
    return _client
        .from('location_pings')
        .stream(primaryKey: ['id'])
        .eq('job_post_id', jobPostId)
        .order('recorded_at')
        .map((rows) => rows
            .cast<Map<String, dynamic>>()
            .map(LocationPing.fromJson)
            .toList());
  }
}
