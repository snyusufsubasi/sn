import 'package:equatable/equatable.dart';

enum OfferStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
  expired;

  static OfferStatus fromString(String value) =>
      OfferStatus.values.firstWhere((e) => e.name == value);
}

class Offer extends Equatable {
  const Offer({
    required this.id,
    required this.jobPostId,
    required this.carrierId,
    required this.price,
    required this.status, required this.createdAt, this.message,
    this.expiresAt,
    this.carrierName,
    this.carrierRating,
    this.carrierCompletedJobs,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Offer(
      id: json['id'] as String,
      jobPostId: json['job_post_id'] as String,
      carrierId: json['carrier_id'] as String,
      price: (json['price'] as num).toDouble(),
      message: json['message'] as String?,
      status: OfferStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      carrierName: profile?['full_name'] as String?,
      carrierRating: (profile?['rating_avg'] as num?)?.toDouble(),
      carrierCompletedJobs: profile?['completed_jobs_count'] as int?,
    );
  }

  final String id;
  final String jobPostId;
  final String carrierId;
  final double price;
  final String? message;
  final OfferStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  // Join'lerden gelen carrier bilgileri (UI için)
  final String? carrierName;
  final double? carrierRating;
  final int? carrierCompletedJobs;

  bool get isPending => status == OfferStatus.pending;
  bool get isAccepted => status == OfferStatus.accepted;

  Map<String, dynamic> toInsertJson(String carrierId) => {
        'job_post_id': jobPostId,
        'carrier_id': carrierId,
        'price': price,
        if (message != null) 'message': message,
      };

  @override
  List<Object?> get props => [
        id,
        jobPostId,
        carrierId,
        price,
        message,
        status,
        createdAt,
      ];
}
