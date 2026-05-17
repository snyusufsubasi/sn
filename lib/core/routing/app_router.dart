import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';
import '../theme/motion/app_curves.dart';
import '../theme/motion/app_duration.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/jobs_list_screen.dart';
import '../../features/jobs/presentation/screens/shipment_flow_screen.dart';
import '../../features/messages/data/models/message_thread.dart';
import '../../features/messages/presentation/screens/message_thread_screen.dart';
import '../../features/messages/presentation/screens/threads_list_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/offers/presentation/screens/my_offers_screen.dart';
import '../../features/payments/presentation/screens/payment_status_screen.dart';
import '../../features/profile/data/models/user_profile.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/carrier_profile_setup_screen.dart';
import '../../features/profile/presentation/screens/legal_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';
import '../../features/profile/presentation/screens/role_selection_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/tracking/presentation/screens/job_tracking_screen.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

CustomTransitionPage<void> _slidePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDuration.slow,
    reverseTransitionDuration: AppDuration.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: AppCurves.standard,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: AppCurves.decelerate),
      );
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDuration.deliberate,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.decelerate,
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.decelerate),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppPalette.navy800),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(AppPalette.white).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    size: 44,
                    color: Color(AppPalette.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'ARACIYOK',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(AppPalette.white),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Yükveren ile Nakliyeci Buluşuyor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppPalette.white).withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: AppSpacing.huge),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(AppPalette.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authNotifier = ValueNotifier<AuthStatus>(
    ref.read(authControllerProvider).status,
  );

  late final GoRouter router;
  router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: authNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (location == RoutePaths.splash) {
        switch (auth.status) {
          case AuthStatus.initial:
          case AuthStatus.busy:
            return null;
          case AuthStatus.unauthenticated:
            return RoutePaths.login;
          case AuthStatus.awaitingOtp:
            return RoutePaths.otp;
          case AuthStatus.authenticatedNoProfile:
            return RoutePaths.roleSelection;
          case AuthStatus.authenticated:
            return RoutePaths.home;
        }
      }

      if (location == RoutePaths.login &&
          auth.status == AuthStatus.awaitingOtp) {
        return RoutePaths.otp;
      }

      final isAuthRoute =
          location == RoutePaths.login || location == RoutePaths.otp;
      if (isAuthRoute && auth.status == AuthStatus.authenticated) {
        return RoutePaths.home;
      }

      final isProtected = !isAuthRoute &&
          location != RoutePaths.splash &&
          location != RoutePaths.roleSelection &&
          location != RoutePaths.profileSetup;
      if (isProtected && auth.status == AuthStatus.unauthenticated) {
        return RoutePaths.login;
      }

      if (auth.status == AuthStatus.authenticatedNoProfile &&
          location != RoutePaths.roleSelection &&
          location != RoutePaths.profileSetup &&
          location != RoutePaths.carrierProfileSetup) {
        return RoutePaths.roleSelection;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, __) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        builder: (_, __) => const OtpScreen(),
      ),
      GoRoute(
        path: RoutePaths.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileSetup,
        builder: (_, state) {
          final role = state.extra as UserRole? ?? UserRole.shipper;
          return ProfileSetupScreen(role: role);
        },
      ),
      GoRoute(
        path: RoutePaths.carrierProfileSetup,
        builder: (_, __) => const CarrierProfileSetupScreen(),
      ),

      // SHELL içi — bottom nav her ana akışta görünür.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.jobs,
                builder: (_, state) {
                  final tab = state.uri.queryParameters['tab'];
                  final initialTab = switch (tab) {
                    'active' => CarrierJobsTab.active,
                    'completed' => CarrierJobsTab.completed,
                    _ => CarrierJobsTab.available,
                  };
                  return JobsListScreen(initialCarrierTab: initialTab);
                },
              ),
              GoRoute(
                path: RoutePaths.createJob,
                pageBuilder: (ctx, state) =>
                    _slidePage(ctx, state, const CreateJobScreen()),
              ),
              GoRoute(
                path: RoutePaths.jobDetail,
                pageBuilder: (ctx, state) {
                  final id = state.pathParameters['id']!;
                  final forceDetail =
                      state.uri.queryParameters['view'] == 'detail';
                  return _slidePage(
                    ctx,
                    state,
                    JobDetailScreen(
                      jobId: id,
                      forceDetailView: forceDetail,
                    ),
                  );
                },
              ),
              GoRoute(
                path: RoutePaths.jobFlow,
                pageBuilder: (ctx, state) {
                  final id = state.pathParameters['id']!;
                  return _slidePage(ctx, state, ShipmentFlowScreen(jobId: id));
                },
              ),
              GoRoute(
                path: RoutePaths.jobTracking,
                pageBuilder: (ctx, state) {
                  final id = state.pathParameters['id']!;
                  return _slidePage(
                      ctx, state, JobTrackingScreen(jobId: id));
                },
              ),
              GoRoute(
                path: RoutePaths.jobPayment,
                pageBuilder: (ctx, state) {
                  final id = state.pathParameters['id']!;
                  return _slidePage(
                      ctx, state, PaymentStatusScreen(jobId: id));
                },
              ),
              GoRoute(
                path: RoutePaths.myOffers,
                pageBuilder: (ctx, state) =>
                    _slidePage(ctx, state, const MyOffersScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.notifications,
                builder: (_, __) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.messages,
                builder: (_, __) => const ThreadsListScreen(),
              ),
              GoRoute(
                path: RoutePaths.messageThread,
                pageBuilder: (ctx, state) {
                  final threadId = state.pathParameters['threadId']!;
                  final thread = state.extra as MessageThread?;
                  return _slidePage(
                    ctx,
                    state,
                    MessageThreadScreen(threadId: threadId, thread: thread),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
              GoRoute(
                path: RoutePaths.editProfile,
                pageBuilder: (ctx, state) {
                  final profile = state.extra! as UserProfile;
                  return _slidePage(
                    ctx,
                    state,
                    EditProfileScreen(profile: profile),
                  );
                },
              ),
              GoRoute(
                path: RoutePaths.legalTerms,
                pageBuilder: (ctx, state) =>
                    _slidePage(ctx, state, const LegalScreen(kind: 'terms')),
              ),
              GoRoute(
                path: RoutePaths.legalPrivacy,
                pageBuilder: (ctx, state) =>
                    _slidePage(ctx, state, const LegalScreen(kind: 'privacy')),
              ),
              GoRoute(
                path: RoutePaths.legalHelp,
                pageBuilder: (ctx, state) =>
                    _slidePage(ctx, state, const LegalScreen(kind: 'help')),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen<AuthState>(authControllerProvider, (prev, next) {
    if (prev?.status != next.status) {
      authNotifier.value = next.status;
      router.refresh();
    }
  });

  ref.onDispose(authNotifier.dispose);

  return router;
}
