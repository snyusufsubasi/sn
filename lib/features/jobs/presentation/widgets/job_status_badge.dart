import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/models/job_post.dart';

/// Status'a göre renk + label döndürür. Tek noktadan eşleme.
class JobStatusBadge extends StatelessWidget {
  const JobStatusBadge({required this.status, super.key});

  final JobStatus status;

  AppStatusBadgeType _badgeType(JobStatus status) {
    switch (status) {
      case JobStatus.open:
        return AppStatusBadgeType.open;
      case JobStatus.offerAccepted:
      case JobStatus.pickupApproval:
      case JobStatus.loaded:
      case JobStatus.onRoad:
      case JobStatus.deliveryApproval:
        return AppStatusBadgeType.inProgress;
      case JobStatus.awaitingPayment:
        return AppStatusBadgeType.info;
      case JobStatus.completed:
        return AppStatusBadgeType.completed;
      case JobStatus.cancelled:
        return AppStatusBadgeType.cancelled;
    }
  }

  String _labelFor(BuildContext context) {
    final l10n = context.l10n;
    switch (status) {
      case JobStatus.open:
        return l10n.jobStatusOpen;
      case JobStatus.offerAccepted:
        return l10n.jobStatusOfferAccepted;
      case JobStatus.pickupApproval:
        return l10n.jobStatusPickupApproval;
      case JobStatus.loaded:
        return l10n.jobStatusLoaded;
      case JobStatus.onRoad:
        return l10n.jobStatusOnRoad;
      case JobStatus.deliveryApproval:
        return l10n.jobStatusDeliveryApproval;
      case JobStatus.awaitingPayment:
        return l10n.jobStatusAwaitingPayment;
      case JobStatus.completed:
        return l10n.jobStatusCompleted;
      case JobStatus.cancelled:
        return l10n.jobStatusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: _labelFor(context),
      status: _badgeType(status),
    );
  }
}
