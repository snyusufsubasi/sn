import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/demo_auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import 'auth_state.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  if (AppConfig.demoMode) {
    return DemoAuthRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  Timer? _resendTimer;

  @override
  AuthState build() {
    ref.onDispose(() => _resendTimer?.cancel());

    // Demo modda backend yok — direkt unauthenticated başlat.
    if (AppConfig.demoMode) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }

    final repo = ref.read(authRepositoryProvider);

    // Auth state stream'ini dinle (sign out vb. ile state'i güncelle)
    final sub = repo.authStateChanges.listen((signedIn) {
      if (!signedIn) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
    ref.onDispose(sub.cancel);

    // İlk durum
    if (repo.isSignedIn) {
      // Profil var mı kontrol etmek async — initial state'i hızla döndür,
      // SplashScreen ya da router redirect bu kontrolü tetikler.
      return AuthState(
        status: AuthStatus.authenticatedNoProfile,
        userId: repo.currentUserId,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> sendOtp(String phoneE164) async {
    state = state.copyWith(status: AuthStatus.busy, clearFailure: true);

    try {
      if (AppConfig.demoMode) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        state = state.copyWith(
          status: AuthStatus.awaitingOtp,
          phoneE164: phoneE164,
        );
        _startResendCountdown();
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final result = await repo.sendOtp(phoneE164: phoneE164);
      result.when(
        success: (_) {
          state = state.copyWith(
            status: AuthStatus.awaitingOtp,
            phoneE164: phoneE164,
          );
          _startResendCountdown();
        },
        failure: (f) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            failure: f,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        failure: UnknownFailure(message: e.toString()),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    final phone = state.phoneE164;
    if (phone == null) return;

    state = state.copyWith(status: AuthStatus.busy, clearFailure: true);

    if (AppConfig.demoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (otp != AppConfig.demoOtpCode) {
        state = state.copyWith(
          status: AuthStatus.awaitingOtp,
          failure: const AuthFailure.invalidOtp(),
        );
        return;
      }
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.verifyOtp(phoneE164: phone, otp: otp);
      await result.when(
        success: (userId) async {
          final hasProfile = DemoConstants.userIdForPhone(phone) != null &&
              await repo.hasCompletedProfile(userId).then(
                    (r) => r.valueOrNull ?? false,
                  );
          state = state.copyWith(
            status: hasProfile
                ? AuthStatus.authenticated
                : AuthStatus.authenticatedNoProfile,
            userId: userId,
            clearFailure: true,
          );
        },
        failure: (f) {
          state = state.copyWith(
            status: AuthStatus.awaitingOtp,
            failure: f,
          );
        },
      );
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyOtp(phoneE164: phone, otp: otp);

    await result.when(
      success: (userId) async {
        // Oturum geldi, profil var mı kontrol et
        final profileCheck = await repo.hasCompletedProfile(userId);
        profileCheck.when(
          success: (hasProfile) {
            state = state.copyWith(
              status: hasProfile
                  ? AuthStatus.authenticated
                  : AuthStatus.authenticatedNoProfile,
              userId: userId,
              clearFailure: true,
            );
          },
          failure: (f) {
            // Profile kontrol başarısız oldu — yine de auth olduk varsay,
            // router profile setup'a yönlendirir.
            state = state.copyWith(
              status: AuthStatus.authenticatedNoProfile,
              userId: userId,
              failure: f,
            );
          },
        );
      },
      failure: (f) async {
        state = state.copyWith(
          status: AuthStatus.awaitingOtp,
          failure: f,
        );
      },
    );
  }

  Future<void> resendOtp() async {
    final phone = state.phoneE164;
    if (phone == null) return;
    if (state.otpResendSeconds > 0) return;
    await sendOtp(phone);
  }

  Future<void> markProfileCompleted() async {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      clearFailure: true,
    );
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    var seconds = AppConfig.otpResendCooldown.inSeconds;
    state = state.copyWith(otpResendSeconds: seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds -= 1;
      if (seconds <= 0) {
        timer.cancel();
        state = state.copyWith(otpResendSeconds: 0);
      } else {
        state = state.copyWith(otpResendSeconds: seconds);
      }
    });
  }
}
