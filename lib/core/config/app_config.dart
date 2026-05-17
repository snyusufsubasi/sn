import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Tüm env okuma tek noktadan. Hardcoded URL/key yasak — daima buradan.
class AppConfig {
  AppConfig._();

  static String _read(String key, {String fallback = ''}) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  // Supabase
  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');

  // Google Maps
  static String get googleMapsApiKeyAndroid =>
      _read('GOOGLE_MAPS_API_KEY_ANDROID');
  static String get googleMapsApiKeyIos => _read('GOOGLE_MAPS_API_KEY_IOS');
  static String get googleMapsApiKeyWeb => _read('GOOGLE_MAPS_API_KEY_WEB');

  // iyzico
  static String get iyzicoCallbackBaseUrl => _read('IYZICO_CALLBACK_BASE_URL');

  // Demo / dev
  /// Web önizlemede `.env` yüklenmezse debug'da demo açık kalır.
  static bool get demoMode {
    final raw = _read('DEMO_MODE', fallback: '');
    if (raw.isNotEmpty) return raw.toLowerCase() == 'true';
    return kDebugMode;
  }
  static String get demoOtpCode => _read('DEMO_OTP_CODE', fallback: '123456');

  // Sabitler (env'den okunmayan)
  static const String appName = 'ARACIYOK';
  static const String defaultLocale = 'tr';
  static const String supportEmail = 'destek@araciyok.com';
  static const int otpLength = 6;
  static const Duration otpResendCooldown = Duration(seconds: 60);

  /// İlk yüklemede env doğrulaması yap.
  /// Production'da Supabase URL boşsa hard fail edilir.
  static void validate() {
    if (demoMode) return;
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      if (kDebugMode) return;
      throw StateError(
        'SUPABASE_URL veya SUPABASE_ANON_KEY .env dosyasında bulunamadı. '
        'Demo modda çalışmak için DEMO_MODE=true yap.',
      );
    }
  }
}
