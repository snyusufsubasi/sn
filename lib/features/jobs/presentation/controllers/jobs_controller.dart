import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/job_post.dart';
import '../../data/repositories/demo_jobs_repository.dart';
import '../../data/repositories/jobs_repository.dart';
import '../../data/repositories/supabase_jobs_repository.dart';

part 'jobs_controller.g.dart';

@Riverpod(keepAlive: true)
JobsRepository jobsRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoJobsRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseJobsRepository(client);
}

/// Açık ilanlar (carrier için). Filtre değişince yeniden çekilir.
@riverpod
Future<List<JobPost>> openJobs(Ref ref, JobFilter filter) async {
  final repo = ref.watch(jobsRepositoryProvider);
  final result = await repo.fetchOpenJobs(filter: filter);
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Aktif filtre state — bottom sheet'ten değiştirilebilir.
@riverpod
class JobFilterNotifier extends _$JobFilterNotifier {
  @override
  JobFilter build() => const JobFilter();

  void setOriginCity(String? city) {
    state = state.copyWith(
      originCity: city,
      clearOriginCity: city == null,
    );
  }

  void setDestinationCity(String? city) {
    state = state.copyWith(
      destinationCity: city,
      clearDestinationCity: city == null,
    );
  }

  void setCargoType(String? type) {
    state = state.copyWith(
      cargoType: type,
      clearCargoType: type == null,
    );
  }

  void setTrailerType(String? type) {
    state = state.copyWith(
      trailerType: type,
      clearTrailerType: type == null,
    );
  }

  void setOriginRegion(String? region) {
    state = state.copyWith(
      originRegion: region,
      clearOriginRegion: region == null,
    );
  }

  void setDestinationRegion(String? region) {
    state = state.copyWith(
      destinationRegion: region,
      clearDestinationRegion: region == null,
    );
  }

  void setSortBy(JobSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void clear() => state = const JobFilter();
}

/// Yükverenin kendi ilanları.
@riverpod
Future<List<JobPost>> myJobs(Ref ref) async {
  final repo = ref.watch(jobsRepositoryProvider);
  final result = await repo.fetchMyJobs();
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Nakliyecinin aktif olarak taşıdığı ilanlar.
@riverpod
Future<List<JobPost>> myActiveCarrierJobs(Ref ref) async {
  final repo = ref.watch(jobsRepositoryProvider);
  final result = await repo.fetchMyActiveCarrierJobs();
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Nakliyecinin tamamladığı işler.
@riverpod
Future<List<JobPost>> myCompletedCarrierJobs(Ref ref) async {
  final repo = ref.watch(jobsRepositoryProvider);
  final result = await repo.fetchMyCompletedCarrierJobs();
  return result.when(
    success: (list) => list,
    failure: (f) => throw f,
  );
}

/// Yükverenin devam eden taşımaları (demo + prod).
@riverpod
Future<List<JobPost>> myInProgressShipperJobs(Ref ref) async {
  final repo = ref.watch(jobsRepositoryProvider);
  if (repo is DemoJobsRepository) {
    final result = await repo.fetchMyInProgressShipperJobs();
    return result.when(
      success: (list) => list,
      failure: (f) => throw f,
    );
  }
  final result = await repo.fetchMyJobs();
  return result.when(
    success: (list) => list.where((j) => j.status.isInProgress).toList(),
    failure: (f) => throw f,
  );
}

/// Tekil ilan detayı — pull to refresh / realtime invalidate ile yenilenir.
@riverpod
Future<JobPost?> jobDetail(Ref ref, String id) async {
  final repo = ref.watch(jobsRepositoryProvider);
  final result = await repo.fetchJobById(id);
  return result.when(
    success: (j) => j,
    failure: (f) => throw f,
  );
}

/// İlan oluşturma controller'ı.
@riverpod
class CreateJobController extends _$CreateJobController {
  @override
  AsyncValue<JobPost?> build() => const AsyncValue.data(null);

  Future<JobPost?> submit(JobPostInput input, String shipperId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(jobsRepositoryProvider);
    final result = await repo.createJob(input, shipperId);
    return result.when(
      success: (job) {
        state = AsyncValue.data(job);
        // Liste invalidate et
        ref.invalidate(myJobsProvider);
        return job;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return null;
      },
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

/// İptal etme controller'ı.
@riverpod
class CancelJobController extends _$CancelJobController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> cancel(String jobId, String reason) async {
    state = const AsyncValue.loading();
    final repo = ref.read(jobsRepositoryProvider);
    final result = await repo.cancelJob(jobId, reason);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(jobDetailProvider(jobId));
        ref.invalidate(myJobsProvider);
        return true;
      },
      failure: (AppFailure f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}
