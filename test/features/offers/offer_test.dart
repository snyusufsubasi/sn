import 'package:araciyok/features/offers/data/models/offer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfferStatus', () {
    test('fromString tüm değerleri tanır', () {
      expect(OfferStatus.fromString('pending'), OfferStatus.pending);
      expect(OfferStatus.fromString('accepted'), OfferStatus.accepted);
      expect(OfferStatus.fromString('rejected'), OfferStatus.rejected);
      expect(OfferStatus.fromString('withdrawn'), OfferStatus.withdrawn);
      expect(OfferStatus.fromString('expired'), OfferStatus.expired);
    });

    test('fromString bilinmeyen değerde fırlatır', () {
      expect(
        () => OfferStatus.fromString('garbage'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Offer.fromJson', () {
    test('düz alanları parse eder', () {
      final json = {
        'id': 'o1',
        'job_post_id': 'j1',
        'carrier_id': 'c1',
        'price': 12500.0,
        'message': 'Hızlı teslim',
        'status': 'pending',
        'created_at': '2026-05-16T10:00:00Z',
      };
      final o = Offer.fromJson(json);
      expect(o.id, 'o1');
      expect(o.price, 12500.0);
      expect(o.status, OfferStatus.pending);
      expect(o.message, 'Hızlı teslim');
      expect(o.isPending, true);
    });

    test('profile join alanlarını parse eder', () {
      final json = {
        'id': 'o1',
        'job_post_id': 'j1',
        'carrier_id': 'c1',
        'price': 12500.0,
        'status': 'accepted',
        'created_at': '2026-05-16T10:00:00Z',
        'profiles': {
          'full_name': 'Ahmet Yıldız',
          'rating_avg': 4.8,
          'completed_jobs_count': 23,
        },
      };
      final o = Offer.fromJson(json);
      expect(o.carrierName, 'Ahmet Yıldız');
      expect(o.carrierRating, 4.8);
      expect(o.carrierCompletedJobs, 23);
      expect(o.isAccepted, true);
    });
  });
}
