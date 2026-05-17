import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  String? get currentUserId => _client.currentUserId;

  @override
  bool get isSignedIn => _client.isSignedIn;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session != null);

  @override
  Future<Result<void>> sendOtp({required String phoneE164}) async {
    try {
      // Demo modda yerine local OTP doğrulamasına bırak — buraya hiç gelinmez.
      if (AppConfig.demoMode) {
        AppLogger.w('sendOtp demo modda çağrıldı, no-op');
        return const Success(null);
      }

      await _client.auth.signInWithOtp(
        phone: phoneE164,
        shouldCreateUser: true,
      );
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('sendOtp error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<String>> verifyOtp({
    required String phoneE164,
    required String otp,
  }) async {
    try {
      // Demo bypass — kabul edilen kod AppConfig.demoOtpCode
      if (AppConfig.demoMode) {
        if (otp != AppConfig.demoOtpCode) {
          return const ResultFailure(AuthFailure.invalidOtp());
        }
        return Success('demo-user-${phoneE164.hashCode.abs()}');
      }

      final response = await _client.auth.verifyOTP(
        phone: phoneE164,
        token: otp,
        type: OtpType.sms,
      );

      final user = response.user;
      if (user == null) {
        return const ResultFailure(AuthFailure.invalidOtp());
      }
      return Success(user.id);
    } catch (e, st) {
      AppLogger.e('verifyOtp error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.signOut();
      return const Success(null);
    } catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<bool>> hasCompletedProfile(String userId) async {
    try {
      if (AppConfig.demoMode) {
        // Demo modda profile setup ekranını her zaman atla
        return const Success(true);
      }
      final row = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return Success(row != null);
    } catch (e, st) {
      AppLogger.e('hasCompletedProfile error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }
}
