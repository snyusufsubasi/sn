import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../../jobs/presentation/controllers/jobs_controller.dart';
import '../../data/models/offer.dart';
import '../../data/repositories/demo_offers_repository.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/supabase_offers_repository.dart';

part 'offers_controller.g.dart';

@Riverpod(keepAlive: true)
OffersRepository offersRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoOffersRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseOffersRepository(client);
}

/// İlana gelen tüm teklifler (yükveren görür).
@riverpod
Future<List<Offer>> offersForJob(Ref ref, String jobId) async {
  final repo = ref.watch(offersRepositoryProvider);
  final result = await repo.fetchOffersForJob(jobId);
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Bu nakliyecinin bu ilana verdiği teklif (yoksa null).
@riverpod
Future<Offer?> myOfferForJob(Ref ref, String jobId) async {
  final repo = ref.watch(offersRepositoryProvider);
  final result = await repo.fetchMyOfferForJob(jobId);
  return result.when(
    success: (o) => o,
    failure: (f) => throw f,
  );
}

/// Bu nakliyecinin tüm teklifleri.
@riverpod
Future<List<Offer>> myOffers(Ref ref) async {
  final repo = ref.watch(offersRepositoryProvider);
  final result = await repo.fetchMyOffers();
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Teklif oluşturma.
@riverpod
class CreateOfferController extends _$CreateOfferController {
  @override
  AsyncValue<Offer?> build() => const AsyncValue.data(null);

  Future<Offer?> submit({
    required String jobPostId,
    required double price,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(offersRepositoryProvider);
    final result = await repo.createOffer(
      jobPostId: jobPostId,
      price: price,
      message: message,
    );
    return result.when(
      success: (o) {
        state = AsyncValue.data(o);
        ref.invalidate(myOfferForJobProvider(jobPostId));
        ref.invalidate(offersForJobProvider(jobPostId));
        ref.invalidate(myOffersProvider);
        return o;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return null;
      },
    );
  }
}

/// Offer aksiyonları — kabul/red/withdraw/operasyon RPC'leri.
@riverpod
class OfferActionsController extends _$OfferActionsController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> accept(String offerId, String jobId) async {
    return _wrap(() async {
      final repo = ref.read(offersRepositoryProvider);
      return repo.acceptOffer(offerId);
    }, jobId);
  }

  Future<bool> reject(String offerId, String jobId) async {
    return _wrap(() async {
      final repo = ref.read(offersRepositoryProvider);
      return repo.rejectOffer(offerId);
    }, jobId);
  }

  Future<bool> withdraw(String offerId, String jobId) async {
    return _wrap(() async {
      final repo = ref.read(offersRepositoryProvider);
      return repo.withdrawOffer(offerId);
    }, jobId);
  }

  Future<bool> confirmPickup(String jobId) async {
    return _wrap(() async {
      final repo = ref.read(offersRepositoryProvider);
      return repo.confirmPickup(jobId);
    }, jobId);
  }

  Future<bool> startRoad(String jobId) async {
    return _wrap(() async {
      final repo = ref.read(offersRepositoryProvider);
      return repo.startRoad(jobId);
    }, jobId);
  }

  Future<bool> confirmDelivery(String jobId) async {
    return _wrap(() async {
      final repo = ref.read(offersRepositoryProvider);
      return repo.confirmDelivery(jobId);
    }, jobId);
  }

  Future<bool> _wrap(
    Future<Result<void>> Function() action,
    String jobId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final result = await action();
      if (result.isSuccess) {
        state = const AsyncValue.data(null);
        ref.invalidate(jobDetailProvider(jobId));
        ref.invalidate(offersForJobProvider(jobId));
        ref.invalidate(myOfferForJobProvider(jobId));
        ref.invalidate(myJobsProvider);
        ref.invalidate(myActiveCarrierJobsProvider);
        return true;
      }
      state = AsyncValue.error(result.failureOrNull!, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
