import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import 'messages_repository.dart';

class SupabaseMessagesRepository implements MessagesRepository {
  SupabaseMessagesRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  Future<Result<List<MessageThread>>> fetchThreads() async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }

      List<MessageThread> threads;
      try {
        final summaryRows = await _client
            .from('message_threads_summary')
            .select(
              'id, job_post_id, shipper_id, carrier_id, last_message_at, '
              'last_message_body, unread_count, '
              'job_posts(title), '
              'shipper:profiles!message_threads_shipper_id_fkey'
              '(id, full_name, avatar_url), '
              'carrier:profiles!message_threads_carrier_id_fkey'
              '(id, full_name, avatar_url)',
            )
            .or('shipper_id.eq.$uid,carrier_id.eq.$uid')
            .order('last_message_at', ascending: false, nullsFirst: false);

        threads = (summaryRows as List)
            .cast<Map<String, dynamic>>()
            .map((j) {
              final base = MessageThread.fromJson(j, currentUserId: uid);
              return base.copyWith(
                lastMessageBody:
                    j['last_message_body'] as String? ?? base.lastMessageBody,
                unreadCount:
                    (j['unread_count'] as num?)?.toInt() ?? base.unreadCount,
              );
            })
            .toList();
      } on Object {
        final rows = await _client
            .from('message_threads')
            .select(
              'id, job_post_id, shipper_id, carrier_id, last_message_at, '
              'job_posts(title), '
              'shipper:profiles!message_threads_shipper_id_fkey'
              '(id, full_name, avatar_url), '
              'carrier:profiles!message_threads_carrier_id_fkey'
              '(id, full_name, avatar_url)',
            )
            .or('shipper_id.eq.$uid,carrier_id.eq.$uid')
            .order('last_message_at', ascending: false, nullsFirst: false);

        threads = (rows as List)
            .cast<Map<String, dynamic>>()
            .map((j) => MessageThread.fromJson(j, currentUserId: uid))
            .toList();

        for (var i = 0; i < threads.length; i++) {
          final t = threads[i];
          try {
            final lastMsg = await _client
                .from('messages')
                .select('body')
                .eq('thread_id', t.id)
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();

            final unreadRows = await _client
                .from('messages')
                .select('id')
                .eq('thread_id', t.id)
                .eq('is_read', false)
                .neq('sender_id', uid);

            threads[i] = t.copyWith(
              lastMessageBody: lastMsg?['body'] as String?,
              unreadCount: (unreadRows as List).length,
            );
          } on Object {
            // tek thread özeti başarısız olsa liste döner
          }
        }
      }
      return Success(threads);
    } catch (e, st) {
      AppLogger.e('fetchThreads error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<Message>>> fetchMessages(
    String threadId, {
    int limit = 50,
  }) async {
    try {
      final rows = await _client
          .from('messages')
          .select()
          .eq('thread_id', threadId)
          .order('created_at', ascending: true)
          .limit(limit);

      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(Message.fromJson)
          .toList();
      return Success(list);
    } catch (e, st) {
      AppLogger.e('fetchMessages error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Message>> sendMessage({
    required String threadId,
    required String body,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      final inserted = await _client.from('messages').insert({
        'thread_id': threadId,
        'sender_id': uid,
        'body': body,
      }).select().single();

      // thread'in last_message_at'ini güncelle
      await _client.from('message_threads').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', threadId);

      return Success(Message.fromJson(inserted));
    } catch (e, st) {
      AppLogger.e('sendMessage error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> markThreadRead(String threadId) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('thread_id', threadId)
          .neq('sender_id', uid)
          .eq('is_read', false);
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('markThreadRead error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<Message>> watchMessages(String threadId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('thread_id', threadId)
        .order('created_at')
        .map((rows) =>
            rows.cast<Map<String, dynamic>>().map(Message.fromJson).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> watchThreads() {
    // Tüm thread tablo değişiklikleri — UI tarafında filter yapılır.
    return _client
        .from('message_threads')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }
}
