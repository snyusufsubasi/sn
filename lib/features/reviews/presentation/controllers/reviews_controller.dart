import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/review.dart';
import '../../data/repositories/demo_reviews_repository.dart';
import '../../data/repositories/reviews_repository.dart';

part 'reviews_controller.g.dart';

@Riverpod(keepAlive: true)
ReviewsRepository reviewsRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoReviewsRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseReviewsRepository(client);
}

@riverpod
Future<List<Review>> reviewsForUser(Ref ref, String userId) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  final result = await repo.fetchReviewsForUser(userId);
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

@riverpod
Future<bool> hasReviewedJob(Ref ref, String jobPostId) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  final result = await repo.hasReviewedJob(jobPostId);
  return result.when(
    success: (b) => b,
    failure: (_) => false,
  );
}

@riverpod
class CreateReviewController extends _$CreateReviewController {
  @override
  AsyncValue<Review?> build() => const AsyncValue.data(null);

  Future<bool> submit({
    required String jobPostId,
    required String revieweeId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(reviewsRepositoryProvider);
    final result = await repo.createReview(
      jobPostId: jobPostId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
    );
    return result.when(
      success: (r) {
        state = AsyncValue.data(r);
        ref.invalidate(hasReviewedJobProvider(jobPostId));
        ref.invalidate(reviewsForUserProvider(revieweeId));
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}
