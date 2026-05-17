import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/job_routes.dart';
import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/theme/app_dimens.dart' show AppDuration, AppMotion;
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart' hide AppRadius;
import '../../../../core/widgets/app_scaffold.dart';
import '../../../jobs/data/models/job_post.dart';
import '../../../jobs/presentation/controllers/jobs_controller.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../widgets/payment_pending_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(message: e.toString()),
          data: (profile) {
            if (profile == null) return const SizedBox.shrink();
            return profile.isShipper
                ? _ShipperHome(profile: profile)
                : _CarrierHome(profile: profile);
          },
        ),
      ),
    );
  }
}

class _ShipperHome extends ConsumerWidget {
  const _ShipperHome({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myJobsAsync = ref.watch(myJobsProvider);
    final activeJobsAsync = ref.watch(myInProgressShipperJobsProvider);
    final totalJobs = myJobsAsync.valueOrNull?.length ?? 0;
    final activeJobs = activeJobsAsync.valueOrNull?.length ?? 0;
    final paymentPending = activeJobsAsync.valueOrNull
            ?.where((j) => j.status == JobStatus.awaitingPayment)
            .toList() ??
        [];

    return RefreshIndicator(
      color: Color(AppPalette.ink900),
      onRefresh: () async => ref.invalidate(myJobsProvider),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          _Greeting(name: profile.fullName)
              .animate()
              .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance)
              .slideY(begin: -0.05, end: 0),
          const SizedBox(height: AppSpacing.md),
          const _GreetingHint(
                  text: 'İlanlarını yönet, aktif taşımanı takip et.')
              .animate(delay: const Duration(milliseconds: 60))
              .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance),
          const SizedBox(height: AppSpacing.lg),
          _HomeHeroBand(
            title: 'Bugünkü durum',
            subtitle: 'Operasyon merkezin',
            primaryLabel: 'Aktif taşıma',
            primaryValue: activeJobs.toString(),
            secondaryLabel: 'Toplam ilan',
            secondaryValue: totalJobs.toString(),
            hint: activeJobs > 0
                ? 'Devam eden taşımalara öncelik ver.'
                : 'Yeni ilan açarak teklif toplamayı hızlandır.',
          )
              .animate(delay: const Duration(milliseconds: 120))
              .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance)
              .scaleXY(begin: 0.97, end: 1.0),
          const SizedBox(height: AppSpacing.lg),
          PaymentPendingBanner(jobs: paymentPending),
          _QuickActionsSection(
            isCarrier: false,
            onAldigimIsler: () => context.push('/jobs/new'),
            onYaptigimIsler: () => context.go('/jobs'),
            onTekliflerim: null,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Hızlı aksiyon
          AppCard(
            color: Color(AppPalette.ink50),
            borderColor: Color(AppPalette.ink200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yeni bir ilan oluştur',
                  style: TextStyle(
                    color: Color(AppPalette.ink900),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Yüklerini hızlıca ilan et, teklifleri karşılaştır.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Color(AppPalette.ink700),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'İlan Oluştur',
                  variant: AppButtonVariant.primary,
                  icon: Icons.add,
                  size: AppButtonSize.medium,
                  onPressed: () => context.push('/jobs/new'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          activeJobsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (jobs) {
              if (jobs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeSectionHeader(
                    title: 'Devam eden taşımaların',
                    subtitle: 'En kritik operasyonlar',
                    actionLabel: 'Hepsi',
                    onAction: () => context.go('/jobs'),
                  ),
                  ...jobs.take(2).map(
                        (j) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
                          child: JobCard(
                            job: j,
                            onTap: () => context.push(jobDestinationPath(j)),
                          ),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),
          myJobsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: AppLoading(),
            ),
            error: (e, _) => AppErrorView(message: e.toString()),
            data: (jobs) {
              if (jobs.isEmpty) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(AppPalette.ink500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Henüz ilanın yok',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'İlk ilanını oluştur, nakliyecilerden teklif '
                        'almaya başla.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: jobs.take(3).indexed.map((entry) {
                  final index = entry.$1;
                  final j = entry.$2;
                  return Column(
                    children: [
                      if (index == 0)
                        _HomeSectionHeader(
                          title: 'Son ilanların',
                          subtitle: 'Hızlıca açıp işlem yap',
                          actionLabel: 'Tümü',
                          onAction: () => context.go('/jobs'),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
                        child: JobCard(
                          job: j,
                          onTap: () => context.push(jobDestinationPath(j)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CarrierHome extends ConsumerWidget {
  const _CarrierHome({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openJobsAsync = ref.watch(openJobsProvider(const JobFilter()));
    final activeAsync = ref.watch(myActiveCarrierJobsProvider);
    final activeCount = activeAsync.valueOrNull?.length ?? 0;
    final openCount = openJobsAsync.valueOrNull?.length ?? 0;
    final paymentPending = activeAsync.valueOrNull
            ?.where((j) => j.status == JobStatus.awaitingPayment)
            .toList() ??
        [];

    return RefreshIndicator(
      color: Color(AppPalette.ink900),
      onRefresh: () async {
        ref.invalidate(openJobsProvider);
        ref.invalidate(myActiveCarrierJobsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          _Greeting(name: profile.fullName)
              .animate()
              .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance)
              .slideY(begin: -0.05, end: 0),
          const SizedBox(height: AppSpacing.md),
          const _GreetingHint(
                  text: 'Aktif taşımanı yönet, uygun yükleri yakala.')
              .animate(delay: const Duration(milliseconds: 60))
              .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance),
          const SizedBox(height: AppSpacing.lg),
          _HomeHeroBand(
            title: 'Bugünkü fırsatlar',
            subtitle: 'Nakliye paneli',
            primaryLabel: 'Aktif taşıma',
            primaryValue: activeCount.toString(),
            secondaryLabel: 'Açık ilan',
            secondaryValue: openCount.toString(),
            hint: openCount > 0
                ? 'Uygun ilanları kaçırmadan teklif ver.'
                : 'Yeni ilanlar için filtrelerini güncelle.',
          )
              .animate(delay: const Duration(milliseconds: 120))
              .fadeIn(duration: AppDuration.base, curve: AppMotion.entrance)
              .scaleXY(begin: 0.97, end: 1.0),
          const SizedBox(height: AppSpacing.lg),
          PaymentPendingBanner(jobs: paymentPending),
          _QuickActionsSection(
            isCarrier: true,
            onAldigimIsler: () => context.go('/jobs?tab=active'),
            onYaptigimIsler: () => context.go('/jobs?tab=completed'),
            onTekliflerim: () => context.go('/offers/my'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            color: Color(AppPalette.ink50),
            borderColor: Color(AppPalette.ink200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bugün yeni yük bul',
                  style: TextStyle(
                    color: Color(AppPalette.ink900),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Şehir ve yük tipine göre filtreleyip hemen teklif ver.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Color(AppPalette.ink700),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'İlanlara Git',
                        variant: AppButtonVariant.primary,
                        onPressed: () => context.go('/jobs'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Filtrele',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.go('/jobs'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Aktif taşımalar
          activeAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (jobs) {
              if (jobs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeSectionHeader(
                    title: 'Aktif taşımaların',
                    subtitle: 'Önce bunları tamamla',
                    actionLabel: 'Hepsi',
                    onAction: () => context.go('/jobs'),
                  ),
                  ...jobs.take(2).map(
                        (j) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
                          child: JobCard(
                            job: j,
                            onTap: () => context.push(jobDestinationPath(j)),
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),

          _HomeSectionHeader(
            title: 'Önerilen ilanlar',
            subtitle: 'Sana uygun açık ilanlar',
            actionLabel: 'Tümü',
            onAction: () => context.go('/jobs'),
          ),
          openJobsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: AppLoading(),
            ),
            error: (e, _) => AppErrorView(message: e.toString()),
            data: (jobs) {
              if (jobs.isEmpty) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(AppPalette.ink500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Açık ilan yok',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Şu an için açık bir ilan bulamadık. '
                        'Birazdan tekrar dene.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: jobs
                    .take(3)
                    .indexed
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
                          child: JobCard(
                            job: entry.$2,
                            onTap: () =>
                                context.push(jobDestinationPath(entry.$2)),
                          )
                              .animate(
                                delay: Duration(
                                    milliseconds: entry.$1 < 5
                                        ? entry.$1 * 40
                                        : 200),
                              )
                              .fadeIn(
                                duration: AppDuration.base,
                                curve: AppMotion.entrance,
                              )
                              .slideX(begin: 0.05, end: 0),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.isCarrier,
    required this.onAldigimIsler,
    required this.onYaptigimIsler,
    required this.onTekliflerim,
  });

  final bool isCarrier;
  final VoidCallback? onAldigimIsler;
  final VoidCallback? onYaptigimIsler;
  final VoidCallback? onTekliflerim;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı işlemler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Color(AppPalette.ink900),
              ),
        ),
        const SizedBox(height: 10),
        _QuickActionTile(
          title: isCarrier ? 'Aldığım işler' : 'Yeni İlan Oluştur',
          subtitle: isCarrier
              ? 'Aktif taşıma süreçlerini aç'
              : 'Hızlıca yeni bir yük ilanı aç',
          icon: isCarrier
              ? Icons.assignment_turned_in_outlined
              : Icons.add_circle_outline,
          onTap: onAldigimIsler,
        ),
        const SizedBox(height: 8),
        _QuickActionTile(
          title: isCarrier ? 'Yaptığım işler' : 'İlanlarım',
          subtitle: isCarrier
              ? 'Tamamlanan taşıma geçmişin'
              : 'Tüm ilanlarını ve durumlarını gör',
          icon: isCarrier ? Icons.history_toggle_off : Icons.list_alt_outlined,
          onTap: onYaptigimIsler,
        ),
        if (isCarrier) ...[
          const SizedBox(height: 8),
          _QuickActionTile(
            title: 'Tekliflerim',
            subtitle: 'Verdiğin tüm teklifleri görüntüle',
            icon: Icons.local_offer_outlined,
            onTap: onTekliflerim,
          ),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Color(AppPalette.transparent),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: enabled ? Color(AppPalette.white) : Color(AppPalette.ink50),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? Color(AppPalette.ink200) : Color(AppPalette.ink100),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      enabled ? Color(AppPalette.ink900) : Color(AppPalette.ink300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Color(AppPalette.white),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Color(AppPalette.ink900),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Color(AppPalette.ink600),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.arrow_forward_ios : Icons.lock_outline,
                size: 16,
                color: enabled ? Color(AppPalette.ink500) : Color(AppPalette.ink400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;

  String _hello() {
    final h = DateTime.now().hour;
    if (h < 6) return 'İyi geceler';
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final first = name.trim().split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _hello(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Color(AppPalette.ink600),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          first,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Color(AppPalette.ink900),
              ),
        ),
      ],
    );
  }
}

class _GreetingHint extends StatelessWidget {
  const _GreetingHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Color(AppPalette.ink600),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(AppPalette.ink900),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Color(AppPalette.ink900),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(AppPalette.ink500),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeHeroBand extends StatelessWidget {
  const _HomeHeroBand({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.hint,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final String primaryValue;
  final String secondaryLabel;
  final String secondaryValue;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppPalette.navy800),
            const Color(AppPalette.navy700),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(AppPalette.white),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppPalette.white).withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: primaryLabel,
                  value: primaryValue,
                  emphasize: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroMetric(
                  label: secondaryLabel,
                  value: secondaryValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppPalette.white).withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasize
            ? const Color(AppPalette.white).withValues(alpha: 0.2)
            : const Color(AppPalette.white).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: emphasize
                      ? const Color(AppPalette.white).withValues(alpha: 0.85)
                      : const Color(AppPalette.white).withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(AppPalette.white),
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
          ),
        ],
      ),
    );
  }
}
