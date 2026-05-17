import 'package:equatable/equatable.dart';

enum NotificationType {
  newOffer,
  offerAccepted,
  offerRejected,
  jobStatusChanged,
  newMessage,
  reviewReceived,
  paymentReceived,
  paymentPending,
  paymentConfirmed,
  disputeOpened,
  system;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'new_offer':
        return NotificationType.newOffer;
      case 'offer_accepted':
        return NotificationType.offerAccepted;
      case 'offer_rejected':
        return NotificationType.offerRejected;
      case 'job_status_changed':
        return NotificationType.jobStatusChanged;
      case 'new_message':
        return NotificationType.newMessage;
      case 'review_received':
        return NotificationType.reviewReceived;
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'payment_pending':
        return NotificationType.paymentPending;
      case 'payment_confirmed':
        return NotificationType.paymentConfirmed;
      case 'dispute_opened':
        return NotificationType.disputeOpened;
      default:
        return NotificationType.system;
    }
  }
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead, required this.createdAt, this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  /// data içindeki job_post_id (varsa)
  String? get jobPostId => data?['job_post_id'] as String?;
  String? get threadId => data?['thread_id'] as String?;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, userId, type, title, body, isRead, createdAt];
}
