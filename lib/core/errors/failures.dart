import 'package:equatable/equatable.dart';

/// Tüm domain seviyesi hataları için sealed tip.
/// Network/server hatalarından business validation hatalarına kadar.
sealed class AppFailure extends Equatable {
  const AppFailure({required this.code, required this.message});

  /// Sabit error code — l10n için kullanılabilir.
  final String code;

  /// Geliştirici/log için. Kullanıcıya gösterilecek metin l10n'dan gelmeli.
  final String message;

  @override
  List<Object?> get props => [code, message];
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({super.message = 'İnternet bağlantısı yok'})
      : super(code: 'network');
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({super.message = 'İstek zaman aşımına uğradı'})
      : super(code: 'timeout');
}

final class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message = 'Sunucu hatası',
    this.statusCode,
  }) : super(code: 'server');
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

final class AuthFailure extends AppFailure {
  const AuthFailure({
    required super.code,
    required super.message,
  });

  const AuthFailure.invalidPhone()
      : super(code: 'auth.invalid_phone', message: 'Geçersiz telefon numarası');
  const AuthFailure.invalidOtp()
      : super(code: 'auth.invalid_otp', message: 'Doğrulama kodu hatalı');
  const AuthFailure.otpExpired()
      : super(code: 'auth.otp_expired', message: 'Doğrulama kodu süresi doldu');
  const AuthFailure.sessionExpired()
      : super(
          code: 'auth.session_expired',
          message: 'Oturum süresi doldu, tekrar giriş yap',
        );
  const AuthFailure.notAuthenticated()
      : super(
          code: 'auth.not_authenticated',
          message: 'Giriş yapmamışsın',
        );
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
  }) : super(code: 'validation');
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.message = 'Bulunamadı'})
      : super(code: 'not_found');
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({super.message = 'Bu işlem için yetkin yok'})
      : super(code: 'unauthorized');
}

final class BusinessRuleFailure extends AppFailure {
  /// İş kuralı ihlali (örn. zaten teklif var, zaten kabul edilmiş, vs.)
  const BusinessRuleFailure({
    required super.code,
    required super.message,
  });
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure({
    super.message = 'Beklenmedik bir hata oluştu',
    this.original,
  }) : super(code: 'unknown');
  final Object? original;

  @override
  List<Object?> get props => [...super.props, original];
}
