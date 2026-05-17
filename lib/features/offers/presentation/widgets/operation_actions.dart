import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../jobs/data/models/job_post.dart';
import '../../../profile/data/models/user_profile.dart';
import '../controllers/offers_controller.dart';

/// İlan durumuna göre operasyon aksiyonlarını gösterir.
///
/// Tüm akış:
/// - open: aksiyon yok (teklif bölümü gösteriyor)
/// - offer_accepted / pickup_approval: "Yük Aldım" butonu (her iki taraf)
/// - loaded: nakliyeci için "Yola Çıktım"
/// - on_road / delivery_approval: "Teslim Ettim/Aldım" butonu (her iki taraf)
/// - completed / cancelled: gösterim
class OperationActions extends ConsumerWidget {
  const OperationActions({
    required this.job,
    required this.viewer,
    super.key,
  });

  final JobPost job;
  final UserProfile viewer;

  bool get _isShipper => job.shipperId == viewer.id;
  bool get _isCarrier => viewer.isCarrier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (job.status) {
      case JobStatus.open:
        return const SizedBox.shrink();

      case JobStatus.offerAccepted:
      case JobStatus.pickupApproval:
        return _PickupApprovalCard(job: job, viewer: viewer);

      case JobStatus.loaded:
        if (!_isShipper && _isCarrier) {
          return _CarrierStartRoadCard(jobId: job.id);
        }
        return _StatusInfoCard(
          icon: Icons.local_shipping_outlined,
          title: 'Yük alındı',
          message: 'Nakliyeci yola çıkması bekleniyor.',
        );

      case JobStatus.onRoad:
      case JobStatus.deliveryApproval:
        return _DeliveryApprovalCard(job: job, viewer: viewer);

      case JobStatus.awaitingPayment:
        return _AwaitingPaymentCard(jobId: job.id, isShipper: _isShipper);

      case JobStatus.completed:
        return const _StatusInfoCard(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          title: 'Tamamlandı',
          message: 'Bu taşıma başarıyla tamamlandı.',
        );

      case JobStatus.cancelled:
        return _StatusInfoCard(
          icon: Icons.cancel,
          iconColor: AppColors.ink600,
          title: 'İptal edildi',
          message: job.cancelledReason ?? 'İlan iptal edildi.',
        );
    }
  }
}

class _PickupApprovalCard extends ConsumerWidget {
  const _PickupApprovalCard({required this.job, required this.viewer});
  final JobPost job;
  final UserProfile viewer;

  bool get _isShipper => job.shipperId == viewer.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offerActionsControllerProvider);
    final isBusy = state.isLoading;

    final myConfirmed = _isShipper
        ? job.pickupConfirmedByShipper
        : job.pickupConfirmedByCarrier;
    final otherConfirmed = _isShipper
        ? job.pickupConfirmedByCarrier
        : job.pickupConfirmedByShipper;

    return AppCard(
      color: AppColors.ink50,
      borderColor: AppColors.ink200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.ink900,
              ),
              const SizedBox(width: 8),
              Text(
                'Yük Alma Onayı',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isShipper
                ? 'Nakliyeci yükü aldığında onaylayın. '
                    'İki taraf da onayladığında taşıma başlar.'
                : 'Yükü aldıktan sonra onayla. '
                    'İki taraf da onayladığında yola çıkabilirsin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink700,
                ),
          ),
          const SizedBox(height: 16),
          _ConfirmationRow(
            label: 'Senin onayın',
            confirmed: myConfirmed,
          ),
          const SizedBox(height: 8),
          _ConfirmationRow(
            label: _isShipper ? 'Nakliyeci onayı' : 'Yükveren onayı',
            confirmed: otherConfirmed,
          ),
          const SizedBox(height: 16),
          if (!myConfirmed)
            AppButton(
              label: 'Yükü Aldım',
              icon: Icons.check,
              onPressed: isBusy
                  ? null
                  : () => ref
                      .read(offerActionsControllerProvider.notifier)
                      .confirmPickup(job.id),
              loading: isBusy,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.ink100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.ink700),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sen onayladın. Karşı taraf onayı bekleniyor.',
                      style: TextStyle(
                        color: AppColors.ink700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CarrierStartRoadCard extends ConsumerWidget {
  const _CarrierStartRoadCard({required this.jobId});
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offerActionsControllerProvider);
    final isBusy = state.isLoading;
    return AppCard(
      color: AppColors.ink50,
      borderColor: AppColors.ink200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_car_outlined,
                color: AppColors.ink900,
              ),
              const SizedBox(width: 8),
              Text(
                'Yola Çıkış',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Yük araçta. Yola çıktığında bildir.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink700,
                ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Yola Çıktım',
            icon: Icons.navigation,
            onPressed: isBusy
                ? null
                : () => ref
                    .read(offerActionsControllerProvider.notifier)
                    .startRoad(jobId),
            loading: isBusy,
          ),
        ],
      ),
    );
  }
}

class _DeliveryApprovalCard extends ConsumerWidget {
  const _DeliveryApprovalCard({required this.job, required this.viewer});
  final JobPost job;
  final UserProfile viewer;

  bool get _isShipper => job.shipperId == viewer.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offerActionsControllerProvider);
    final isBusy = state.isLoading;

    final myConfirmed = _isShipper
        ? job.deliveryConfirmedByShipper
        : job.deliveryConfirmedByCarrier;
    final otherConfirmed = _isShipper
        ? job.deliveryConfirmedByCarrier
        : job.deliveryConfirmedByShipper;

    return AppCard(
      color: AppColors.ink50,
      borderColor: AppColors.ink200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                color: AppColors.ink900,
              ),
              const SizedBox(width: 8),
              Text(
                'Teslim Onayı',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isShipper
                ? 'Yükü teslim aldığında onayla. '
                    'İki taraf da onayladığında taşıma tamamlanır.'
                : 'Teslim ettiğinde onayla. '
                    'İki taraf da onayladığında taşıma tamamlanır.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink700,
                ),
          ),
          const SizedBox(height: 16),
          _ConfirmationRow(
            label: 'Senin onayın',
            confirmed: myConfirmed,
          ),
          const SizedBox(height: 8),
          _ConfirmationRow(
            label: _isShipper ? 'Nakliyeci onayı' : 'Yükveren onayı',
            confirmed: otherConfirmed,
          ),
          const SizedBox(height: 16),
          if (!myConfirmed)
            AppButton(
              label: _isShipper ? 'Teslim Aldım' : 'Teslim Ettim',
              icon: Icons.check_circle_outline,
              onPressed: isBusy
                  ? null
                  : () => ref
                      .read(offerActionsControllerProvider.notifier)
                      .confirmDelivery(job.id),
              loading: isBusy,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.ink100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.ink700),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sen onayladın. Karşı taraf onayı bekleniyor.',
                      style: TextStyle(
                        color: AppColors.ink700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({required this.label, required this.confirmed});
  final String label;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: confirmed ? AppColors.success : AppColors.ink300,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: confirmed ? AppColors.ink900 : AppColors.ink600,
                fontWeight: confirmed ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ],
    );
  }
}

class _AwaitingPaymentCard extends StatelessWidget {
  const _AwaitingPaymentCard({
    required this.jobId,
    required this.isShipper,
  });

  final String jobId;
  final bool isShipper;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.ink50,
      borderColor: AppColors.ink100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.ink900, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ödeme bekleniyor',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isShipper
                ? 'IBAN kopyalayıp havale yapın.'
                : 'Ödeme gelince onaylayın.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: isShipper ? 'Ödeme Yap' : 'Ödeme Onayı',
            onPressed: () => context.push('/jobs/$jobId/payment'),
          ),
        ],
      ),
    );
  }
}

class _StatusInfoCard extends StatelessWidget {
  const _StatusInfoCard({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.ink600,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.ink50,
      borderColor: AppColors.ink100,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.ink600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
