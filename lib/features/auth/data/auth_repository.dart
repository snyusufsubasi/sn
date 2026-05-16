import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:tasima_app/core/errors/app_exceptions.dart' as errors;

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository() : _client = SupabaseClientManager.instance.client;

  GoTrueClient get _auth => _client.auth;

  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  User? get currentUser => DevAuthService.isActive ? null : _auth.currentUser;
  Session? get currentSession =>
      DevAuthService.isActive ? null : _auth.currentSession;
  bool get isSignedIn => DevAuthService.isActive ? false : currentUser != null;
  String? get phoneNumber => currentUser?.phone;

  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _auth.signInWithOtp(phone: phone, shouldCreateUser: true);
    } on AuthException catch (e) {
      throw errors.AppAuthException(
        message: _mapOtpError(e.message),
        code: e.statusCode,
      );
    } catch (e) {
      throw errors.AppAuthException(
        message: 'SMS gonderilemedi. Lutfen tekrar deneyin.',
      );
    }
  }

  Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    try {
      final response = await _auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response;
    } on AuthException catch (e) {
      throw errors.AppAuthException(
        message: _mapOtpError(e.message),
        code: e.statusCode,
      );
    } catch (e) {
      throw errors.AppAuthException(
        message: 'Dogrulama yapilamadi. Lutfen tekrar deneyin.',
      );
    }
  }

  Future<void> signOut() async {
    if (DevAuthService.isActive) {
      await DevAuthService.clear();
      return;
    }
    try {
      await _auth.signOut();
    } catch (e) {
      throw errors.AppAuthException(message: 'Cikis yapilamadi.');
    }
  }

  String _mapOtpError(String message) {
    message = message.toLowerCase();
    if (message.contains('invalid') && message.contains('phone')) {
      return 'Gecerli bir telefon numarasi girin.';
    }
    if (message.contains('expired')) {
      return 'Kodun suresi doldu. Lutfen tekrar kod isteyin.';
    }
    if (message.contains('invalid') && message.contains('token')) {
      return 'Kod hatali.';
    }
    if (message.contains('token') && message.contains('invalid')) {
      return 'Kod hatali.';
    }
    if (message.contains('sms') || message.contains('provider')) {
      return 'SMS gonderilemedi. Lutfen tekrar deneyin.';
    }
    if (message.contains('network')) {
      return 'Baglanti hatasi olustu.';
    }
    if (message.contains('rate') || message.contains('limit')) {
      return 'Cok fazla deneme yaptiniz. Biraz bekleyip tekrar deneyin.';
    }
    if (message.contains('not found') || message.contains('user')) {
      return 'Bu telefon numarasi bulunamadi.';
    }
    return 'Bir hata olustu. Lutfen tekrar deneyin.';
  }
}
