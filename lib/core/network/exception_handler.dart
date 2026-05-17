import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/failures.dart';

/// Supabase ve genel network hatalarını domain `AppFailure`'a çevirir.
/// Tüm datasource'lar try-catch'lerini buradan geçirmeli.
AppFailure mapExceptionToFailure(Object error, [StackTrace? stack]) {
  if (error is AppFailure) return error;

  if (error is SocketException) {
    return const NetworkFailure();
  }
  if (error is TimeoutException) {
    return const TimeoutFailure();
  }

  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('otp') && msg.contains('invalid')) {
      return const AuthFailure.invalidOtp();
    }
    if (msg.contains('expired')) {
      return const AuthFailure.otpExpired();
    }
    if (msg.contains('phone')) {
      return const AuthFailure.invalidPhone();
    }
    return AuthFailure(
      code: 'auth.${error.statusCode ?? 'unknown'}',
      message: error.message,
    );
  }

  if (error is PostgrestException) {
    // Supabase PostgREST hataları
    final code = error.code ?? '';
    final msg = error.message;

    if (code == 'PGRST116' || msg.contains('not found')) {
      return const NotFoundFailure();
    }
    if (code == '42501' || msg.toLowerCase().contains('permission denied')) {
      return const UnauthorizedFailure();
    }
    if (code.startsWith('23')) {
      // 23xxx: constraint violation
      return BusinessRuleFailure(code: 'constraint.$code', message: msg);
    }
    // RAISE EXCEPTION'lardan gelen custom hatalar
    if (msg.contains('Ilan') ||
        msg.contains('Teklif') ||
        msg.contains('Bu islemi')) {
      return BusinessRuleFailure(code: 'business.rpc', message: msg);
    }
    return ServerFailure(
      message: msg,
      statusCode: int.tryParse(code),
    );
  }

  if (error is StorageException) {
    return ServerFailure(message: 'Dosya hatası: ${error.message}');
  }

  return UnknownFailure(message: error.toString(), original: error);
}
