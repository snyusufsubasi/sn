import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/job_post.dart';
import 'jobs_repository.dart';

class DemoJobsRepository implements JobsRepository {
  DemoJobsRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  Future<Result<List<JobPost>>> fetchOpenJobs({
    JobFilter filter = const JobFilter(),
    int limit = 20,
    int offset = 0,
  }) async {
    var list = _store.state.jobs.values
        .where((j) => j.status == JobStatus.open)
        .toList();
    if (filter.originCity != null) {
      list = list.where((j) => j.originCity == filter.originCity).toList();
    }
    if (filter.destinationCity != null) {
      list =
          list.where((j) => j.destinationCity == filter.destinationCity).toList();
    }
    if (filter.cargoType != null) {
      list = list.where((j) => j.cargoType == filter.cargoType).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list.skip(offset).take(limit).toList());
  }

  @override
  Future<Result<List<JobPost>>> fetchMyJobs({
    int limit = 20,
    int offset = 0,
  }) async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success([]);
    final list = _store.state.jobs.values
        .where((j) => j.shipperId == uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list.skip(offset).take(limit).toList());
  }

  @override
  Future<Result<List<JobPost>>> fetchMyActiveCarrierJobs() async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success([]);
    final list = <JobPost>[];
    for (final job in _store.state.jobs.values) {
      if (!job.status.isInProgress) continue;
      final offerId = job.acceptedOfferId;
      if (offerId == null) continue;
      final offer = _store.state.offers[offerId];
      if (offer?.carrierId == uid) list.add(job);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list);
  }

  @override
  Future<Result<List<JobPost>>> fetchMyCompletedCarrierJobs() async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success([]);
    final list = <JobPost>[];
    for (final job in _store.state.jobs.values) {
      if (!job.status.isCompleted) continue;
      final offerId = job.acceptedOfferId;
      if (offerId == null) continue;
      final offer = _store.state.offers[offerId];
      if (offer?.carrierId == uid) list.add(job);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list);
  }

  /// Yükverenin devam eden ilanları (demo helper).
  Future<Result<List<JobPost>>> fetchMyInProgressShipperJobs() async {
    final uid = _store.state.currentUserId;
    if (uid == null) return const Success([]);
    final list = _store.state.jobs.values
        .where((j) => j.shipperId == uid && j.status.isInProgress)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list);
  }

  @override
  Future<Result<JobPost?>> fetchJobById(String id) async {
    return Success(_store.job(id));
  }

  @override
  Future<Result<JobPost>> createJob(JobPostInput input, String shipperId) async {
    return Success(_store.createJob(input, shipperId));
  }

  @override
  Future<Result<JobPost>> updateJob(String id, JobPostInput input) async {
    final existing = _store.job(id);
    if (existing == null) {
      return const ResultFailure(
        ValidationFailure(message: 'İlan bulunamadı'),
      );
    }
    final coords = DemoCityCoords.forRoute(
      input.originCity,
      input.destinationCity,
    );
    return Success(
      _store.updateJob(
        JobPost(
          id: existing.id,
          shipperId: existing.shipperId,
          title: input.title,
          description: input.description,
          cargoType: input.cargoType,
          weightTons: input.weightTons,
          volumeM3: input.volumeM3,
          originCity: input.originCity,
          originDistrict: input.originDistrict,
          destinationCity: input.destinationCity,
          destinationDistrict: input.destinationDistrict,
          originAddress: input.originAddress,
          destinationAddress: input.destinationAddress,
          originLat: coords.$1,
          originLng: coords.$2,
          destinationLat: coords.$3,
          destinationLng: coords.$4,
          pickupDate: input.pickupDate,
          deliveryDate: input.deliveryDate,
          preferredTrailerType: input.preferredTrailerType,
          budgetMin: input.budgetMin,
          budgetMax: input.budgetMax,
          status: existing.status,
          acceptedOfferId: existing.acceptedOfferId,
          pickupConfirmedByCarrier: existing.pickupConfirmedByCarrier,
          pickupConfirmedByShipper: existing.pickupConfirmedByShipper,
          deliveryConfirmedByCarrier: existing.deliveryConfirmedByCarrier,
          deliveryConfirmedByShipper: existing.deliveryConfirmedByShipper,
          createdAt: existing.createdAt,
        ),
      ),
    );
  }

  @override
  Future<Result<void>> cancelJob(String id, String reason) async {
    _store.cancelJob(id, reason);
    return const Success(null);
  }

  @override
  Stream<JobPost> watchJob(String id) => _store.watchJob(id);
}
