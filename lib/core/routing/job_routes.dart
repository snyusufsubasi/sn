import '../../features/jobs/data/models/job_post.dart';

/// Aktif taşımalar için akış ekranı, açık ilanlar için detay.
String jobDestinationPath(JobPost job) {
  if (shouldOpenShipmentFlow(job.status)) {
    return '/jobs/${job.id}/flow';
  }
  return '/jobs/${job.id}';
}

/// Taşıma lifecycle'ındaki ilanlar için varsayılan deneyim akış ekranıdır.
bool shouldOpenShipmentFlow(JobStatus status) =>
    status != JobStatus.open && status != JobStatus.cancelled;
