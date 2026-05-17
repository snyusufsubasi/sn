import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../reviews/presentation/controllers/reviews_controller.dart';
import '../../../reviews/presentation/widgets/star_rating.dart';
import '../../data/models/user_profile.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: profileAsync.when(
        loading: () => const _ProfileSkeleton(),
        error: (e, _) => AppErrorView(message: e.toString()),
        data: (profile) {
          if (profile == null) {
            return const AppEmptyState(
              title: 'Profil bulunamadı',
              icon: Icons.person_off_outlined,
            );
          }
          return _ProfileContent(profile: profile);
        },
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsForUserProvider(profile.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card — avatar, isim, rol
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.ink100,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          _initials(profile.fullName),
                          style: const TextStyle(
                            color: AppColors.ink900,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AppBadge(
                            label: profile.isShipper ? 'Yükveren' : 'Nakliyeci',
                            backgroundColor: AppColors.ink100,
                            color: AppColors.ink700,
                          ),
                          const SizedBox(width: 6),
                          if (profile.isCompany)
                            const AppBadge(
                              label: 'Kurumsal',
                              backgroundColor: AppColors.ink100,
                              color: AppColors.ink700,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Rating + completed jobs özeti
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        profile.ratingAvg > 0
                            ? profile.ratingAvg.toStringAsFixed(1)
                            : '—',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      StarRating(
                        rating: profile.ratingAvg,
                        size: 14,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ortalama puan',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 56,
                  color: AppColors.ink100,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${profile.completedJobsCount}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.isShipper
                            ? 'Tamamlanan ilan'
                            : 'Tamamlanan taşıma',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hakkında
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Konum',
            value: '${profile.city}, ${profile.district}',
          ),
          if (profile.companyName != null)
            _InfoRow(
              icon: Icons.business_outlined,
              label: 'Şirket',
              value: profile.companyName!,
            ),
          if (profile.taxNumber != null)
            _InfoRow(
              icon: Icons.numbers,
              label: 'Vergi No',
              value: profile.taxNumber!,
            ),

          const SizedBox(height: 24),

          // Son değerlendirmeler özeti
          Text(
            'Son Değerlendirmeler',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          reviewsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AppLoading(),
            ),
            error: (e, _) => Text(e.toString()),
            data: (reviews) {
              if (reviews.isEmpty) {
                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Henüz değerlendirme yok',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink500,
                            ),
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: reviews
                    .take(3)
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      r.reviewerName ?? 'Anonim',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const Spacer(),
                                    StarRating(
                                      rating: r.rating.toDouble(),
                                      size: 14,
                                    ),
                                  ],
                                ),
                                if (r.comment != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    r.comment!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 32),

          // Ayarlar
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.edit_outlined,
                  label: 'Profili düzenle',
                  onTap: () => context.push(
                    '/profile/edit',
                    extra: profile,
                  ),
                ),
                const Divider(height: 1, color: AppColors.ink100),
                _SettingsRow(
                  icon: Icons.policy_outlined,
                  label: 'Kullanım Koşulları',
                  onTap: () => context.push('/legal/terms'),
                ),
                const Divider(height: 1, color: AppColors.ink100),
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Gizlilik / KVKK',
                  onTap: () => context.push('/legal/privacy'),
                ),
                const Divider(height: 1, color: AppColors.ink100),
                _SettingsRow(
                  icon: Icons.help_outline,
                  label: 'Yardım & Destek',
                  onTap: () => context.push('/legal/help'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Çıkış
          AppButton(
            label: 'Çıkış Yap',
            variant: AppButtonVariant.secondary,
            icon: Icons.logout,
            onPressed: () => _confirmSignOut(context, ref),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'ARACIYOK',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.ink400,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 16),
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

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yap?'),
        content: const Text('Hesabından çıkış yapmak istediğinden emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(authControllerProvider.notifier).signOut();
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const AppSkeletonAvatar(radius: 32),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 160, height: 18, radius: AppRadius.sm),
                    const SizedBox(height: 8),
                    AppSkeleton(width: 100, height: 13, radius: AppRadius.sm),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppSkeletonCard(height: 120),
          const SizedBox(height: AppSpacing.md),
          const AppSkeletonCard(height: 80),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.ink500),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.ink500, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.ink700),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.ink400,
            ),
          ],
        ),
      ),
    );
  }
}
