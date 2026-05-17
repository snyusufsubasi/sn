import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import 'messages_repository.dart';

class DemoMessagesRepository implements MessagesRepository {
  DemoMessagesRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  final _messageStreams = <String, StreamController<List<Message>>>{};

  @override
  Future<Result<List<MessageThread>>> fetchThreads() async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success([]);
    final list = _store.state.threads.values.where(
      (t) => t.shipperId == uid || t.carrierId == uid,
    ).toList()
      ..sort(
        (a, b) => (b.lastMessageAt ?? DateTime(2000)).compareTo(
          a.lastMessageAt ?? DateTime(2000),
        ),
      );
    return Success(
      list.map((t) {
        final counterpartId = t.counterpartId(uid);
        final profile = _store.profile(counterpartId);
        return MessageThread(
          id: t.id,
          jobPostId: t.jobPostId,
          shipperId: t.shipperId,
          carrierId: t.carrierId,
          lastMessageAt: t.lastMessageAt,
          lastMessageBody: t.lastMessageBody,
          unreadCount: t.unreadCount,
          jobTitle: t.jobTitle ?? _store.job(t.jobPostId)?.title,
          counterpartName: profile?.fullName ?? t.counterpartName,
          counterpartAvatar: profile?.avatarUrl ?? t.counterpartAvatar,
        );
      }).toList(),
    );
  }

  @override
  Future<Result<List<Message>>> fetchMessages(
    String threadId, {
    int limit = 50,
  }) async {
    final msgs = _store.messagesForThread(threadId);
    return Success(msgs.take(limit).toList());
  }

  @override
  Future<Result<Message>> sendMessage({
    required String threadId,
    required String body,
  }) async {
    final uid = _store.state.currentUserId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    final msg = _store.appendMessage(
      threadId: threadId,
      senderId: uid,
      body: body,
    );
    _pushMessages(threadId, _store.messagesForThread(threadId));
    return Success(msg);
  }

  @override
  Future<Result<void>> markThreadRead(String threadId) async {
    _store.markThreadMessagesRead(threadId);
    return const Success(null);
  }

  @override
  Stream<List<Message>> watchMessages(String threadId) {
    final existing = _messageStreams[threadId];
    if (existing != null) return existing.stream;

    final controller = StreamController<List<Message>>.broadcast();
    _messageStreams[threadId] = controller;
    Future.microtask(
      () => controller.add(_store.messagesForThread(threadId)),
    );
    return controller.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchThreads() {
    return Stream.periodic(
      const Duration(seconds: 3),
      (_) => _store.state.threads.values.map((t) => {'id': t.id}).toList(),
    );
  }

  void _pushMessages(String threadId, List<Message> list) {
    _messageStreams[threadId]?.add(list);
  }
}
