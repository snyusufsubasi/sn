import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/message_thread.dart';
import '../controllers/messages_controller.dart';

class ThreadsListScreen extends ConsumerWidget {
  const ThreadsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsListProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMessages)),
      body: RefreshIndicator(
        color: AppColors.ink900,
        onRefresh: () async => ref.invalidate(threadsListProvider),
        child: threadsAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(threadsListProvider),
          ),
          data: (threads) {
            if (threads.isEmpty) {
              return ListView(children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                AppEmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: l10n.msgEmpty,
                  subtitle: l10n.msgEmptySubtitle,
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.md,
              ),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ThreadRow(thread: threads[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.thread});
  final MessageThread thread;

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;
    return AppCard(
      onTap: () => GoRouter.of(context).push(
        '/messages/${thread.id}',
        extra: thread,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.ink100,
            child: Text(
              _initials(thread.counterpartName ?? '?'),
              style: const TextStyle(
                color: AppColors.ink900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        thread.counterpartName ?? 'Bilinmeyen',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (thread.lastMessageAt != null)
                      Text(
                        Formatters.relative(thread.lastMessageAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: hasUnread
                                  ? AppColors.ink900
                                  : AppColors.ink500,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                if (thread.jobTitle != null)
                  Text(
                    thread.jobTitle!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.ink500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        thread.lastMessageBody ?? 'Henüz mesaj yok',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: hasUnread
                                      ? AppColors.ink900
                                      : AppColors.ink500,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.ink900,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        child: Text(
                          '${thread.unreadCount}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }
}
