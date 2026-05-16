import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasima_app/features/auth/screens/otp_verification_screen.dart';
import 'package:tasima_app/features/auth/screens/phone_login_screen.dart';
import 'package:tasima_app/features/auth/screens/splash_screen.dart';
import 'package:tasima_app/features/jobs/screens/carrier_home_screen.dart';
import 'package:tasima_app/features/jobs/screens/create_job_screen.dart';
import 'package:tasima_app/features/jobs/screens/job_created_success_screen.dart';
import 'package:tasima_app/features/jobs/screens/job_detail_screen.dart';
import 'package:tasima_app/features/jobs/screens/my_job_posts_screen.dart';
import 'package:tasima_app/features/jobs/screens/shipper_home_screen.dart';
import 'package:tasima_app/features/notifications/screens/notifications_screen.dart';
import 'package:tasima_app/features/offers/screens/my_offers_screen.dart';
import 'package:tasima_app/features/onboarding/onboarding_screen.dart';
import 'package:tasima_app/features/profile/screens/carrier_profile_setup_screen.dart';
import 'package:tasima_app/features/profile/screens/edit_profile_screen.dart';
import 'package:tasima_app/features/profile/screens/document_upload_screen.dart';
import 'package:tasima_app/features/profile/screens/document_upload_screen.dart';
import 'package:tasima_app/features/profile/screens/profile_screen.dart';
import 'package:tasima_app/features/profile/screens/shipper_profile_setup_screen.dart';
import 'package:tasima_app/features/role_selection/role_selection_screen.dart';
import 'package:tasima_app/features/settings/privacy_policy_screen.dart';
import 'package:tasima_app/features/settings/settings_screen.dart';
import 'package:tasima_app/features/settings/terms_screen.dart';
import 'package:tasima_app/features/support/report_screen.dart';
import 'package:tasima_app/features/messages/screens/messages_screen.dart';
import 'package:tasima_app/features/messages/screens/chat_screen.dart';
import 'package:tasima_app/features/support/support_screen.dart';
import 'package:tasima_app/shared/widgets/mobile_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';
  static const String shipperProfileSetup = '/shipper-profile-setup';
  static const String carrierProfileSetup = '/carrier-profile-setup';
  static const String shipperHome = '/shipper-home';
  static const String carrierHome = '/carrier-home';
  static const String createJob = '/create-job';
  static const String jobCreatedSuccess = '/job-created-success';
  static const String jobDetail = '/job-detail';
  static const String myJobPosts = '/my-job-posts';
  static const String myOffers = '/my-offers';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String documentUpload = '/document-upload';
  static const String support = '/support';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String report = '/report';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) =>
            OtpVerificationScreen(phone: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.shipperProfileSetup,
        name: 'shipperProfileSetup',
        builder: (context, state) => const ShipperProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.carrierProfileSetup,
        name: 'carrierProfileSetup',
        builder: (context, state) => const CarrierProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppTabShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.shipperHome,
            name: 'shipperHome',
            builder: (context, state) => const ShipperHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.carrierHome,
            name: 'carrierHome',
            builder: (context, state) => const CarrierHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.myJobPosts,
            name: 'myJobPosts',
            builder: (context, state) => const MyJobPostsScreen(),
          ),
          GoRoute(
            path: AppRoutes.myOffers,
            name: 'myOffers',
            builder: (context, state) => const MyOffersScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.messages,
        name: 'messages',
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:otherUserId',
        name: 'chat',
        builder: (context, state) =>
            ChatScreen(otherUserId: state.pathParameters['otherUserId']!),
      ),
      GoRoute(
        path: AppRoutes.createJob,
        name: 'createJob',
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: AppRoutes.jobCreatedSuccess,
        name: 'jobCreatedSuccess',
        builder: (context, state) =>
            JobCreatedSuccessScreen(jobId: state.uri.queryParameters['jobId']),
      ),
      GoRoute(
        path: '${AppRoutes.jobDetail}/:jobId',
        name: 'jobDetail',
        builder: (context, state) =>
            JobDetailScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentUpload,
        name: 'documentUpload',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.report,
        name: 'report',
        builder: (context, state) => ReportScreen(
          jobPostId: state.uri.queryParameters['jobPostId'],
          reportedUserId: state.uri.queryParameters['reportedUserId'],
        ),
      ),
    ],
  );
});
