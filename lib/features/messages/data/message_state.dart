import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'message_repository.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final userId = DevAuthService.isActive ? DevAuthService.devUserId : SupabaseClientManager.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  final repo = ref.read(messageRepositoryProvider);
  return repo.getConversations(userId);
});

final unreadMessageCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = DevAuthService.isActive ? DevAuthService.devUserId : SupabaseClientManager.instance.client.auth.currentUser?.id;
  if (userId == null) return 0;
  final repo = ref.read(messageRepositoryProvider);
  return repo.getUnreadCount(userId);
});
