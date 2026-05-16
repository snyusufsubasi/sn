import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/core/app_config.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:tasima_app/shared/widgets/mobile_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  final url = AppConfig.supabaseUrl;
  final key = AppConfig.supabaseAnonKey;

  if (url.isNotEmpty && key.isNotEmpty) {
    await SupabaseClientManager.initialize(url: url, anonKey: key);
  }

  runApp(const ProviderScope(child: TasimaApp()));
}

class TasimaApp extends ConsumerWidget {
  const TasimaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) => ResponsiveMobileFrame(child: child),
    );
  }
}
