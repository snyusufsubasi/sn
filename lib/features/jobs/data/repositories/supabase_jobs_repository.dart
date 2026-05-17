import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/job_post.dart';
import 'jobs_repository.dart';

class SupabaseJobsRepository implements JobsRepository {
  SupabaseJobsRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  Future<Result<List<JobPost>>> fetchOpenJobs({
    JobFilter filter = const JobFilter(),
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('job_posts').select().eq('status', 'open');

      if (filter.originCity != null) {
        query = query.eq('origin_city', filter.originCity!);
      }
      if (filter.destinationCity != null) {
        query = query.eq('destination_city', filter.destinationCity!);
      }
      if (filter.cargoType != null) {
        query = query.eq('cargo_type', filter.cargoType!);
      }
      if (filter.trailerType != null) {
        query = query.eq('preferred_trailer_type', filter.trailerType!);
      }
      if (filter.minWeight != null) {
        query = query.gte('weight_tons', filter.minWeight!);
      }
      if (filter.maxWeight != null) {
        query = query.lte('weight_tons', filter.maxWeight!);
      }

      final rows = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(JobPost.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchOpenJobs error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<JobPost>>> fetchMyJobs({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }

      final rows = await _client
          .from('job_posts')
          .select()
          .eq('shipper_id', uid)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(JobPost.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchMyJobs error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<JobPost>>> fetchMyActiveCarrierJobs() async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }

      // Kabul edilmiş teklifim olan tüm aktif ilanlar
      final offerRows = await _client
          .from('offers')
          .select('job_post_id, job_posts(*)')
          .eq('carrier_id', uid)
          .eq('status', 'accepted');

      final list = (offerRows as List)
          .map((r) => r as Map<String, dynamic>)
          .where((r) => r['job_posts'] != null)
          .map((r) => JobPost.fromJson(r['job_posts'] as Map<String, dynamic>))
          .where((j) => !j.status.isCompleted && !j.status.isCancelled)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchMyActiveCarrierJobs error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<JobPost>>> fetchMyCompletedCarrierJobs() async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }

      final offerRows = await _client
          .from('offers')
          .select('job_post_id, job_posts(*)')
          .eq('carrier_id', uid)
          .eq('status', 'accepted');

      final list = (offerRows as List)
          .map((r) => r as Map<String, dynamic>)
          .where((r) => r['job_posts'] != null)
          .map((r) => JobPost.fromJson(r['job_posts'] as Map<String, dynamic>))
          .where((j) => j.status.isCompleted)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchMyCompletedCarrierJobs error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<JobPost?>> fetchJobById(String id) async {
    try {
      final row =
          await _client.from('job_posts').select().eq('id', id).maybeSingle();
      if (row == null) return const Success(null);
      return Success(JobPost.fromJson(row));
    } catch (e, st) {
      AppLogger.e('fetchJobById error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<JobPost>> createJob(
    JobPostInput input,
    String shipperId,
  ) async {
    try {
      final inserted = await _client
          .from('job_posts')
          .insert(input.toJson(shipperId))
          .select()
          .single();
      return Success(JobPost.fromJson(inserted));
    } catch (e, st) {
      AppLogger.e('createJob error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<JobPost>> updateJob(String id, JobPostInput input) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final updated = await _client
          .from('job_posts')
          .update(input.toJson(uid))
          .eq('id', id)
          .select()
          .single();
      return Success(JobPost.fromJson(updated));
    } catch (e, st) {
      AppLogger.e('updateJob error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> cancelJob(String id, String reason) async {
    try {
      await _client.rpc<void>(
        'cancel_job',
        params: {'p_job_id': id, 'p_reason': reason},
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('cancelJob error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<JobPost> watchJob(String id) {
    return _client
        .from('job_posts')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) => rows.isEmpty
            ? null
            : JobPost.fromJson(rows.first))
        .where((j) => j != null)
        .cast<JobPost>();
  }
}
