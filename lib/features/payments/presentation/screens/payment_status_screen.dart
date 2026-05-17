import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../jobs/data/models/job_post.dart';
import '../../../jobs/presentation/controllers/jobs_controller.dart';
import '../../../offers/data/models/offer.dart';
import '../../../offers/presentation/controllers/offers_controller.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/payment_record.dart';
import '../controllers/payments_controller.dart';

class PaymentStatusScreen extends ConsumerWidget {
  const PaymentStatusScreen({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(currentProfileProvider);
    final jobAsync = ref.watch(jobDetailProvider(jobId));
    final paymentAsync = ref.watch(paymentByJobProvider(jobId));

    return AppScaffold(
      title: l10n.paymentTitle,
      body: profileAsync.when(
        loading: () => const _PaymentSkeleton(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return jobAsync.when(
            loading: () => const _PaymentSkeleton(),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (job) {
              if (job == null) {
                return Center(child: Text(l10n.errorNotFound));
              }
              return paymentAsync.when(
                loading: () =>
                    const _PaymentSkeleton(),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (payment) => _PaymentFlowBody(
                  job: job,
                  payment: payment,
                  profile: profile,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PaymentFlowBody extends ConsumerWidget {
  const _PaymentFlowBody({
    required this.job,
    required this.payment,
    required this.profile,
  });

  final JobPost job;
  final PaymentRecord? payment;
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isShipper = job.shipperId == profile.id;
    final offersAsync = ref.watch(offersForJobProvider(job.id));
    final confirmState = ref.watch(confirmCarrierPaymentControllerProvider);

    if (job.status != JobStatus.awaitingPayment &&
        job.status != JobStatus.completed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            l10n.paymentNotReady,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return offersAsync.when(
      loading: () => const _PaymentSkeleton(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (offers) {
        Offer? accepted;
        for (final o in offers) {
          if (o.isAccepted) {
            accepted = o;
            break;
          }
        }
        final amount = payment?.amount ?? accepted?.price ?? 0.0;

        if (payment?.status == PaymentStatus.held && isShipper) {
          return _EscrowPaymentView(
            jobId: job.id,
            payment: payment!,
            releaseLoading:
                ref.watch(releasePaymentControllerProvider).isLoading,
            onRelease: () async {
              final ok = await ref
                  .read(releasePaymentControllerProvider.notifier)
                  .release(job.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? l10n.paymentEscrowReleased : l10n.commonError,
                  ),
                ),
              );
            },
          );
        }

        if (isShipper) {
          return _ShipperPaymentView(
            jobId: job.id,
            amount: amount,
            payment: payment,
            carrierId: accepted?.carrierId,
            jobCompleted: job.status == JobStatus.completed,
            reportLoading:
                ref.watch(reportShipperTransferControllerProvider).isLoading,
            onReportTransfer: job.status == JobStatus.awaitingPayment &&
                    payment?.shipperReportedTransferAt == null
                ? () async {
                    final ok = await ref
                        .read(
                          reportShipperTransferControllerProvider.notifier,
                        )
                        .report(job.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? l10n.paymentReportTransferSuccess
                              : l10n.commonError,
                        ),
                      ),
                    );
                  }
                : null,
          );
        }

        return _CarrierPaymentView(
          amount: amount,
          payment: payment,
          jobCompleted: job.status == JobStatus.completed,
          confirmLoading: confirmState.isLoading,
          onConfirm: job.status == JobStatus.awaitingPayment
              ? () async {
                  final ok = await ref
                      .read(confirmCarrierPaymentControllerProvider.notifier)
                      .confirm(job.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? l10n.paymentConfirmSuccess : l10n.commonError,
                      ),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }
}

class _EscrowPaymentView extends StatelessWidget {
  const _EscrowPaymentView({
    required this.jobId,
    required this.payment,
    required this.releaseLoading,
    required this.onRelease,
  });

  final String jobId;
  final PaymentRecord payment;
  final bool releaseLoading;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.paymentEscrowTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(l10n.paymentEscrowHint),
              const SizedBox(height: 12),
              _RowLine(
                label: l10n.paymentAmount,
                value: '₺${payment.amount.toStringAsFixed(2)}',
              ),
              _RowLine(
                label: l10n.paymentCommission,
                value: l10n.paymentZeroCommission,
              ),
            ],
          ),
        ),
        const Spacer(),
        AppButton(
          label: l10n.paymentEscrowRelease,
          loading: releaseLoading,
          onPressed: releaseLoading ? null : onRelease,
        ),
      ],
    );
  }
}

class _ShipperPaymentView extends ConsumerWidget {
  const _ShipperPaymentView({
    required this.jobId,
    required this.amount,
    required this.payment,
    required this.carrierId,
    required this.jobCompleted,
    required this.reportLoading,
    required this.onReportTransfer,
  });

  final String jobId;
  final double amount;
  final PaymentRecord? payment;
  final String? carrierId;
  final bool jobCompleted;
  final bool reportLoading;
  final VoidCallback? onReportTransfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final carrierProfileAsync = carrierId != null
        ? ref.watch(carrierProfileByUserProvider(carrierId!))
        : const AsyncValue.data(null);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobCompleted
                      ? l10n.paymentCompletedTitle
                      : l10n.paymentAwaitingTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                _RowLine(label: l10n.paymentAmount, value: '₺${amount.toStringAsFixed(2)}'),
                _RowLine(
                  label: l10n.paymentCommission,
                  value: l10n.paymentZeroCommission,
                ),
                if (payment != null)
                  _RowLine(
                    label: l10n.paymentStatusLabel,
                    value: _paymentStatusLabel(context, payment!.status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          carrierProfileAsync.when(
            loading: () => const _PaymentSkeleton(),
            error: (e, _) => Text(e.toString()),
            data: (carrier) {
              final iban = carrier?.iban;
              if (iban == null || iban.isEmpty) {
                return AppCard(
                  child: Text(
                    l10n.paymentIbanMissing,
                    style: TextStyle(color: scheme.onSurface),
                  ),
                );
              }
              final display = IbanUtils.formatDisplay(iban);
              final masked = IbanUtils.mask(iban);
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.paymentIbanTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      masked,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.paymentIbanHint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: l10n.paymentCopyIban,
                      icon: Icons.copy,
                      onPressed: jobCompleted
                          ? null
                          : () async {
                              await Clipboard.setData(
                                ClipboardData(text: IbanUtils.normalize(iban)),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.paymentIbanCopied)),
                              );
                            },
                    ),
                    if (display != masked) ...[
                      const SizedBox(height: 8),
                      Text(
                        display,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          if (!jobCompleted) ...[
            const SizedBox(height: AppSpacing.lg),
            if (payment?.shipperReportedTransferAt != null)
              Text(
                l10n.paymentReportTransferDone,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
              )
            else if (onReportTransfer != null)
              AppButton(
                label: l10n.paymentReportTransfer,
                variant: AppButtonVariant.secondary,
                loading: reportLoading,
                onPressed: reportLoading ? null : onReportTransfer,
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.paymentWaitingCarrier,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _paymentStatusLabel(BuildContext context, PaymentStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      PaymentStatus.awaitingTransfer => l10n.paymentStatusAwaiting,
      PaymentStatus.carrierConfirmed => l10n.paymentStatusConfirmed,
      PaymentStatus.pending => l10n.paymentStatusPending,
      _ => status.name,
    };
  }
}

class _CarrierPaymentView extends StatelessWidget {
  const _CarrierPaymentView({
    required this.amount,
    required this.payment,
    required this.jobCompleted,
    required this.confirmLoading,
    required this.onConfirm,
  });

  final double amount;
  final PaymentRecord? payment;
  final bool jobCompleted;
  final bool confirmLoading;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobCompleted
                    ? l10n.paymentCompletedTitle
                    : l10n.paymentCarrierTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              _RowLine(
                label: l10n.paymentAmount,
                value: '₺${amount.toStringAsFixed(2)}',
              ),
              _RowLine(
                label: l10n.paymentCommission,
                value: l10n.paymentZeroCommission,
              ),
              if (!jobCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.paymentCarrierHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),
        if (!jobCompleted && onConfirm != null)
          AppButton(
            label: l10n.paymentConfirmReceived,
            loading: confirmLoading,
            onPressed: confirmLoading
                ? null
                : () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.paymentConfirmDialogTitle),
                        content: Text(l10n.paymentConfirmDialogBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n.commonCancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onConfirm!();
                            },
                            child: Text(l10n.commonConfirm),
                          ),
                        ],
                      ),
                    );
                  },
          ),
      ],
    );
  }
}

class _PaymentSkeleton extends StatelessWidget {
  const _PaymentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        children: [
          AppSkeletonCard(height: 140),
          SizedBox(height: AppSpacing.md),
          AppSkeletonCard(height: 100),
        ],
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
