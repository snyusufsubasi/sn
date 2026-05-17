

/// Geriye uyumluluk katmanı.
///
/// YENİ KOD: `AppSpacing.lg`, `AppRadius.lg`, `AppDuration.normal` kullan.
/// ESKİ KOD: Hâlâ çalışır ama @Deprecated uyarısı alırsın.
class AppDimens {
  AppDimens._();
}

/// Geriye uyumluluk — eski AppSpacing.
@Deprecated('Use AppSpacing instead')
class AppSpacingOld {
  AppSpacingOld._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double massive = 64;
  static const double pageHorizontal = 20;
  static const double sectionGap = 32;
}

/// Geriye uyumluluk — eski AppRadius.
@Deprecated('Use AppRadius instead')
class AppRadiusOld {
  AppRadiusOld._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double pill = 999;
}

/// Geriye uyumluluk — eski AppIconSize.
@Deprecated('Use AppIconSize instead')
class AppIconSizeOld {
  AppIconSizeOld._();
  static const double xs = 14;
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 28;
  static const double xl = 36;
}
