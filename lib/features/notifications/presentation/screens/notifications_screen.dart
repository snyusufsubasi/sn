import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../data/models/app_notification.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final unreadCount =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationActionsProvider.notifier).markAllRead(),
              child: Text(
                l10n.notificationsMarkAllRead,
                style: const TextStyle(color: AppColors.ink900),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.ink900,
        onRefresh: () async => ref.invalidate(notificationsListProvider),
        child: notificationsAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.md,
            ),
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              AppSkeletonListItem(),
              AppSkeletonListItem(),
              AppSkeletonListItem(),
            ],
          ),
          error: (e, _) => AppErrorView(message: e.toString()),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                AppEmptyState(
                  icon: Icons.notifications_none,
                  title: l10n.notificationsEmpty,
                  subtitle: l10n.notificationsEmptySubtitle,
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.md,
              ),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _NotificationRow(
                notification: notifications[i],
                onTap: () => _onTap(context, ref, notifications[i]),
              )
                  .animate(
                    delay: Duration(milliseconds: i < 5 ? i * 40 : 200),
                  )
                  .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance)
                  .slideX(begin: 0.04, end: 0),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    // Önce okundu işaretle
    if (!n.isRead) {
      await ref.read(notificationActionsProvider.notifier).markRead(n.id);
    }
    // Sonra route
    if (!context.mounted) return;
    if (n.threadId != null) {
      unawaited(context.push('/messages/${n.threadId}'));
    } else if (n.jobPostId != null) {
      unawaited(context.push('/jobs/${n.jobPostId}'));
    }
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(notification.type);
    final isUnread = !notification.isRead;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.base,
        curve: AppMotion.standard,
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.ink50 : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.ink200),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
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
                        notification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      Formatters.relative(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.ink500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.ink900,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  (IconData, Color) _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newOffer:
        return (Icons.local_offer, AppColors.ink900);
      case NotificationType.offerAccepted:
        return (Icons.handshake, AppColors.ink700);
      case NotificationType.offerRejected:
        return (Icons.cancel_outlined, AppColors.error);
      case NotificationType.jobStatusChanged:
        return (Icons.local_shipping_outlined, AppColors.ink600);
      case NotificationType.newMessage:
        return (Icons.message_outlined, AppColors.ink900);
      case NotificationType.reviewReceived:
        return (Icons.star_outline, AppColors.star);
      case NotificationType.paymentReceived:
      case NotificationType.paymentPending:
        return (Icons.payments_outlined, AppColors.ink700);
      case NotificationType.paymentConfirmed:
        return (Icons.payments_outlined, AppColors.success);
      case NotificationType.disputeOpened:
        return (Icons.warning_amber_outlined, AppColors.warning);
      case NotificationType.system:
        return (Icons.notifications_none, AppColors.ink600);
    }
  }
}
