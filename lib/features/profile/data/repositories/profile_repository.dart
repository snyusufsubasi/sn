import 'dart:typed_data';

import '../../../../core/errors/result.dart';
import '../models/carrier_profile.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  /// Mevcut kullanıcının profilini getir.
  Future<Result<UserProfile?>> fetchCurrentProfile();

  /// Verilen kullanıcının profilini getir.
  Future<Result<UserProfile?>> fetchProfile(String userId);

  /// Yeni profil oluştur (ilk kez kayıt).
  Future<Result<UserProfile>> createProfile(UserProfile profile);

  /// Mevcut profili güncelle.
  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  /// Avatar yükle (Supabase Storage). Returns: public URL.
  ///
  /// [bytes] resmin byte verisi (image_picker'dan readAsBytes ile alınır)
  /// [fileExt] uzantı (örn. 'jpg', 'png')
  Future<Result<String>> uploadAvatar({
    required Uint8List bytes,
    required String fileExt,
  });

  /// Carrier profil bilgisi (sadece role=carrier için).
  Future<Result<CarrierProfile?>> fetchCarrierProfile(String userId);

  /// Carrier profil oluştur/güncelle.
  Future<Result<CarrierProfile>> upsertCarrierProfile(CarrierProfile profile);

  /// Telefon numarasını private tabloya kaydet.
  Future<Result<void>> savePhoneNumber({
    required String userId,
    required String phoneE164,
  });
}
