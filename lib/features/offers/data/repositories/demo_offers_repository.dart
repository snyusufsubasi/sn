import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/offer.dart';
import 'offers_repository.dart';

class DemoOffersRepository implements OffersRepository {
  DemoOffersRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  String? get _userId => _store.state.currentUserId;

  @override
  Future<Result<List<Offer>>> fetchOffersForJob(String jobId) async {
    final list = _store.state.offers.values
        .where((o) => o.jobPostId == jobId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list);
  }

  @override
  Future<Result<Offer?>> fetchMyOfferForJob(String jobId) async {
    final uid = _userId;
    if (uid == null) return const Success(null);
    final match = _store.state.offers.values.where(
      (o) => o.jobPostId == jobId && o.carrierId == uid,
    );
    return Success(match.isEmpty ? null : match.first);
  }

  @override
  Future<Result<List<Offer>>> fetchMyOffers() async {
    final uid = _userId;
    if (uid == null) return const Success([]);
    final list = _store.state.offers.values
        .where((o) => o.carrierId == uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(list);
  }

  @override
  Future<Result<Offer>> createOffer({
    required String jobPostId,
    required double price,
    String? message,
  }) async {
    final uid = _userId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    return Success(
      _store.createOffer(
        jobPostId: jobPostId,
        carrierId: uid,
        price: price,
        message: message,
      ),
    );
  }

  @override
  Future<Result<void>> acceptOffer(String offerId) async {
    _store.acceptOffer(offerId);
    return const Success(null);
  }

  @override
  Future<Result<void>> rejectOffer(String offerId) async {
    _store.rejectOffer(offerId);
    return const Success(null);
  }

  @override
  Future<Result<void>> withdrawOffer(String offerId) async {
    _store.withdrawOffer(offerId);
    return const Success(null);
  }

  @override
  Future<Result<void>> confirmPickup(String jobId) async {
    final uid = _userId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    _store.confirmPickup(jobId, uid);
    return const Success(null);
  }

  @override
  Future<Result<void>> startRoad(String jobId) async {
    final uid = _userId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    _store.startRoad(jobId, uid);
    return const Success(null);
  }

  @override
  Future<Result<void>> confirmDelivery(String jobId) async {
    final uid = _userId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    _store.confirmDelivery(jobId, uid);
    return const Success(null);
  }
}
