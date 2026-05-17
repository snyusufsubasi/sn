/// ARACIYOK Renk Sistemi — Tüm token'lar.
///
/// Tasarım felsefesi:
/// - Primary (Lacivert / Navy): Güven, profesyonellik, ciddiyet
/// - Accent (Kehribar / Amber): Anadolu sıcaklığı, enerji, dikkat
/// - Neutral (Sıcak Gri): Okunabilirlik, sadelik, ferahlık
///
/// Kullanım: doğrudan bu class üzerinden. Semantic wrapper'lar
/// için AppSemanticColors'a bak.
class AppPalette {
  AppPalette._();

  // ── Primary — Lacivert Serisi (Güven) ──────────────────────────
  /// En koyu lacivert — navbar, footer, çok koyu alanlar
  static const int _navy900 = 0xFF0F1A30;
  /// Primary buton, CTA, ana vurgu
  static const int _navy800 = 0xFF1B2A4A;
  /// Aktif state, hover
  static const int _navy700 = 0xFF2A3D63;
  /// Vurgulu border, focus indicator
  static const int _navy600 = 0xFF405A82;
  /// Disabled buton, soluk vurgu
  static const int _navy500 = 0xFF6A82A8;
  /// İkincil border
  static const int _navy200 = 0xFFC4D0E0;
  /// Arka plan tonu
  static const int _navy100 = 0xFFE8EDF5;
  /// En hafif arka plan
  static const int _navy50 = 0xFFF4F7FC;

  static const int navy900 = _navy900;
  static const int navy800 = _navy800;
  static const int navy700 = _navy700;
  static const int navy600 = _navy600;
  static const int navy500 = _navy500;
  static const int navy200 = _navy200;
  static const int navy100 = _navy100;
  static const int navy50 = _navy50;

  // ── Accent — Kehribar Serisi (Sıcaklık) ────────────────────────
  /// Basılı durum / koyu kehribar
  static const int amber600 = 0xFFB86520;
  /// Ana accent rengi — fırsatlar, öne çıkan aksiyonlar, badge
  static const int amber500 = 0xFFD4782E;
  /// Vurgulu badge, ikincil accent
  static const int amber400 = 0xFFE8873A;
  /// Accent arka planı (soft)
  static const int amber200 = 0xFFF5D7B8;
  /// En sıcak arka plan (çok açık krem)
  static const int amber50 = 0xFFFDF5ED;

  // ── Neutral — Sıcak Gri Serisi ─────────────────────────────────
  /// Ana metin rengi (neredeyse siyah)
  static const int ink900 = 0xFF1A1A1A;
  /// İkincil metin, kalın başlıklar
  static const int ink800 = 0xFF2E2E2E;
  /// Label metni, gövde
  static const int ink700 = 0xFF4A4A4A;
  /// Muted metin, helper text
  static const int ink600 = 0xFF6B6B6B;
  /// Placeholder metin
  static const int ink500 = 0xFF8E8E8E;
  /// Disabled border
  static const int ink400 = 0xFFB0B0B0;
  /// Border, ayraç
  static const int ink300 = 0xFFD1D1D1;
  /// Divider, ince çizgiler
  static const int ink200 = 0xFFE8E8E8;
  /// Card arka planı, input bg
  static const int ink100 = 0xFFF5F5F0;
  /// Sayfa arka planı (sıcak beyaz)
  static const int ink50 = 0xFFFAFAF7;

  // ── Semantic — Durum Renkleri ──────────────────────────────────
  /// Başarı, tamamlandı
  static const int green600 = 0xFF2D7D46;
  /// Başarı arka plan
  static const int green100 = 0xFFE8F5EC;
  /// Uyarı, beklemede
  static const int gold600 = 0xFFD4A02B;
  /// Uyarı arka plan
  static const int gold100 = 0xFFFDF4E0;
  /// Hata, iptal
  static const int red600 = 0xFFC94A3C;
  /// Hata arka plan
  static const int red100 = 0xFFFCEAE7;
  /// Bilgi, açık ilan
  static const int blue600 = 0xFF3A7BBF;
  /// Bilgi arka plan
  static const int blue100 = 0xFFEBF2FA;

  // ── Sabit Beyaz / Siyah ────────────────────────────────────────
  static const int white = 0xFFFFFFFF;
  static const int black = 0xFF000000;
  static const int transparent = 0x00000000;
}
