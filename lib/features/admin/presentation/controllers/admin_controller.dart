import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/admin_overview.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/demo_admin_repository.dart';
import '../../data/repositories/supabase_admin_repository.dart';

part 'admin_controller.g.dart';

@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) {
  if (AppConfig.demoMode) return const DemoAdminRepository();
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAdminRepository(client);
}

@riverpod
Future<AdminOverview> adminOverview(Ref ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.fetchOverview();
  return result.when(
    success: (value) => value,
    failure: (AppFailure f) => throw f,
  );
}
