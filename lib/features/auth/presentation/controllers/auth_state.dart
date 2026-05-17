import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

enum AuthStatus {
  /// Henüz oturum durumu okunmadı (splash bekleniyor)
  initial,

  /// Oturum yok
  unauthenticated,

  /// Telefon girildi, OTP gönderildi, kod bekleniyor
  awaitingOtp,

  /// Oturum var ama henüz profil tamamlanmadı
  authenticatedNoProfile,

  /// Oturum var, profil tamam
  authenticated,

  /// İşlem yapılıyor (OTP gönderiliyor, doğrulanıyor, vs.)
  busy,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.phoneE164,
    this.userId,
    this.failure,
    this.otpResendSeconds = 0,
  });

  final AuthStatus status;
  final String? phoneE164;
  final String? userId;
  final AppFailure? failure;
  final int otpResendSeconds;

  AuthState copyWith({
    AuthStatus? status,
    String? phoneE164,
    String? userId,
    AppFailure? failure,
    bool clearFailure = false,
    int? otpResendSeconds,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneE164: phoneE164 ?? this.phoneE164,
      userId: userId ?? this.userId,
      failure: clearFailure ? null : (failure ?? this.failure),
      otpResendSeconds: otpResendSeconds ?? this.otpResendSeconds,
    );
  }

  @override
  List<Object?> get props =>
      [status, phoneE164, userId, failure, otpResendSeconds];
}
