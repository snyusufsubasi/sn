import '../../../../core/errors/result.dart';

abstract class AuthRepository {
  /// Mevcut kullanıcı id'si veya null.
  String? get currentUserId;

  /// Oturum var mı?
  bool get isSignedIn;

  /// Auth state stream — splash/router için.
  Stream<bool> get authStateChanges;

  /// Telefon numarasına OTP gönder.
  Future<Result<void>> sendOtp({required String phoneE164});

  /// OTP doğrula. Başarılı olunca yeni user id döner.
  Future<Result<String>> verifyOtp({
    required String phoneE164,
    required String otp,
  });

  /// Oturumu sonlandır.
  Future<Result<void>> signOut();

  /// Kullanıcının `profiles` tablosunda kaydı var mı? (Profile setup gerekli mi?)
  Future<Result<bool>> hasCompletedProfile(String userId);
}
