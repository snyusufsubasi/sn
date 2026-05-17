import 'package:equatable/equatable.dart';

/// Thread'in liste görünümünde ihtiyaç duyulan tüm bilgiler.
/// Son mesaj, okunmamış sayısı, karşı tarafın adı, ilan başlığı.
class MessageThread extends Equatable {
  const MessageThread({
    required this.id,
    required this.jobPostId,
    required this.shipperId,
    required this.carrierId,
    this.lastMessageAt,
    this.lastMessageBody,
    this.unreadCount = 0,
    this.jobTitle,
    this.counterpartName,
    this.counterpartAvatar,
  });

  factory MessageThread.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final job = json['job_posts'] as Map<String, dynamic>?;
    final shipperProfile = json['shipper'] as Map<String, dynamic>?;
    final carrierProfile = json['carrier'] as Map<String, dynamic>?;

    final shipperId = json['shipper_id'] as String;
    final carrierId = json['carrier_id'] as String;
    final counterpartProfile =
        currentUserId == shipperId ? carrierProfile : shipperProfile;

    return MessageThread(
      id: json['id'] as String,
      jobPostId: json['job_post_id'] as String,
      shipperId: shipperId,
      carrierId: carrierId,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      jobTitle: job?['title'] as String?,
      counterpartName: counterpartProfile?['full_name'] as String?,
      counterpartAvatar: counterpartProfile?['avatar_url'] as String?,
    );
  }

  final String id;
  final String jobPostId;
  final String shipperId;
  final String carrierId;
  final DateTime? lastMessageAt;
  final String? lastMessageBody;
  final int unreadCount;
  final String? jobTitle;
  final String? counterpartName;
  final String? counterpartAvatar;

  String counterpartId(String currentUserId) =>
      currentUserId == shipperId ? carrierId : shipperId;

  MessageThread copyWith({
    DateTime? lastMessageAt,
    String? lastMessageBody,
    int? unreadCount,
  }) =>
      MessageThread(
        id: id,
        jobPostId: jobPostId,
        shipperId: shipperId,
        carrierId: carrierId,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        lastMessageBody: lastMessageBody ?? this.lastMessageBody,
        unreadCount: unreadCount ?? this.unreadCount,
        jobTitle: jobTitle,
        counterpartName: counterpartName,
        counterpartAvatar: counterpartAvatar,
      );

  @override
  List<Object?> get props => [
        id,
        jobPostId,
        lastMessageAt,
        lastMessageBody,
        unreadCount,
        jobTitle,
        counterpartName,
      ];
}
