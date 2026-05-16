import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:tasima_app/features/profile/data/profile_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Dev mode
    if (DevAuthService.isActive) {
      final loggedIn = await DevAuthService.isLoggedIn();
      if (!mounted) return;
      if (!loggedIn) {
        _goToOnboardingOrLogin();
        return;
      }
      final role = await DevAuthService.getRole();
      if (!mounted) return;
      if (role == null || role.isEmpty) {
        context.go(AppRoutes.roleSelection);
        return;
      }
      final complete = await DevAuthService.isProfileSetupComplete();
      if (!mounted) return;
      if (role == 'shipper') {
        context.go(
          complete ? AppRoutes.shipperHome : AppRoutes.shipperProfileSetup,
        );
      } else if (role == 'carrier') {
        context.go(
          complete ? AppRoutes.carrierHome : AppRoutes.carrierProfileSetup,
        );
      } else {
        context.go(AppRoutes.roleSelection);
      }
      return;
    }

    // Supabase mode
    try {
      final client = SupabaseClientManager.instance.client;
      final session = client.auth.currentSession;

      if (session == null) {
        _goToOnboardingOrLogin();
        return;
      }

      final profile = await client
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .maybeSingle();
      if (!mounted) return;
      if (profile == null) {
        context.go(AppRoutes.roleSelection);
        return;
      }
      final role = profile['role'] as String?;
      if (role == null || role.isEmpty) {
        context.go(AppRoutes.roleSelection);
        return;
      }

      final isSetupComplete = await ref
          .read(profileRepositoryProvider)
          .isProfileSetupComplete();
      if (!mounted) return;
      if (role == 'shipper') {
        context.go(
          isSetupComplete
              ? AppRoutes.shipperHome
              : AppRoutes.shipperProfileSetup,
        );
      } else if (role == 'carrier') {
        context.go(
          isSetupComplete
              ? AppRoutes.carrierHome
              : AppRoutes.carrierProfileSetup,
        );
      } else {
        context.go(AppRoutes.roleSelection);
      }
    } catch (e) {
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }

  Future<void> _goToOnboardingOrLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    if (onboardingSeen) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'ARACIYOK',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
