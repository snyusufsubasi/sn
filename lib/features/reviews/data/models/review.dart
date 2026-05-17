import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.jobPostId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.createdAt, this.comment,
    this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] as String,
      jobPostId: json['job_post_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      revieweeId: json['reviewee_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerName: reviewer?['full_name'] as String?,
    );
  }

  final String id;
  final String jobPostId;
  final String reviewerId;
  final String revieweeId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  // Join'den gelen reviewer adı (UI için)
  final String? reviewerName;

  @override
  List<Object?> get props =>
      [id, jobPostId, reviewerId, revieweeId, rating, comment, createdAt];
}
