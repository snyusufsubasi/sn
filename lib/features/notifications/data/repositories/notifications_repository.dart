import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> fetchNotifications({int limit = 50});
  Future<Result<int>> unreadCount();
  Future<Result<void>> markRead(String id);
  Future<Result<void>> markAllRead();
  Stream<List<AppNotification>> watchNotifications();
}

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);
  final SupabaseClientWrapper _client;

  @override
  Future<Result<List<AppNotification>>> fetchNotifications({
    int limit = 50,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchNotifications error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> unreadCount() async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final rows = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);
      return Success((rows as List).length);
    } catch (e, st) {
      AppLogger.e('unreadCount error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> markRead(String id) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('markRead error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> markAllRead() async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('markAllRead error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    final uid = _client.currentUserId;
    if (uid == null) return Stream.value(const []);
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList());
  }
}
