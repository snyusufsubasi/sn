import 'package:araciyok/features/jobs/data/models/job_post.dart';
import 'package:araciyok/features/jobs/domain/shipment_flow_step.dart';
import 'package:araciyok/features/profile/data/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserProfile shipper() => const UserProfile(
        id: 'shipper-1',
        role: UserRole.shipper,
        userType: UserType.individual,
        fullName: 'Shipper',
        city: 'İstanbul',
        district: 'Kadıköy',
      );

  JobPost job(JobStatus status) => JobPost(
        id: 'job-1',
        shipperId: 'shipper-1',
        title: 'Deneme',
        cargoType: 'Paletli',
        weightTons: 10,
        originCity: 'İstanbul',
        originDistrict: 'Tuzla',
        destinationCity: 'Ankara',
        destinationDistrict: 'Sincan',
        pickupDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        status: status,
      );

  test('onRoad durumunda CTA canlı takip olur', () {
    final model = buildShipmentFlowModel(
      job: job(JobStatus.onRoad),
      viewer: shipper(),
      hasReviewed: false,
    );
    expect(model.ctaType, ShipmentFlowCtaType.openTracking);
  });

  test('awaitingPayment durumunda ödeme CTA', () {
    final model = buildShipmentFlowModel(
      job: job(JobStatus.awaitingPayment),
      viewer: shipper(),
      hasReviewed: false,
    );
    expect(model.ctaType, ShipmentFlowCtaType.openPayment);
  });

  test('completed + hasReviewed false iken review CTA gösterilir', () {
    final model = buildShipmentFlowModel(
      job: job(JobStatus.completed),
      viewer: shipper(),
      hasReviewed: false,
    );
    expect(model.ctaType, ShipmentFlowCtaType.openReview);
    expect(model.canReview, isTrue);
  });
}
