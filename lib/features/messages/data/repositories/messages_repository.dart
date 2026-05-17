import 'dart:async';

import '../../../../core/errors/result.dart';
import '../models/message.dart';
import '../models/message_thread.dart';

abstract class MessagesRepository {
  Future<Result<List<MessageThread>>> fetchThreads();
  Future<Result<List<Message>>> fetchMessages(
    String threadId, {
    int limit = 50,
  });
  Future<Result<Message>> sendMessage({
    required String threadId,
    required String body,
  });
  Future<Result<void>> markThreadRead(String threadId);

  /// Tek bir thread'in mesajlarını realtime izle.
  Stream<List<Message>> watchMessages(String threadId);

  /// Threadlerdeki değişiklikleri izle (yeni mesaj geldiğinde liste yenilenir).
  Stream<List<Map<String, dynamic>>> watchThreads();
}
