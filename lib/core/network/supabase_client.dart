import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Supabase istemcisinin tek erişim noktası.
/// Notifier/Repository'ler `Supabase.instance.client` yerine bunu kullanır.
/// Sebep: testlerde fake'lemek, demo modda no-op vermek kolay olsun.
class SupabaseClientWrapper {
  SupabaseClientWrapper(this._client);

  final SupabaseClient _client;

  SupabaseClient get raw => _client;

  GoTrueClient get auth => _client.auth;

  SupabaseQueryBuilder from(String table) => _client.from(table);

  SupabaseStorageClient get storage => _client.storage;

  RealtimeClient get realtime => _client.realtime;

  /// RPC çağrıları için kısayol.
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
  }) {
    return _client.rpc<T>(fn, params: params);
  }

  /// Mevcut kullanıcı id'si. Yoksa null.
  String? get currentUserId => _client.auth.currentUser?.id;

  bool get isSignedIn => _client.auth.currentUser != null;

  /// Sign out (oturumu sonlandır).
  Future<void> signOut() => _client.auth.signOut();
}

/// İlk init — main()'de bir kere çağrılır.
Future<SupabaseClientWrapper> initSupabase() async {
  if (AppConfig.demoMode) {
    // Demo modda Supabase'e bağlanma. main()'de wrapper null kalır,
    // demo mode aktifken hiçbir repository çağrısı yapılmaması beklenir.
    // Buraya gelinmemeli.
    throw StateError('Demo modda Supabase init edilmez');
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: false,
  );

  return SupabaseClientWrapper(Supabase.instance.client);
}
