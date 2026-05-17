import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/carrier_profile.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

class DemoProfileRepository implements ProfileRepository {
  DemoProfileRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  Future<Result<UserProfile?>> fetchCurrentProfile() async {
    final uid = _store.state.currentUserId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    return Success(_store.profile(uid));
  }

  @override
  Future<Result<UserProfile?>> fetchProfile(String userId) async {
    return Success(_store.profile(userId));
  }

  @override
  Future<Result<UserProfile>> createProfile(UserProfile profile) async {
    return Success(_store.upsertProfile(profile));
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    return Success(_store.upsertProfile(profile));
  }

  @override
  Future<Result<String>> uploadAvatar({
    required Uint8List bytes,
    required String fileExt,
  }) async {
    return const Success('https://placeholder.demo/avatar.jpg');
  }

  @override
  Future<Result<CarrierProfile?>> fetchCarrierProfile(String userId) async {
    return Success(_store.state.carrierProfiles[userId]);
  }

  @override
  Future<Result<CarrierProfile>> upsertCarrierProfile(
    CarrierProfile profile,
  ) async {
    return Success(_store.upsertCarrierProfile(profile));
  }

  @override
  Future<Result<void>> savePhoneNumber({
    required String userId,
    required String phoneE164,
  }) async {
    return const Success(null);
  }
}
