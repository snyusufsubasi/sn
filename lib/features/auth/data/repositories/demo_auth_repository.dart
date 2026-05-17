import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_constants.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import 'auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  String? get currentUserId => _store.state.currentUserId;

  @override
  bool get isSignedIn => currentUserId != null;

  @override
  Stream<bool> get authStateChanges async* {
    yield isSignedIn;
  }

  @override
  Future<Result<void>> sendOtp({required String phoneE164}) async {
    if (DemoConstants.userIdForPhone(phoneE164) == null) {
      return const ResultFailure(
        ValidationFailure(
          message: 'Demo modda yalnızca 5551111111 veya 5552222222',
        ),
      );
    }
    return const Success(null);
  }

  @override
  Future<Result<String>> verifyOtp({
    required String phoneE164,
    required String otp,
  }) async {
    final userId = DemoConstants.userIdForPhone(phoneE164);
    if (userId == null) {
      return const ResultFailure(
        ValidationFailure(message: 'Bilinmeyen demo telefon numarası'),
      );
    }
    _store.setCurrentUser(userId);
    return Success(userId);
  }

  @override
  Future<Result<void>> signOut() async {
    _store.setCurrentUser(null);
    return const Success(null);
  }

  @override
  Future<Result<bool>> hasCompletedProfile(String userId) async {
    return Success(_store.profile(userId) != null);
  }
}
