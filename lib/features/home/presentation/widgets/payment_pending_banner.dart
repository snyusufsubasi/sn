import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../jobs/data/models/job_post.dart';

/// Anasayfada ödeme bekleyen işler için hero kart.
class PaymentPendingBanner extends StatelessWidget {
  const PaymentPendingBanner({
    required this.jobs,
    super.key,
  });

  final List<JobPost> jobs;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final job = jobs.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        color: AppColors.ink50,
        borderColor: AppColors.ink200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.ink900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.homePaymentPending,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (jobs.length > 1)
                  Text(
                    '+${jobs.length - 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.homePaymentPendingSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              job.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.homePaymentPendingAction,
              size: AppButtonSize.medium,
              onPressed: () => context.push('/jobs/${job.id}/payment'),
            ),
          ],
        ),
      ),
    );
  }
}
