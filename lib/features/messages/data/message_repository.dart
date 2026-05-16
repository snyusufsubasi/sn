import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasima_app/core/dev_auth_service.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String? jobPostId;
  final String content;
  final String createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.jobPostId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        receiverId: map['receiver_id'] as String,
        jobPostId: map['job_post_id'] as String?,
        content: map['content'] as String,
        createdAt: map['created_at'] as String,
        isRead: map['is_read'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'job_post_id': jobPostId,
        'content': content,
        'created_at': createdAt,
        'is_read': isRead,
      };
}

class Conversation {
  final String otherUserId;
  final String otherUserName;
  final String? jobPostId;
  final String? jobTitle;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.otherUserId,
    required this.otherUserName,
    this.jobPostId,
    this.jobTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class MessageRepository {
  static const _key = 'dev_messages';

  Future<List<Message>> _allMessages() async {
    if (DevAuthService.isActive) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => Message.fromMap(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> _saveAll(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(messages.map((m) => m.toMap()).toList()),
    );
  }

  Future<List<Message>> getMessagesForConversation(
      String userId1, String userId2) async {
    final all = await _allMessages();
    return all
        .where((m) =>
            (m.senderId == userId1 && m.receiverId == userId2) ||
            (m.senderId == userId2 && m.receiverId == userId1))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<Conversation>> getConversations(String userId) async {
    final all = await _allMessages();
    final Map<String, List<Message>> grouped = {};

    for (final m in all) {
      if (m.senderId != userId && m.receiverId != userId) continue;
      final otherId = m.senderId == userId ? m.receiverId : m.senderId;
      grouped.putIfAbsent(otherId, () => []).add(m);
    }

    final conversations = <Conversation>[];
    for (final entry in grouped.entries) {
      final msgs = entry.value..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final last = msgs.first;
      final unread = msgs.where((m) => m.receiverId == userId && !m.isRead).length;

      String otherName = 'Kullanıcı';
      if (DevAuthService.isActive) {
        final profile = await DevAuthService.getProfileForUser(entry.key);
        otherName = profile?['full_name'] as String? ?? otherName;
      }

      String? jobTitle;
      if (last.jobPostId != null) {
        jobTitle = 'Is #';
      }

      conversations.add(Conversation(
        otherUserId: entry.key,
        otherUserName: otherName,
        jobPostId: last.jobPostId,
        jobTitle: jobTitle,
        lastMessage: last.content,
        lastMessageTime: last.createdAt,
        unreadCount: unread,
      ));
    }

    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }

  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? jobPostId,
  }) async {
    final all = await _allMessages();
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      jobPostId: jobPostId,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
    );
    all.add(msg);
    await _saveAll(all);
    return msg;
  }

  Future<void> markConversationAsRead(String userId, String otherUserId) async {
    final all = await _allMessages();
    for (int i = 0; i < all.length; i++) {
      final m = all[i];
      if (m.senderId == otherUserId && m.receiverId == userId && !m.isRead) {
        all[i] = Message(
          id: m.id,
          senderId: m.senderId,
          receiverId: m.receiverId,
          jobPostId: m.jobPostId,
          content: m.content,
          createdAt: m.createdAt,
          isRead: true,
        );
      }
    }
    await _saveAll(all);
  }

  Future<int> getUnreadCount(String userId) async {
    final all = await _allMessages();
    return all.where((m) => m.receiverId == userId && !m.isRead).length;
  }
}
