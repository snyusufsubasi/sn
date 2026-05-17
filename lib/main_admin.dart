import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client.dart';
import 'core/network/supabase_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {}

  AppConfig.validate();

  SupabaseClientWrapper? supabase;
  if (!AppConfig.demoMode) {
    supabase = await initSupabase();
  }

  runApp(
    ProviderScope(
      overrides: [
        if (supabase != null)
          supabaseClientProvider.overrideWithValue(supabase),
      ],
      child: const _AdminApp(),
    ),
  );
}

class _AdminApp extends StatelessWidget {
  const _AdminApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARACIYOK Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AdminDashboardScreen(),
    );
  }
}
