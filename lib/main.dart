import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client.dart';
import 'core/network/supabase_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/controllers/auth_state.dart';
import 'features/notifications/data/services/push_notification_service.dart';
import 'features/notifications/presentation/controllers/push_provider.dart';
import 'features/tracking/presentation/controllers/tracking_lifecycle.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // .env yükle. Web'de asset olarak paketlenir; yoksa debug demo modu açılır.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    AppLogger.w('.env yüklenemedi, varsayılan değerlerle devam ediliyor: $e');
  }

  AppConfig.validate();
  await initializeDateFormatting('tr_TR');

  // Firebase — web önizlemede yapılandırma yok; mobilde dene.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    } catch (e) {
      AppLogger.w('Firebase init başarısız, push devre dışı: $e');
    }
  }

  // Supabase init
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
      child: const _ARACIYOKApp(),
    ),
  );
}

class _ARACIYOKApp extends ConsumerStatefulWidget {
  const _ARACIYOKApp();

  @override
  ConsumerState<_ARACIYOKApp> createState() => _ARACIYOKAppState();
}

class _ARACIYOKAppState extends ConsumerState<_ARACIYOKApp> {
  void _handleNotificationTap(Map<String, dynamic> data) {
    final router = ref.read(appRouterProvider);
    final type = data['type'] as String?;
    final jobPostId = data['job_post_id'] as String?;
    final threadId = data['thread_id'] as String?;

    AppLogger.i('Notification tap → type=$type jobId=$jobPostId threadId=$threadId');

    // Öncelik: thread > job > notifications
    if (threadId != null) {
      router.push('/messages/$threadId');
    } else if (jobPostId != null) {
      router.push('/jobs/$jobPostId');
    } else {
      router.push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    // Auth state değişince push ve tracking lifecycle'ı yönet.
    ref.listen<AuthState>(authControllerProvider, (prev, next) async {
      if (prev?.status != next.status && !AppConfig.demoMode) {
        final push = ref.read(pushNotificationServiceProvider);
        if (next.status == AuthStatus.authenticated) {
          await push.initialize();
          push.onNotificationTap = _handleNotificationTap;
        } else if (next.status == AuthStatus.unauthenticated &&
            prev?.status == AuthStatus.authenticated) {
          await push.deactivateCurrentToken();
        }
      }
    });

    if (!AppConfig.demoMode) {
      ref.read(trackingLifecycleProvider);
    }

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr'),
    );
  }
}
