import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? relatedJobId;
  final String? relatedOfferId;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedJobId,
    this.relatedOfferId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: map['type'] as String? ?? '',
      relatedJobId: map['related_job_id'] as String?,
      relatedOfferId: map['related_offer_id'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: map['created_at'] as String,
    );
  }
}

class NotificationRepository {
  final _client = SupabaseClientManager.instance.client;

  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<List<AppNotification>> getMyNotifications() async {
    if (DevAuthService.isActive) {
      return (await DevAuthService.getNotifications())
          .where(
            (n) =>
                n['user_id'] == _userId ||
                n['user_id'] == DevAuthService.demoCarrierId,
          )
          .map(AppNotification.fromMap)
          .toList();
    }

    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(AppNotification.fromMap).toList();
  }

  Future<int> getUnreadCount() async {
    if (DevAuthService.isActive) {
      final notifications = await getMyNotifications();
      return notifications.where((n) => !n.isRead).length;
    }

    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', _userId)
        .eq('is_read', false);
    return response.length;
  }

  Future<void> markAsRead(String notificationId) async {
    if (DevAuthService.isActive) {
      await DevAuthService.markNotificationAsRead(notificationId);
      return;
    }

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', _userId);
  }

  Future<void> markAllAsRead() async {
    if (DevAuthService.isActive) {
      await DevAuthService.markAllNotificationsAsRead();
      return;
    }

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _userId)
        .eq('is_read', false);
  }
}
