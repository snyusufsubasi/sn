import '../../offers/data/models/offer.dart';
import '../../profile/data/models/user_profile.dart';
import '../data/models/job_post.dart';

enum ShipmentFlowStepKind {
  offerAccepted,
  pickupApproval,
  startRoad,
  onRoad,
  deliveryApproval,
  completed,
  paymentPlaceholder,
}

enum ShipmentFlowCtaType {
  none,
  confirmPickup,
  startRoad,
  openTracking,
  confirmDelivery,
  openPayment,
  openReview,
}

class ShipmentFlowStep {
  const ShipmentFlowStep({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.isActive,
    this.shipperConfirmed,
    this.carrierConfirmed,
  });

  final ShipmentFlowStepKind kind;
  final String title;
  final String subtitle;
  final bool isComplete;
  final bool isActive;
  final bool? shipperConfirmed;
  final bool? carrierConfirmed;
}

class ShipmentFlowModel {
  const ShipmentFlowModel({
    required this.steps,
    required this.activeIndex,
    required this.ctaType,
    required this.ctaLabel,
    required this.showTrackingPreview,
    required this.revieweeId,
    required this.canReview,
  });

  final List<ShipmentFlowStep> steps;
  final int activeIndex;
  final ShipmentFlowCtaType ctaType;
  final String? ctaLabel;
  final bool showTrackingPreview;
  final String? revieweeId;
  final bool canReview;

  double get progress => steps.isEmpty ? 0 : (activeIndex + 1) / steps.length;
}

int _statusOrder(JobStatus s) {
  switch (s) {
    case JobStatus.open:
      return 0;
    case JobStatus.offerAccepted:
      return 1;
    case JobStatus.pickupApproval:
      return 2;
    case JobStatus.loaded:
      return 3;
    case JobStatus.onRoad:
      return 4;
    case JobStatus.deliveryApproval:
      return 5;
    case JobStatus.awaitingPayment:
      return 6;
    case JobStatus.completed:
      return 7;
    case JobStatus.cancelled:
      return -1;
  }
}

ShipmentFlowModel buildShipmentFlowModel({
  required JobPost job,
  required UserProfile viewer,
  Offer? acceptedOffer,
  bool hasReviewed = false,
}) {
  final isShipper = job.shipperId == viewer.id;
  final order = _statusOrder(job.status);
  final revieweeId = isShipper ? acceptedOffer?.carrierId : job.shipperId;

  final steps = <ShipmentFlowStep>[
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.offerAccepted,
      title: 'Teklif kabul edildi',
      subtitle: 'Taşıma başladı.',
      isComplete: order >= 1,
      isActive: job.status == JobStatus.offerAccepted,
    ),
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.pickupApproval,
      title: 'Yük alma onayı',
      subtitle: 'İki taraf da onaylamalı.',
      isComplete: order >= 3,
      isActive: job.status == JobStatus.offerAccepted ||
          job.status == JobStatus.pickupApproval,
      shipperConfirmed: job.pickupConfirmedByShipper,
      carrierConfirmed: job.pickupConfirmedByCarrier,
    ),
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.startRoad,
      title: 'Yola çıkış',
      subtitle: 'Nakliyeci yola çıktığında bildirir.',
      isComplete: order >= 4,
      isActive: job.status == JobStatus.loaded,
    ),
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.onRoad,
      title: 'Yolda',
      subtitle: 'Canlı konum takibi.',
      isComplete: order >= 5,
      isActive: job.status == JobStatus.onRoad,
    ),
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.deliveryApproval,
      title: 'Teslim onayı',
      subtitle: 'Teslimatı onaylayın.',
      isComplete: order >= 6,
      isActive: job.status == JobStatus.deliveryApproval,
      shipperConfirmed: job.deliveryConfirmedByShipper,
      carrierConfirmed: job.deliveryConfirmedByCarrier,
    ),
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.paymentPlaceholder,
      title: 'Ödeme',
      subtitle: isShipper
          ? 'Havale yap, nakliyeci onaylasın.'
          : 'Ödeme gelince onayla.',
      isComplete: order >= 7,
      isActive: job.status == JobStatus.awaitingPayment,
    ),
    ShipmentFlowStep(
      kind: ShipmentFlowStepKind.completed,
      title: 'Tamamlandı',
      subtitle: hasReviewed ? 'Teşekkürler.' : 'Değerlendirme yapabilirsin.',
      isComplete: job.status == JobStatus.completed && hasReviewed,
      isActive: job.status == JobStatus.completed && !hasReviewed,
    ),
  ];

  var activeIndex = steps.indexWhere((s) => s.isActive);
  if (activeIndex < 0) {
    activeIndex = steps.lastIndexWhere((s) => s.isComplete);
  }

  final cta = _resolveCta(job, isShipper, hasReviewed);

  return ShipmentFlowModel(
    steps: steps,
    activeIndex: activeIndex.clamp(0, steps.length - 1),
    ctaType: cta.$1,
    ctaLabel: cta.$2,
    showTrackingPreview: order >= 1 && order < 7,
    revieweeId: revieweeId,
    canReview: job.status == JobStatus.completed && !hasReviewed,
  );
}

(ShipmentFlowCtaType, String?) _resolveCta(
  JobPost job,
  bool isShipper,
  bool hasReviewed,
) {
  if (job.status == JobStatus.completed) {
    if (hasReviewed) return (ShipmentFlowCtaType.none, null);
    return (ShipmentFlowCtaType.openReview, 'Değerlendir');
  }
  if (job.status == JobStatus.offerAccepted ||
      job.status == JobStatus.pickupApproval) {
    final myDone =
        isShipper ? job.pickupConfirmedByShipper : job.pickupConfirmedByCarrier;
    if (!myDone) {
      return (
        ShipmentFlowCtaType.confirmPickup,
        isShipper ? 'Yük Alındı Onayı' : 'Yükü Aldım',
      );
    }
    return (ShipmentFlowCtaType.none, 'Karşı taraf onayı bekleniyor');
  }
  if (job.status == JobStatus.loaded) {
    if (!isShipper) {
      return (ShipmentFlowCtaType.startRoad, 'Yola Çıktım');
    }
    return (ShipmentFlowCtaType.none, 'Nakliyeci yola çıkması bekleniyor');
  }
  if (job.status == JobStatus.onRoad) {
    return (ShipmentFlowCtaType.openTracking, 'Canlı Takip');
  }
  if (job.status == JobStatus.deliveryApproval) {
    final myDone = isShipper
        ? job.deliveryConfirmedByShipper
        : job.deliveryConfirmedByCarrier;
    if (!myDone) {
      return (
        ShipmentFlowCtaType.confirmDelivery,
        isShipper ? 'Teslim Aldım' : 'Teslim Ettim',
      );
    }
    return (ShipmentFlowCtaType.none, 'Karşı taraf onayı bekleniyor');
  }
  if (job.status == JobStatus.awaitingPayment) {
    return (
      ShipmentFlowCtaType.openPayment,
      isShipper ? 'Ödeme Yap' : 'Ödeme Onayı',
    );
  }
  return (ShipmentFlowCtaType.none, null);
}
