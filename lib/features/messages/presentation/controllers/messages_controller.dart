import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/message.dart';
import '../../data/models/message_thread.dart';
import '../../data/repositories/demo_messages_repository.dart';
import '../../data/repositories/messages_repository.dart';
import '../../data/repositories/supabase_messages_repository.dart';

part 'messages_controller.g.dart';

@Riverpod(keepAlive: true)
MessagesRepository messagesRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoMessagesRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMessagesRepository(client);
}

/// Thread listesi — bottom nav "Mesajlar" tab'ında kullanılır.
@riverpod
Future<List<MessageThread>> threadsList(Ref ref) async {
  final repo = ref.watch(messagesRepositoryProvider);
  final result = await repo.fetchThreads();
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Toplam okunmamış mesaj sayısı — alt tab'da badge için.
@riverpod
Future<int> unreadMessagesCount(Ref ref) async {
  final threads = await ref.watch(threadsListProvider.future);
  return threads.fold<int>(0, (sum, t) => sum + t.unreadCount);
}

/// Bir thread'in tüm mesajları, realtime stream.
@riverpod
Stream<List<Message>> threadMessages(Ref ref, String threadId) {
  final repo = ref.watch(messagesRepositoryProvider);
  return repo.watchMessages(threadId);
}

/// Mesaj göndermek için controller.
@riverpod
class SendMessageController extends _$SendMessageController {
  @override
  AsyncValue<Message?> build() => const AsyncValue.data(null);

  Future<bool> send({required String threadId, required String body}) async {
    if (body.trim().isEmpty) return false;
    state = const AsyncValue.loading();
    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.sendMessage(threadId: threadId, body: body.trim());
    return result.when(
      success: (m) {
        state = AsyncValue.data(m);
        ref.invalidate(threadsListProvider);
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}

/// Thread'in mesajlarını okundu işaretle.
@riverpod
class MarkThreadReadController extends _$MarkThreadReadController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> mark(String threadId) async {
    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.markThreadRead(threadId);
    result.when(
      success: (_) {
        ref.invalidate(threadsListProvider);
        ref.invalidate(unreadMessagesCountProvider);
      },
      failure: (_) {},
    );
  }
}
