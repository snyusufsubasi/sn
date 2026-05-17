import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/message.dart';
import '../../data/models/message_thread.dart';
import '../controllers/messages_controller.dart';
import '../widgets/message_bubble.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({
    required this.threadId, super.key,
    this.thread,
  });

  final String threadId;
  final MessageThread? thread;

  @override
  ConsumerState<MessageThreadScreen> createState() =>
      _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _markedRead = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppDuration.fast,
        curve: AppMotion.entrance,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final ok = await ref
        .read(sendMessageControllerProvider.notifier)
        .send(threadId: widget.threadId, body: text);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj gönderilemedi')),
      );
      // restore the text so user can retry
      _controller.text = text;
    } else {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final messagesAsync =
        ref.watch(threadMessagesProvider(widget.threadId));
    final sendState = ref.watch(sendMessageControllerProvider);

    // Mesajlar yüklendiğinde otomatik okundu işaretle (sadece bir kez)
    ref.listen(threadMessagesProvider(widget.threadId), (_, next) {
      next.whenData((messages) {
        if (!_markedRead && messages.isNotEmpty) {
          _markedRead = true;
          ref
              .read(markThreadReadControllerProvider.notifier)
              .mark(widget.threadId);
        }
        _scrollToBottom();
      });
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _AppBarTitle(thread: widget.thread),
        actions: [
          if (widget.thread != null)
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined),
              tooltip: 'İlana git',
              onPressed: () =>
                  context.push('/jobs/${widget.thread!.jobPostId}'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppErrorView(message: e.toString()),
              data: (messages) {
                if (messages.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Mesajlaşmaya başla',
                    subtitle:
                        'İlk mesajı sen yaz; yük ve teslimat hakkında konuşun.',
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMine = profile != null && m.senderId == profile.id;
                    final showDateHeader = _shouldShowDateHeader(messages, i);
                    final isRecent = i >= messages.length - 5;
                    final bubble = Column(
                      children: [
                        if (showDateHeader) _DateHeader(date: m.createdAt),
                        MessageBubble(message: m, isMine: isMine),
                      ],
                    );
                    if (!isRecent) return bubble;
                    return bubble
                        .animate(
                          delay: Duration(
                              milliseconds:
                                  (messages.length - 1 - i).clamp(0, 4) * 30),
                        )
                        .fadeIn(
                          duration: AppDuration.fast,
                          curve: AppMotion.entrance,
                        )
                        .slideY(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
            isSending: sendState.isLoading,
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateHeader(List<Message> messages, int index) {
    if (index == 0) return true;
    final prev = messages[index - 1].createdAt;
    final cur = messages[index].createdAt;
    return prev.day != cur.day ||
        prev.month != cur.month ||
        prev.year != cur.year;
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({this.thread});
  final MessageThread? thread;

  @override
  Widget build(BuildContext context) {
    final name = thread?.counterpartName ?? 'Mesaj';
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.ink100,
          child: Text(
            _initials(name),
            style: const TextStyle(
              color: AppColors.ink900,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (thread?.jobTitle != null)
                Text(
                  thread!.jobTitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.ink500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});
  final DateTime date;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.ink50,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            Formatters.date(date),
            style: const TextStyle(fontSize: 11, color: AppColors.ink600),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.ink100)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  filled: true,
                  fillColor: AppColors.ink50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.ink200),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              duration: AppDuration.fast,
              opacity: (_hasText && !widget.isSending) ? 1.0 : 0.35,
              child: Material(
                color: AppColors.ink900,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: (widget.isSending || !_hasText) ? null : widget.onSend,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: widget.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.send,
                            color: AppColors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
