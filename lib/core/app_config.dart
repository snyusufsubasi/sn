import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'ARACIYOK';

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static bool get isDevAuthEnabled => dotenv.env['DEV_AUTH_ENABLED'] == 'true';
  static bool get isDemoDataEnabled =>
      dotenv.env['DEMO_DATA_ENABLED'] == 'true';
}
