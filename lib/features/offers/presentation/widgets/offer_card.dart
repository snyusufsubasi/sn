import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/theme/dimensions/app_spacing.dart';
import '../../../../core/theme/motion/app_curves.dart';
import '../../../../core/theme/motion/app_duration.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/models/offer.dart';
import '../controllers/offers_controller.dart';

class OfferCard extends ConsumerWidget {
  const OfferCard({
    required this.offer,
    super.key,
    this.showShipperActions = false,
    this.showCarrierActions = false,
    this.jobBudgetMin,
    this.jobBudgetMax,
  });

  final Offer offer;
  final bool showShipperActions;
  final bool showCarrierActions;
  final double? jobBudgetMin;
  final double? jobBudgetMax;

  bool get _isPrimaryPending => offer.status == OfferStatus.pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actionState = ref.watch(offerActionsControllerProvider);
    final isBusy = actionState.isLoading;

    return AnimatedContainer(
      duration: AppDuration.normal,
      curve: AppCurves.decelerate,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _isPrimaryPending
            ? const Color(AppPalette.ink800)
            : const Color(AppPalette.white),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _isPrimaryPending
              ? const Color(AppPalette.ink800)
              : const Color(AppPalette.ink200),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carrier bilgisi + durum badge ──────────────────
          if (offer.carrierName != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isPrimaryPending
                      ? const Color(AppPalette.ink700)
                      : const Color(AppPalette.ink100),
                  child: Text(
                    _initials(offer.carrierName!),
                    style: TextStyle(
                      color: _isPrimaryPending
                          ? const Color(AppPalette.white)
                          : const Color(AppPalette.ink900),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carrier adı — büyük, bold
                      Text(
                        offer.carrierName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isPrimaryPending
                              ? const Color(AppPalette.white)
                              : const Color(AppPalette.ink900),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Puan + tamamlanan işler
                      Row(
                        children: [
                          if (offer.carrierRating != null &&
                              offer.carrierRating! > 0) ...[
                            Text(
                              '★ ${offer.carrierRating!.toStringAsFixed(1)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(AppPalette.gold600),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (offer.carrierCompletedJobs != null)
                            Text(
                              '${offer.carrierCompletedJobs} iş',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _isPrimaryPending
                                    ? const Color(AppPalette.ink200)
                                    : const Color(AppPalette.ink500),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Durum badge — AppStatusBadge kullan
                _buildStatusBadge(),
              ],
            ),
          if (offer.carrierName != null) const SizedBox(height: 14),

          // ── Fiyat — büyük vurgu, amber500 ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(offer.price),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(AppPalette.amber500),
                ),
              ),
              const SizedBox(width: 8),
              _budgetIndicator(theme),
            ],
          ),

          // Komisyon bilgisi
          const SizedBox(height: 4),
          Text(
            '₺0 komisyon',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(AppPalette.green600),
              fontWeight: FontWeight.w600,
            ),
          ),

          // ── Mesaj (varsa) — italic, küçük, tek satır ──────
          if (offer.message != null && offer.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              offer.message!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: _isPrimaryPending
                    ? const Color(AppPalette.ink100)
                    : const Color(AppPalette.ink600),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 10),
          Text(
            Formatters.relative(offer.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _isPrimaryPending
                  ? const Color(AppPalette.ink300)
                  : const Color(AppPalette.ink400),
            ),
          ),

          // ── Aksiyon butonları (shipper için) ──────────────
          if (showShipperActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reddet',
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.medium,
                    onPressed: isBusy
                        ? null
                        : () => _confirmAction(
                              context,
                              ref,
                              title: 'Teklifi reddet?',
                              action: () => ref
                                  .read(offerActionsControllerProvider.notifier)
                                  .reject(offer.id, offer.jobPostId),
                            ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Kabul Et 🟢',
                    size: AppButtonSize.medium,
                    onPressed: isBusy
                        ? null
                        : () => _confirmAction(
                              context,
                              ref,
                              title: 'Teklifi kabul et?',
                              message: 'Diğer açık teklifler reddedilecek, '
                                  'ilan kapanacak.',
                              action: () => ref
                                  .read(offerActionsControllerProvider.notifier)
                                  .accept(offer.id, offer.jobPostId),
                            ),
                  ),
                ),
              ],
            ),
          ],

          // ── Carrier geri çek butonu ───────────────────────
          if (showCarrierActions && offer.isPending) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Teklifimi Geri Çek',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.medium,
              onPressed: isBusy
                  ? null
                  : () => _confirmAction(
                        context,
                        ref,
                        title: 'Teklifini geri çek?',
                        action: () => ref
                            .read(offerActionsControllerProvider.notifier)
                            .withdraw(offer.id, offer.jobPostId),
                      ),
            ),
          ],
        ],
      ),
    );
  }

  /// OfferStatus → AppStatusBadge dönüşümü
  Widget _buildStatusBadge() {
    final (label, type) = switch (offer.status) {
      OfferStatus.pending => ('Beklemede', AppStatusBadgeType.warning),
      OfferStatus.accepted => ('Kabul Edildi', AppStatusBadgeType.completed),
      OfferStatus.rejected => ('Reddedildi', AppStatusBadgeType.cancelled),
      OfferStatus.withdrawn => ('Geri Çekildi', AppStatusBadgeType.info),
      OfferStatus.expired => ('Süresi Doldu', AppStatusBadgeType.cancelled),
    };
    return AppStatusBadge(
      label: label,
      status: type,
      size: AppStatusBadgeSize.sm,
    );
  }

  Widget _budgetIndicator(ThemeData theme) {
    if (jobBudgetMin == null && jobBudgetMax == null) {
      return const SizedBox.shrink();
    }
    String? label;
    Color? color;
    if (jobBudgetMin != null && offer.price < jobBudgetMin!) {
      label = 'bütçenin altında';
      color = const Color(AppPalette.gold600);
    } else if (jobBudgetMax != null && offer.price > jobBudgetMax!) {
      label = 'bütçenin üstünde';
      color = const Color(AppPalette.gold600);
    } else {
      label = 'bütçe içinde';
      color = const Color(AppPalette.green600);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required Future<bool> Function() action,
    String? message,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ? 'İşlem tamam' : 'İşlem başarısız')),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }
}
