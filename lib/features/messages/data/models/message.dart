import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderId: json['sender_id'] as String,
      body: json['body'] as String,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String threadId;
  final String senderId;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  bool isMine(String currentUserId) => senderId == currentUserId;

  Message copyWith({bool? isRead}) => Message(
        id: id,
        threadId: threadId,
        senderId: senderId,
        body: body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, threadId, senderId, body, isRead, createdAt];
}
