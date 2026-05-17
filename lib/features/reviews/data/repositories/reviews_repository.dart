import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/review.dart';

abstract class ReviewsRepository {
  Future<Result<Review>> createReview({
    required String jobPostId,
    required String revieweeId,
    required int rating,
    String? comment,
  });

  Future<Result<List<Review>>> fetchReviewsForUser(String userId);

  /// Bu job için bu kullanıcı review yapmış mı?
  Future<Result<bool>> hasReviewedJob(String jobPostId);
}

class SupabaseReviewsRepository implements ReviewsRepository {
  SupabaseReviewsRepository(this._client);
  final SupabaseClientWrapper _client;

  @override
  Future<Result<Review>> createReview({
    required String jobPostId,
    required String revieweeId,
    required int rating,
    String? comment,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      if (rating < 1 || rating > 5) {
        return const ResultFailure(
          ValidationFailure(message: 'Puan 1-5 arası olmalı'),
        );
      }
      final inserted = await _client.from('reviews').insert({
        'job_post_id': jobPostId,
        'reviewer_id': uid,
        'reviewee_id': revieweeId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      }).select().single();
      return Success(Review.fromJson(inserted));
    } catch (e, st) {
      AppLogger.e('createReview error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<Review>>> fetchReviewsForUser(String userId) async {
    try {
      final rows = await _client
          .from('reviews')
          .select(
            'id, job_post_id, reviewer_id, reviewee_id, rating, comment, '
            'created_at, '
            'reviewer:profiles!reviews_reviewer_id_fkey(full_name)',
          )
          .eq('reviewee_id', userId)
          .order('created_at', ascending: false);
      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(Review.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchReviewsForUser error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<bool>> hasReviewedJob(String jobPostId) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final row = await _client
          .from('reviews')
          .select('id')
          .eq('job_post_id', jobPostId)
          .eq('reviewer_id', uid)
          .maybeSingle();
      return Success(row != null);
    } catch (e, st) {
      AppLogger.e('hasReviewedJob error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }
}
