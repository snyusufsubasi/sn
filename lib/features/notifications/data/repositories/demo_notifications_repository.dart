import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/result.dart';
import '../models/app_notification.dart';
import 'notifications_repository.dart';

class DemoNotificationsRepository implements NotificationsRepository {
  DemoNotificationsRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  Future<Result<List<AppNotification>>> fetchNotifications({
    int limit = 50,
  }) async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success([]);
    return Success(_store.notificationsFor(uid).take(limit).toList());
  }

  @override
  Future<Result<int>> unreadCount() async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success(0);
    final count = _store.notificationsFor(uid).where((n) => !n.isRead).length;
    return Success(count);
  }

  @override
  Future<Result<void>> markRead(String id) async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success(null);
    final list = List<AppNotification>.from(_store.notificationsFor(uid));
    final idx = list.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(isRead: true);
      _store.updateNotifications(uid, list);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllRead() async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success(null);
    final list = _store
        .notificationsFor(uid)
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _store.updateNotifications(uid, list);
    return const Success(null);
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return Stream.periodic(const Duration(seconds: 2), (_) {
      final uid = _store.state.currentUserId;
      if (uid == null) return <AppNotification>[];
      return _store.notificationsFor(uid);
    });
  }
}
