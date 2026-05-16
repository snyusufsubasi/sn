import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/features/notifications/data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  return ref.watch(notificationRepositoryProvider).getMyNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationRepositoryProvider).getUnreadCount();
});
