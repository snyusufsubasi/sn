import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/routing/job_routes.dart';
import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/theme/motion/app_curves.dart';
import '../../../../core/theme/motion/app_duration.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/mini_route_widget.dart';
import '../../../offers/data/models/offer.dart';
import '../../../offers/presentation/controllers/offers_controller.dart';
import '../../../offers/presentation/screens/create_offer_sheet.dart';
import '../../../offers/presentation/widgets/offer_card.dart';
import '../../../offers/presentation/widgets/operation_actions.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/job_post.dart';
import '../controllers/jobs_controller.dart';
import '../widgets/job_status_badge.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({
    required this.jobId,
    this.forceDetailView = false,
    super.key,
  });

  final String jobId;
  final bool forceDetailView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));
    final profileAsync = ref.watch(currentProfileProvider);

    return jobAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('İlan')),
        body: const _JobDetailSkeleton(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('İlan')),
        body: AppErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(jobDetailProvider(jobId)),
        ),
      ),
      data: (job) {
        if (job == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('İlan')),
            body: const AppEmptyState(
              icon: Icons.search_off,
              title: 'İlan bulunamadı',
            ),
          );
        }
        if (!forceDetailView && shouldOpenShipmentFlow(job.status)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/jobs/${job.id}/flow');
            }
          });
          return Scaffold(
            appBar: AppBar(title: const Text('İlan')),
            body: const AppLoading(),
          );
        }
        return profileAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('İlan')),
            body: const AppLoading(),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('İlan')),
            body: AppErrorView(message: e.toString()),
          ),
          data: (profile) {
            if (profile == null) return const SizedBox.shrink();
            return Scaffold(
              appBar: AppBar(title: const Text('İlan')),
              body: _JobDetailContent(job: job, viewer: profile),
              bottomNavigationBar: job.status.isOpen
                  ? _JobBottomBar(job: job, viewer: profile)
                  : null,
            );
          },
        );
      },
    );
  }
}

class _JobDetailContent extends ConsumerWidget {
  const _JobDetailContent({required this.job, required this.viewer});

  final JobPost job;
  final UserProfile viewer;

  bool get _isOwner => job.shipperId == viewer.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDetails = job.status.detailsRevealed && !_isOwner;
    // Yükveren ilan sahibi olduğu için her zaman görür; nakliyeci sadece
    // teklif kabul edildikten sonra görür.
    final canSeeFullDetails = _isOwner || showDetails || _isAcceptedCarrier;

    return RefreshIndicator(
      color: Color(AppPalette.ink900),
      onRefresh: () async => ref.invalidate(jobDetailProvider(job.id)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCard(job: job)
                .animate()
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 12),
            _RouteCard(job: job, showDetails: canSeeFullDetails)
                .animate()
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 12),
            _CargoCard(job: job)
                .animate(delay: const Duration(milliseconds: 100))
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideY(begin: 0.05, end: 0),
            if (job.budgetMin != null || job.budgetMax != null) ...[
              const SizedBox(height: 12),
              _BudgetCard(job: job)
                  .animate(delay: const Duration(milliseconds: 200))
                  .fadeIn(
                      duration: AppDuration.normal, curve: AppCurves.decelerate)
                  .slideY(begin: 0.05, end: 0),
            ],
            const SizedBox(height: AppSpacing.xxl),

            // Faz 5: Aksiyon bölgesi — duruma göre operasyon aksiyonları
            // veya teklif listesi/ver butonu
            OperationActions(job: job, viewer: viewer),

            if (job.status.detailsRevealed &&
                job.status != JobStatus.cancelled) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                color: Color(AppPalette.ink50),
                borderColor: Color(AppPalette.ink200),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: Color(AppPalette.ink900),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.offerZeroCommissionNote,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Faz 9: Canlı takip butonu — yük alınmış/yolda/teslim bekliyor
            if (job.status == JobStatus.loaded ||
                job.status == JobStatus.onRoad ||
                job.status == JobStatus.deliveryApproval) ...[
              AppButton(
                label: 'Canlı Takip',
                variant: AppButtonVariant.secondary,
                icon: Icons.map_outlined,
                onPressed: () => context.push('/jobs/${job.id}/track'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Teklifler bölümü
            _OffersSection(job: job, viewer: viewer)
                .animate(delay: const Duration(milliseconds: 300))
                .fadeIn(duration: AppDuration.normal, curve: AppCurves.decelerate)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            // İptal etme (sadece sahip, sadece open ise)
            if (_isOwner && job.status.isOpen) ...[
              AppButton(
                label: 'İlanı iptal et',
                variant: AppButtonVariant.danger,
                onPressed: () => _confirmCancel(context, ref),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }

  bool get _isAcceptedCarrier {
    if (job.acceptedOfferId == null) return false;
    if (!viewer.isCarrier) return false;
    // RLS zaten görünürlüğü garanti ediyor; carrier ise ve job artık open
    // değilse, kabul edilen teklifin sahibi yüksek olasılıkla bu kullanıcıdır.
    return !job.status.isOpen;
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İlanı iptal et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bu işlem geri alınamaz. Açık tüm teklifler de iptal edilir.',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: reasonController,
              hint: 'Sebep (opsiyonel)',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Color(AppPalette.red600)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('İptal et'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final success = await ref
        .read(cancelJobControllerProvider.notifier)
        .cancel(job.id, reasonController.text.trim());

    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlan iptal edildi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İptal başarısız')),
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.job});
  final JobPost job;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              JobStatusBadge(status: job.status),
              const Spacer(),
              Text(
                'İlan #${job.id.substring(0, 8)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Color(AppPalette.ink400)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
          if (job.description != null && job.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              job.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.job, required this.showDetails});

  final JobPost job;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Güzergah',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 12),
          MiniRouteWidget(
            originCity: job.originCity,
            originDistrict: job.originDistrict,
            destinationCity: job.destinationCity,
            destinationDistrict: job.destinationDistrict,
            compact: false,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.straighten, size: 16, color: Color(AppPalette.ink500)),
              const SizedBox(width: 6),
              Text(
                '~450 km',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppPalette.ink600),
                ),
              ),
              const Spacer(),
              const Icon(Icons.event, size: 16, color: Color(AppPalette.ink500)),
              const SizedBox(width: 6),
              Text(
                'Yükleme: ${Formatters.date(job.pickupDate)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (job.deliveryDate != null) ...[
                const SizedBox(width: 16),
                const Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: Color(AppPalette.ink500),
                ),
                const SizedBox(width: 6),
                Text(
                  'Teslim: ${Formatters.date(job.deliveryDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          if (!showDetails && !job.status.isCancelled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Color(AppPalette.ink50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Color(AppPalette.ink600)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Açık adres teklif kabul edilince görünür',
                      style: TextStyle(fontSize: 12, color: Color(AppPalette.ink600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CargoCard extends StatelessWidget {
  const _CargoCard({required this.job});
  final JobPost job;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yük Bilgileri',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Ağırlık', value: Formatters.weight(job.weightTons)),
          if (job.volumeM3 != null) ...[
            const SizedBox(height: 8),
            _InfoRow(label: 'Hacim', value: '${job.volumeM3!.toStringAsFixed(0)} m³'),
          ],
          if (job.preferredTrailerType != null) ...[
            const SizedBox(height: 8),
            _InfoRow(label: 'Kasa tipi', value: job.preferredTrailerType!),
          ],
          if (job.description != null && job.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(label: 'Açıklama', value: job.description!),
          ],
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.job});
  final JobPost job;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: Color(AppPalette.ink50),
      borderColor: Color(AppPalette.ink100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bütçe',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (job.budgetMin != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Min',
                      style: TextStyle(fontSize: 11, color: Color(AppPalette.ink500)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.currency(job.budgetMin!),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (job.budgetMin != null && job.budgetMax != null) ...[
                const SizedBox(width: 24),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '—',
                    style: TextStyle(fontSize: 18, color: Color(AppPalette.ink400)),
                  ),
                ),
                const SizedBox(width: 24),
              ],
              if (job.budgetMax != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maks',
                      style: TextStyle(fontSize: 11, color: Color(AppPalette.ink500)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.currency(job.budgetMax!),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(AppPalette.ink500),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Teklif bölümü — duruma göre değişen içerik.
class _OffersSection extends ConsumerWidget {
  const _OffersSection({required this.job, required this.viewer});
  final JobPost job;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShipper = viewer.id == job.shipperId;

    if (isShipper) {
      return _ShipperOffersList(job: job);
    }
    return _CarrierOfferSection(job: job, viewer: viewer);
  }
}

class _ShipperOffersList extends ConsumerWidget {
  const _ShipperOffersList({required this.job});
  final JobPost job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersForJobProvider(job.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Teklifler',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        offersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: AppLoading(),
          ),
          error: (e, _) => Text(e.toString()),
          data: (offers) {
            if (offers.isEmpty) {
              return const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Henüz teklif yok',
                      style: TextStyle(color: Color(AppPalette.ink500)),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: offers
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OfferCard(
                          offer: o,
                          showShipperActions: job.status.isOpen &&
                              o.status == OfferStatus.pending,
                          jobBudgetMin: job.budgetMin,
                          jobBudgetMax: job.budgetMax,
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CarrierOfferSection extends ConsumerWidget {
  const _CarrierOfferSection({required this.job, required this.viewer});
  final JobPost job;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOfferAsync = ref.watch(myOfferForJobProvider(job.id));

    return myOfferAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Text(e.toString()),
      data: (offer) {
        if (offer == null) {
          if (!job.status.isOpen) {
            return const SizedBox.shrink();
          }
          return AppButton(
            label: 'Teklif Ver',
            onPressed: () => showCreateOfferSheet(context, job: job),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Senin teklifin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            OfferCard(
              offer: offer,
              showCarrierActions: offer.status == OfferStatus.pending,
              jobBudgetMin: job.budgetMin,
              jobBudgetMax: job.budgetMax,
            ),
          ],
        );
      },
    );
  }
}

class _JobDetailSkeleton extends StatelessWidget {
  const _JobDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: const Column(
        children: [
          AppSkeletonCard(height: 110),
          SizedBox(height: 12),
          AppSkeletonCard(height: 140),
          SizedBox(height: 12),
          AppSkeletonCard(height: 100),
          SizedBox(height: 12),
          AppSkeletonCard(height: 80),
        ],
      ),
    );
  }
}

/// Sabit alt çubuk — sadece ilan açıkken gösterilir.
class _JobBottomBar extends ConsumerWidget {
  const _JobBottomBar({required this.job, required this.viewer});

  final JobPost job;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShipper = viewer.id == job.shipperId;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: const Color(AppPalette.ink200)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: isShipper
            ? AppButton(
                label: 'Teklifleri Gör',
                icon: Icons.list_alt,
                onPressed: () {},
              )
            : Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Mesaj',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.chat_outlined,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Teklif Ver',
                      variant: AppButtonVariant.accent,
                      onPressed: () => showCreateOfferSheet(context, job: job),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
