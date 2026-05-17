import 'package:flutter/material.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/mini_route_widget.dart';
import '../../data/models/job_post.dart';
import 'job_status_badge.dart';

/// İlan kartı — MiniRouteWidget ile yeniden tasarlanmış.
///
/// compact=false (varsayılan):
/// ```text
/// [Açık]                        2 dk önce
/// Tekstil Yükü — İstanbul -> Ankara
/// ● İstanbul, Pendik
/// ║
/// 📍 Ankara, Çankaya
/// [⚖️ 22,5 ton] [📅 16 May 2026]    [15.000 ₺]
/// ```
///
/// compact=true: tek satır
/// ```text
/// ● İstanbul → 📍 Ankara | Tekstil | 22,5 ton | 15.000 ₺
/// ```
class JobCard extends StatelessWidget {
  const JobCard({
    required this.job,
    required this.onTap,
    this.offerCount,
    this.compact = false,
    super.key,
  });

  final JobPost job;
  final VoidCallback onTap;
  final int? offerCount;
  final bool compact;

  bool get _isPriorityJob =>
      job.status == JobStatus.offerAccepted ||
      job.status == JobStatus.pickupApproval ||
      job.status == JobStatus.loaded ||
      job.status == JobStatus.onRoad ||
      job.status == JobStatus.deliveryApproval;

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);

    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Üst satır: StatusBadge + createdAt ──────────────────
          Row(
            children: [
              JobStatusBadge(status: job.status),
              if (_isPriorityJob) ...[
                const SizedBox(width: 8),
                const _PriorityChip(),
              ],
              const Spacer(),
              Text(
                Formatters.relative(job.createdAt),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: const Color(AppPalette.ink600)),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Başlık ─────────────────────────────────────────────
          Text(
            job.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(AppPalette.ink900),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Rota: MiniRouteWidget (compact=false) ──────────────
          MiniRouteWidget(
            originCity: job.originCity,
            destinationCity: job.destinationCity,
            originDistrict: job.originDistrict,
            destinationDistrict: job.destinationDistrict,
            compact: false,
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Meta satırı: 3 sütun ────────────────────────────────
          Row(
            children: [
              _MetaItem(
                icon: Icons.scale,
                label: Formatters.weight(job.weightTons),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MetaItem(
                icon: Icons.event,
                label: Formatters.date(job.pickupDate),
              ),
              const Spacer(),
              if (job.budgetMax != null || job.budgetMin != null)
                _BudgetBadge(label: _budgetLabel()),
            ],
          ),

          // ── Teklif sayısı (opsiyonel) ─────────────────────────
          if (offerCount != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 14, color: Color(AppPalette.ink500)),
                const SizedBox(width: 4),
                Text(
                  '$offerCount teklif',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(AppPalette.ink500),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Dar mod: tek satır "● İstanbul → 📍 Ankara | Tekstil | 22t | 15K ₺"
  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          MiniRouteWidget(
            originCity: job.originCity,
            destinationCity: job.destinationCity,
            compact: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Kargo tipi etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(AppPalette.ink100),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              job.cargoType,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(AppPalette.ink700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Ağırlık
          Text(
            Formatters.weight(job.weightTons),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(AppPalette.ink800),
            ),
          ),
          const Spacer(),
          // Bütçe
          if (job.budgetMax != null || job.budgetMin != null)
            Text(
              _budgetLabel(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(AppPalette.ink900),
              ),
            ),
        ],
      ),
    );
  }

  String _budgetLabel() {
    if (job.budgetMin != null && job.budgetMax != null) {
      return '${Formatters.currency(job.budgetMin!)}'
          ' - ${Formatters.currency(job.budgetMax!)}';
    }
    if (job.budgetMax != null) return Formatters.currency(job.budgetMax!);
    if (job.budgetMin != null) return Formatters.currency(job.budgetMin!);
    return '';
  }
}

/// Meta sütun öğesi — ağırlık, tarih gibi bilgiler için pill.
class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(AppPalette.white),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(AppPalette.ink200)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(AppPalette.ink700)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppPalette.ink800),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Bütçe rozeti — siyah zemin üzerine beyaz yazı.
class _BudgetBadge extends StatelessWidget {
  const _BudgetBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(AppPalette.ink900),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(AppPalette.white),
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// Öncelikli işlem etiketi.
class _PriorityChip extends StatelessWidget {
  const _PriorityChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(AppPalette.ink100),
        border: Border.all(color: const Color(AppPalette.ink300)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Öncelikli',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(AppPalette.ink900),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
