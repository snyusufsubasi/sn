import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/logger.dart';
import '../../../jobs/data/models/job_post.dart';
import '../../../jobs/presentation/controllers/jobs_controller.dart';
import 'tracking_controller.dart';

part 'tracking_lifecycle.g.dart';

/// Nakliyecinin aktif iş listesini izler.
/// Eğer içlerinden biri `loaded` / `onRoad` / `deliveryApproval` durumundaysa
/// broadcasting'i başlatır. Başka durum olunca durdurur.
///
/// `keepAlive: true` çünkü app boyunca canlı kalmalı.
@Riverpod(keepAlive: true)
class TrackingLifecycle extends _$TrackingLifecycle {
  @override
  void build() {
    // Aktif carrier jobs listesini izle
    ref.listen(myActiveCarrierJobsProvider, (_, next) {
      next.whenData(_reconcile);
    });
  }

  void _reconcile(List<JobPost> jobs) {
    final broadcaster = ref.read(locationBroadcasterProvider);
    // Broadcasting yapılması gereken iş:
    // - loaded / onRoad / deliveryApproval durumlarında
    final activeForTracking = jobs.where((j) =>
        j.status == JobStatus.loaded ||
        j.status == JobStatus.onRoad ||
        j.status == JobStatus.deliveryApproval).toList();

    if (activeForTracking.isEmpty) {
      if (broadcaster.isBroadcasting) {
        AppLogger.i('Aktif takip yok, broadcasting durduruluyor');
        broadcaster.stop();
      }
      return;
    }

    // İlk uygun iş için broadcast et
    final target = activeForTracking.first;
    if (broadcaster.activeJobId != target.id) {
      AppLogger.i('Broadcasting başlatılıyor: ${target.id}');
      broadcaster.start(target.id);
    }
  }
}
