import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/features/profile/data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  return ref.watch(profileRepositoryProvider).getCurrentUserRole();
});

final currentProfileProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  return ref.watch(profileRepositoryProvider).getCurrentProfile();
});

final profileSetupCompleteProvider = FutureProvider<bool>((ref) async {
  return ref.watch(profileRepositoryProvider).isProfileSetupComplete();
});
