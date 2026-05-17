

/// ARACIYOK animasyon süreleri.
///
/// Felsefe: 40+ kullanıcı için daha yavaş, daha yumuşak geçişler.
/// Hiçbir şey ani olmamalı — her geçiş kullanıcıya "kontrol bende"
/// hissi vermeli.
class AppDuration {
  AppDuration._();

  /// Basılı his — tap feedback, hover (50ms)
  static const Duration instant = Duration(milliseconds: 50);

  /// Hızlı geçişler — chip state, renk değişimi (200ms)
  static const Duration fast = Duration(milliseconds: 200);

  /// Standart geçiş — kart açılma, liste öğesi (350ms)
  static const Duration normal = Duration(milliseconds: 350);

  /// Sayfa geçişleri, bottom sheet (500ms)
  static const Duration slow = Duration(milliseconds: 500);

  /// Modal, dialog, kasıtlı animasyonlar (800ms)
  static const Duration deliberate = Duration(milliseconds: 800);

  /// Shimmer / skeleton döngüsü (2000ms — sakin)
  static const Duration shimmer = Duration(milliseconds: 2000);
}
