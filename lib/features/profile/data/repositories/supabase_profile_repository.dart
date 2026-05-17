import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/carrier_profile.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  Future<Result<UserProfile?>> fetchCurrentProfile() async {
    final uid = _client.currentUserId;
    if (uid == null) {
      return const ResultFailure(AuthFailure.notAuthenticated());
    }
    return fetchProfile(uid);
  }

  @override
  Future<Result<UserProfile?>> fetchProfile(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return const Success(null);
      return Success(UserProfile.fromJson(row));
    } catch (e, st) {
      AppLogger.e('fetchProfile error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<UserProfile>> createProfile(UserProfile profile) async {
    try {
      final inserted = await _client
          .from('profiles')
          .insert(profile.toJson())
          .select()
          .single();
      return Success(UserProfile.fromJson(inserted));
    } catch (e, st) {
      AppLogger.e('createProfile error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final updated = await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();
      return Success(UserProfile.fromJson(updated));
    } catch (e, st) {
      AppLogger.e('updateProfile error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<CarrierProfile?>> fetchCarrierProfile(String userId) async {
    try {
      final row = await _client
          .from('carrier_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) return const Success(null);
      return Success(CarrierProfile.fromJson(row));
    } catch (e, st) {
      AppLogger.e('fetchCarrierProfile error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<CarrierProfile>> upsertCarrierProfile(
    CarrierProfile profile,
  ) async {
    try {
      final upserted = await _client
          .from('carrier_profiles')
          .upsert(profile.toJson())
          .select()
          .single();
      return Success(CarrierProfile.fromJson(upserted));
    } catch (e, st) {
      AppLogger.e('upsertCarrierProfile error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> savePhoneNumber({
    required String userId,
    required String phoneE164,
  }) async {
    try {
      await _client.from('profile_private_info').upsert({
        'user_id': userId,
        'phone': phoneE164,
      });
      return const Success(null);
    } catch (e, st) {
      AppLogger.e('savePhoneNumber error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<String>> uploadAvatar({
    required Uint8List bytes,
    required String fileExt,
  }) async {
    try {
      final uid = _client.currentUserId;
      if (uid == null) {
        return const ResultFailure(AuthFailure.notAuthenticated());
      }

      // RLS politikası: bucket=avatars, path[0] = auth.uid()
      // Path: {uid}/{timestamp}.{ext}
      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = '$uid/$ts.$fileExt';

      await _client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentTypeFor(fileExt),
            ),
          );

      final publicUrl =
          _client.storage.from('avatars').getPublicUrl(path);
      return Success(publicUrl);
    } catch (e, st) {
      AppLogger.e('uploadAvatar error', e, st);
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  String _contentTypeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
