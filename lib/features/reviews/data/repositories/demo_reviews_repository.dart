import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/review.dart';
import 'reviews_repository.dart';

class DemoReviewsRepository implements ReviewsRepository {
  DemoReviewsRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  Future<Result<Review>> createReview({
    required String jobPostId,
    required String revieweeId,
    required int rating,
    String? comment,
  }) async {
    final uid = _store.state.currentUserId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    if (rating < 1 || rating > 5) {
      return const ResultFailure(
        ValidationFailure(message: 'Puan 1-5 arası olmalı'),
      );
    }
    return Success(
      _store.addReview(
        jobPostId: jobPostId,
        reviewerId: uid,
        revieweeId: revieweeId,
        rating: rating,
        comment: comment,
      ),
    );
  }

  @override
  Future<Result<List<Review>>> fetchReviewsForUser(String userId) async {
    final list = _store.state.reviews
        .where((r) => r.revieweeId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list);
  }

  @override
  Future<Result<bool>> hasReviewedJob(String jobPostId) async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success(false);
    final exists = _store.state.reviews.any(
      (r) => r.jobPostId == jobPostId && r.reviewerId == uid,
    );
    return Success(exists);
  }
}
