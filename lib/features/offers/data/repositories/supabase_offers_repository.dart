import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/offer.dart';
import 'offers_repository.dart';

class SupabaseOffersRepository implements OffersRepository {
  SupabaseOffersRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  Future<Result<List<Offer>>> fetchOffersForJob(String jobId) async {
    try {
      // Carrier profile bilgilerini join et
      final rows = await _client
          .from('offers')
          .select(
            'id, job_post_id, carrier_id, price, message, status, '
            'created_at, expires_at, '
            'profiles!offers_carrier_id_fkey(full_name, rating_avg, '
            'completed_jobs_count)',
          )
          .eq('job_post_id', jobId)
          .order('created_at', ascending: false);

      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(Offer.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchOffersForJob error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Offer?>> fetchMyOfferForJob(String jobId) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final row = await _client
          .from('offers')
          .select()
          .eq('job_post_id', jobId)
          .eq('carrier_id', uid)
          .maybeSingle();
      if (row == null) return const Success(null);
      return Success(Offer.fromJson(row));
    } catch (e, st) {
      AppLogger.e('fetchMyOfferForJob error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<Offer>>> fetchMyOffers() async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final rows = await _client
          .from('offers')
          .select()
          .eq('carrier_id', uid)
          .order('created_at', ascending: false);

      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(Offer.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchMyOffers error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Offer>> createOffer({
    required String jobPostId,
    required double price,
    String? message,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final inserted = await _client.from('offers').insert({
        'job_post_id': jobPostId,
        'carrier_id': uid,
        'price': price,
        if (message != null) 'message': message,
      }).select().single();
      return Success(Offer.fromJson(inserted));
    } catch (e, st) {
      AppLogger.e('createOffer error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> acceptOffer(String offerId) async {
    return _runRpc('accept_offer', {'p_offer_id': offerId});
  }

  @override
  Future<Result<void>> rejectOffer(String offerId) async {
    return _runRpc('reject_offer', {'p_offer_id': offerId});
  }

  @override
  Future<Result<void>> withdrawOffer(String offerId) async {
    try {
      await _client
          .from('offers')
          .update({'status': 'withdrawn'}).eq('id', offerId);
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('withdrawOffer error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> confirmPickup(String jobId) {
    return _runRpc('confirm_pickup', {'p_job_id': jobId});
  }

  @override
  Future<Result<void>> startRoad(String jobId) {
    return _runRpc('start_road', {'p_job_id': jobId});
  }

  @override
  Future<Result<void>> confirmDelivery(String jobId) {
    return _runRpc('confirm_delivery', {'p_job_id': jobId});
  }

  Future<Result<void>> _runRpc(
    String name,
    Map<String, dynamic> params,
  ) async {
    try {
      await _client.rpc<void>(name, params: params);
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('RPC $name error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }
}
