import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/supabase_client.dart';

part 'supabase_provider.g.dart';

/// Global Supabase wrapper'ı. main()'de override edilir.
/// Demo modda override edilmez, çağrıldığında throw eder.
@Riverpod(keepAlive: true)
SupabaseClientWrapper supabaseClient(Ref ref) {
  throw UnimplementedError(
    'supabaseClientProvider main()\'de override edilmemiş. '
    'Demo modda erişim yapma.',
  );
}
