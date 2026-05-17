import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/theme/motion/app_curves.dart';
import '../../../../core/theme/motion/app_duration.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../offers/data/models/offer.dart';
import '../../../offers/presentation/controllers/offers_controller.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../reviews/presentation/controllers/reviews_controller.dart';
import '../../../reviews/presentation/screens/create_review_sheet.dart';
import '../../data/models/job_post.dart';
import '../../domain/shipment_flow_step.dart';
import '../controllers/jobs_controller.dart';
import '../widgets/job_status_badge.dart';
import '../widgets/shipment_route_preview.dart';
import '../widgets/shipment_timeline.dart';

class ShipmentFlowScreen extends ConsumerWidget {
  const ShipmentFlowScreen({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));
    final profileAsync = ref.watch(currentProfileProvider);
    final reviewedAsync = ref.watch(hasReviewedJobProvider(jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Taşıma akışı')),
      body: jobAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(jobDetailProvider(jobId)),
        ),
        data: (job) {
          if (job == null) {
            return const AppEmptyState(
              icon: Icons.search_off,
              title: 'İlan bulunamadı',
            );
          }
          return profileAsync.when(
            loading: () => const AppLoading(),
            error: (e, _) => AppErrorView(message: e.toString()),
            data: (profile) {
              if (profile == null) return const SizedBox.shrink();
              return reviewedAsync.when(
                loading: () => const AppLoading(),
                error: (_, __) => _FlowBody(
                  job: job,
                  viewer: profile,
                  hasReviewed: false,
                ),
                data: (hasReviewed) => _FlowBody(
                  job: job,
                  viewer: profile,
                  hasReviewed: hasReviewed,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FlowBody extends ConsumerWidget {
  const _FlowBody({
    required this.job,
    required this.viewer,
    required this.hasReviewed,
  });

  final JobPost job;
  final UserProfile viewer;
  final bool hasReviewed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Offer? acceptedOffer;
    final offers = ref.watch(offersForJobProvider(job.id)).valueOrNull;
    if (offers != null) {
      for (final o in offers) {
        if (o.isAccepted) {
          acceptedOffer = o;
          break;
        }
      }
    }

    final model = buildShipmentFlowModel(
      job: job,
      viewer: viewer,
      acceptedOffer: acceptedOffer,
      hasReviewed: hasReviewed,
    );

    final actionsState = ref.watch(offerActionsControllerProvider);
    final isBusy = actionsState.isLoading;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: const Color(AppPalette.ink900),
            onRefresh: () async {
              ref.invalidate(jobDetailProvider(job.id));
              ref.invalidate(hasReviewedJobProvider(job.id));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.lg,
              ),
              children: [
                Row(
                  children: [
                    JobStatusBadge(status: job.status),
                    const Spacer(),
                    if (model.showTrackingPreview)
                      TextButton.icon(
                        onPressed: () => context.push('/jobs/${job.id}/track'),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Harita'),
                      ),
                    TextButton(
                      onPressed: () =>
                          context.push('/jobs/${job.id}?view=detail'),
                      child: const Text('Tüm bilgiler'),
                    ),
                    TextButton(
                      onPressed: () => context.push('/jobs/${job.id}/payment'),
                      child: const Text('Ödeme'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(AppPalette.ink900),
                      ),
                ),
                Text(
                  job.route,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppPalette.ink700),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _NextActionCard(
                  model: model,
                  onTap: model.showTrackingPreview &&
                          model.ctaType != ShipmentFlowCtaType.confirmPickup &&
                          model.ctaType !=
                              ShipmentFlowCtaType.confirmDelivery &&
                          model.ctaType != ShipmentFlowCtaType.startRoad
                      ? () => context.push('/jobs/${job.id}/track')
                      : null,
                ),
                const SizedBox(height: 16),
                if (model.showTrackingPreview) ...[
                  ShipmentRoutePreview(job: job),
                  const SizedBox(height: 16),
                ],
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: model.progress.clamp(0.05, 1.0),
                  ),
                  duration: AppDuration.slow,
                  curve: AppCurves.emphasize,
                  builder: (_, value, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 4,
                      backgroundColor: const Color(AppPalette.ink100),
                      color: const Color(AppPalette.ink900),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShipmentTimeline(steps: model.steps),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _BottomBar(
          model: model,
          job: job,
          isBusy: isBusy,
          revieweeName: _counterpartName(
            ref.watch(offersForJobProvider(job.id)).valueOrNull,
            viewer,
          ),
        ),
      ],
    );
  }

  String _counterpartName(List<Offer>? offers, UserProfile viewer) {
    if (viewer.isShipper) {
      if (offers != null) {
        for (final o in offers) {
          if (o.isAccepted) {
            return o.carrierName ?? 'Nakliyeci';
          }
        }
      }
      return 'Nakliyeci';
    }
    return 'Yükveren';
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.model,
    required this.job,
    required this.isBusy,
    required this.revieweeName,
  });

  final ShipmentFlowModel model;
  final JobPost job;
  final bool isBusy;
  final String revieweeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        12,
        AppSpacing.pageHorizontal,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: const Color(AppPalette.white),
        border: Border(top: BorderSide(color: const Color(AppPalette.ink200))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (model.ctaType != ShipmentFlowCtaType.none &&
              model.ctaLabel != null)
            AppButton(
              label: model.ctaLabel!,
              loading: isBusy,
              onPressed:
                  isBusy ? null : () => _onCta(context, ref, model.ctaType),
            )
          else if (model.ctaLabel != null)
            Text(
              model.ctaLabel!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: const Color(AppPalette.ink700),
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (model.showTrackingPreview) ...[
                Expanded(
                  child: AppButton(
                    label: 'Harita',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.map_outlined,
                    onPressed: () => context.push('/jobs/${job.id}/track'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: AppButton(
                  label: 'Mesajlar',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => context.go('/messages'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Ödeme Durumu',
            variant: AppButtonVariant.secondary,
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () => context.push('/jobs/${job.id}/payment'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCta(
    BuildContext context,
    WidgetRef ref,
    ShipmentFlowCtaType type,
  ) async {
    final notifier = ref.read(offerActionsControllerProvider.notifier);
    late final Future<bool> Function() action;
    switch (type) {
      case ShipmentFlowCtaType.confirmPickup:
        action = () => notifier.confirmPickup(job.id);
      case ShipmentFlowCtaType.startRoad:
        action = () => notifier.startRoad(job.id);
      case ShipmentFlowCtaType.confirmDelivery:
        action = () => notifier.confirmDelivery(job.id);
      case ShipmentFlowCtaType.openTracking:
        if (context.mounted) {
          await context.push('/jobs/${job.id}/track');
        }
        return;
      case ShipmentFlowCtaType.openPayment:
        if (context.mounted) {
          await context.push('/jobs/${job.id}/payment');
        }
        return;
      case ShipmentFlowCtaType.openReview:
        final revieweeId = model.revieweeId;
        if (revieweeId == null) return;
        final done = await showCreateReviewSheet(
          context,
          jobPostId: job.id,
          revieweeId: revieweeId,
          revieweeName: revieweeName,
        );
        if (done ?? false) {
          ref.invalidate(hasReviewedJobProvider(job.id));
          ref.invalidate(jobDetailProvider(job.id));
        }
        return;
      case ShipmentFlowCtaType.none:
        return;
    }

    final ok = await action();
    if (!context.mounted) return;
    if (ok) {
      ref.invalidate(jobDetailProvider(job.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncellendi')),
      );
    }
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.model,
    this.onTap,
  });

  final ShipmentFlowModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = model.ctaLabel ?? 'Süreç güncel';
    final subtitle = switch (model.ctaType) {
      ShipmentFlowCtaType.confirmPickup => 'Sıradaki adım: yük alımını onayla.',
      ShipmentFlowCtaType.startRoad => 'Sıradaki adım: yola çıkışı bildir.',
      ShipmentFlowCtaType.openTracking =>
        'Sıradaki adım: canlı haritadan takip et.',
      ShipmentFlowCtaType.confirmDelivery => 'Sıradaki adım: teslimatı onayla.',
      ShipmentFlowCtaType.openPayment =>
        'Sıradaki adım: ödemeyi tamamla.',
      ShipmentFlowCtaType.openReview =>
        'Sıradaki adım: taşıma değerlendirmesi bırak.',
      ShipmentFlowCtaType.none =>
        'Süreç otomatik ilerliyor, güncellemeleri takip et.',
    };

    return AppCard(
      color: const Color(AppPalette.ink50),
      borderColor: const Color(AppPalette.ink100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: const Color(AppPalette.ink900)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppPalette.ink600),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: const Color(AppPalette.ink500),
              ),
            ),
        ],
      ),
    );
  }
}
