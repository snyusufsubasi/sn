import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:uuid/uuid.dart';

class Review {
  final String id;
  final String jobPostId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String? comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.jobPostId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      jobPostId: map['job_post_id'] as String,
      reviewerId: map['reviewer_id'] as String,
      revieweeId: map['reviewee_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}

class ReviewRepository {
  final _client = SupabaseClientManager.instance.client;
  final _uuid = const Uuid();

  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<Review> createReview({
    required String jobPostId,
    required String revieweeId,
    required int rating,
    String? comment,
  }) async {
    if (DevAuthService.isActive) {
      if (await hasReviewed(jobPostId, revieweeId)) {
        throw StateError('Bu iş için değerlendirme zaten kaydedildi.');
      }
      final review = {
        'id': _uuid.v4(),
        'job_post_id': jobPostId,
        'reviewer_id': _userId,
        'reviewee_id': revieweeId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      };
      await DevAuthService.addReview(review);
      return Review.fromMap(review);
    }

    final response = await _client
        .from('reviews')
        .insert({
          'job_post_id': jobPostId,
          'reviewer_id': _userId,
          'reviewee_id': revieweeId,
          'rating': rating,
          'comment': comment,
        })
        .select()
        .single();

    return Review.fromMap(response);
  }

  Future<bool> hasReviewed(String jobPostId, String revieweeId) async {
    if (DevAuthService.isActive) {
      final reviews = await DevAuthService.getReviews();
      return reviews.any(
        (r) =>
            r['job_post_id'] == jobPostId &&
            r['reviewer_id'] == _userId &&
            r['reviewee_id'] == revieweeId,
      );
    }

    final response = await _client
        .from('reviews')
        .select('id')
        .eq('job_post_id', jobPostId)
        .eq('reviewer_id', _userId)
        .eq('reviewee_id', revieweeId)
        .maybeSingle();
    return response != null;
  }

  Future<Review?> getMyReviewForJob(String jobPostId, String revieweeId) async {
    if (DevAuthService.isActive) {
      final reviews = await DevAuthService.getReviews();
      try {
        return Review.fromMap(
          reviews.firstWhere(
            (r) =>
                r['job_post_id'] == jobPostId &&
                r['reviewer_id'] == _userId &&
                r['reviewee_id'] == revieweeId,
          ),
        );
      } catch (_) {
        return null;
      }
    }

    final response = await _client
        .from('reviews')
        .select()
        .eq('job_post_id', jobPostId)
        .eq('reviewer_id', _userId)
        .eq('reviewee_id', revieweeId)
        .maybeSingle();
    if (response == null) return null;
    return Review.fromMap(response);
  }

  Future<List<Review>> getReviewsForUser(String userId) async {
    if (DevAuthService.isActive) {
      return (await DevAuthService.getReviews())
          .where((r) => r['reviewee_id'] == userId)
          .map(Review.fromMap)
          .toList();
    }

    final response = await _client
        .from('reviews')
        .select()
        .eq('reviewee_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(Review.fromMap).toList();
  }
}
