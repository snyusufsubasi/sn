import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/features/jobs/data/job_repository.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});
