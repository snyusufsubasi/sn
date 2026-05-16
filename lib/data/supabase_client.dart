import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static SupabaseClientManager? _instance;
  late final SupabaseClient client;

  SupabaseClientManager._();

  static Future<SupabaseClientManager> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_instance != null) return _instance!;

    await Supabase.initialize(url: url, anonKey: anonKey);

    _instance = SupabaseClientManager._();
    _instance!.client = Supabase.instance.client;
    return _instance!;
  }

  static SupabaseClientManager get instance {
    if (_instance == null) {
      throw StateError(
        'SupabaseClientManager baslatilmadi. initialize() cagir.',
      );
    }
    return _instance!;
  }

  SupabaseClient get supabase => client;
}
