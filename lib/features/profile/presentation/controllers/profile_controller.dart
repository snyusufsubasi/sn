import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_provider.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../data/models/carrier_profile.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/demo_profile_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/supabase_profile_repository.dart';

part 'profile_controller.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  if (AppConfig.demoMode) {
    ref.watch(demoAppStateProvider);
    return DemoProfileRepository(ref);
  }
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(client);
}

/// Mevcut kullanıcının profili. Auth değişince yeniden çekilir.
@riverpod
Future<CarrierProfile?> carrierProfileByUser(Ref ref, String userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.fetchCarrierProfile(userId);
  return result.when(
    success: (p) => p,
    failure: (f) => throw f,
  );
}

@Riverpod(keepAlive: true)
Future<UserProfile?> currentProfile(Ref ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.fetchCurrentProfile();
  return result.valueOrNull;
}

/// Profil düzenleme controller'ı.
@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  AsyncValue<UserProfile?> build() => const AsyncValue.data(null);

  /// Sadece değişen alanları gönder.
  Future<bool> save(UserProfile updated) async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(updated);
    return result.when(
      success: (p) {
        state = AsyncValue.data(p);
        ref.invalidate(currentProfileProvider);
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}

/// Nakliyecinin IBAN bilgisini günceller.
@riverpod
class UpdateCarrierIbanController extends _$UpdateCarrierIbanController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> update(String userId, String iban) async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryProvider);
    final fetchResult = await repo.fetchCarrierProfile(userId);
    final existing = fetchResult.valueOrNull;
    if (existing == null) {
      state = AsyncValue.error('Carrier profil bulunamadı', StackTrace.current);
      return false;
    }
    final updated = CarrierProfile(
      userId: existing.userId,
      vehicleType: existing.vehicleType,
      trailerType: existing.trailerType,
      capacityTons: existing.capacityTons,
      plate: existing.plate,
      serviceRegions: existing.serviceRegions,
      iban: iban.trim().isEmpty ? null : iban.trim(),
    );
    final result = await repo.upsertCarrierProfile(updated);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(carrierProfileByUserProvider(userId));
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}

/// Avatar yükleme controller'ı.
@riverpod
class UploadAvatarController extends _$UploadAvatarController {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  /// Returns: public URL (null = hata).
  Future<String?> upload({
    required Uint8List bytes,
    required String fileExt,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.uploadAvatar(bytes: bytes, fileExt: fileExt);
    return result.when(
      success: (url) {
        state = AsyncValue.data(url);
        return url;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return null;
      },
    );
  }
}
