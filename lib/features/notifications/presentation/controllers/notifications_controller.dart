import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/demo_notifications_repository.dart';
import '../../data/repositories/notifications_repository.dart';

part 'notifications_controller.g.dart';

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoNotificationsRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseNotificationsRepository(client);
}

@riverpod
Future<List<AppNotification>> notificationsList(Ref ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  final result = await repo.fetchNotifications();
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

@riverpod
Future<int> unreadNotificationsCount(Ref ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  final result = await repo.unreadCount();
  return result.when(
    success: (n) => n,
    failure: (_) => 0,
  );
}

@riverpod
class NotificationActions extends _$NotificationActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> markRead(String id) async {
    final repo = ref.read(notificationsRepositoryProvider);
    final result = await repo.markRead(id);
    result.when(
      success: (_) {
        ref.invalidate(notificationsListProvider);
        ref.invalidate(unreadNotificationsCountProvider);
      },
      failure: (_) {},
    );
  }

  Future<void> markAllRead() async {
    final repo = ref.read(notificationsRepositoryProvider);
    final result = await repo.markAllRead();
    result.when(
      success: (_) {
        ref.invalidate(notificationsListProvider);
        ref.invalidate(unreadNotificationsCountProvider);
      },
      failure: (_) {},
    );
  }
}
