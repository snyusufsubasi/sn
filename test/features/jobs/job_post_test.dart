import 'package:araciyok/features/jobs/data/models/job_constants.dart';
import 'package:araciyok/features/jobs/data/models/job_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JobStatus', () {
    test('roundtrip — string <-> enum', () {
      for (final s in JobStatus.values) {
        expect(JobStatus.fromString(s.dbValue), s,
            reason: '${s.dbValue} roundtrip');
      }
    });

    test('dbValue snake_case (Postgres ile uyumlu)', () {
      expect(JobStatus.offerAccepted.dbValue, 'offer_accepted');
      expect(JobStatus.pickupApproval.dbValue, 'pickup_approval');
      expect(JobStatus.deliveryApproval.dbValue, 'delivery_approval');
      expect(JobStatus.onRoad.dbValue, 'on_road');
    });

    test('detailsRevealed — sadece open ve cancelled değilse', () {
      expect(JobStatus.open.detailsRevealed, false);
      expect(JobStatus.cancelled.detailsRevealed, false);
      expect(JobStatus.offerAccepted.detailsRevealed, true);
      expect(JobStatus.loaded.detailsRevealed, true);
      expect(JobStatus.completed.detailsRevealed, true);
    });

    test('isInProgress — sadece transit/onay aşamalarında', () {
      expect(JobStatus.open.isInProgress, false);
      expect(JobStatus.cancelled.isInProgress, false);
      expect(JobStatus.completed.isInProgress, false);
      expect(JobStatus.offerAccepted.isInProgress, true);
      expect(JobStatus.pickupApproval.isInProgress, true);
      expect(JobStatus.onRoad.isInProgress, true);
    });
  });

  group('JobFilter', () {
    test('boş filtre', () {
      const f = JobFilter();
      expect(f.isEmpty, true);
    });

    test('copyWith ile şehir eklenir', () {
      const base = JobFilter();
      final updated = base.copyWith(originCity: 'İstanbul');
      expect(updated.originCity, 'İstanbul');
      expect(updated.isEmpty, false);
    });

    test('copyWith ile clearOriginCity=true ile silinir', () {
      const base = JobFilter(originCity: 'İstanbul');
      final cleared = base.copyWith(clearOriginCity: true);
      expect(cleared.originCity, isNull);
    });
  });

  group('JobConstants', () {
    test('Türkiye il listesi 81 il içerir', () {
      expect(JobConstants.turkishCities.length, JobConstants.turkishCityCount);
    });

    test('Kritik şehirler listede mevcut', () {
      expect(JobConstants.turkishCities, contains('İstanbul'));
      expect(JobConstants.turkishCities, contains('Ankara'));
      expect(JobConstants.turkishCities, contains('İzmir'));
      expect(JobConstants.turkishCities, contains('Hakkari'));
      expect(JobConstants.turkishCities, contains('Şırnak'));
    });
  });
}
