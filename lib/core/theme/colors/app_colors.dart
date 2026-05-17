import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_semantic_colors.dart';

/// ARACIYOK renk sistemine giriş noktası.
///
/// YENİ KOD: `AppPalette.navy800`, `AppSemanticColors.light` kullan.
/// ESKİ KOD: `AppColors.ink900` hâlâ çalışır ama @Deprecated uyarısı verir.
///
/// Tüm yeni kodlarda doğrudan `AppPalette` veya `AppSemanticColors`
/// kullan. Bu class sadece migration sürecinde geriye uyumluluk içindir.
class AppColors {
  AppColors._();

  // ── Geriye uyumluluk — eski token hâlâ çalışır ────────────────

  // Eski :root token'ları
  @Deprecated('Use AppPalette.ink50 instead')
  static const Color background = Color(AppPalette.ink50);

  @Deprecated('Use AppPalette.ink100 instead')
  static const Color surface = Color(AppPalette.ink100);

  @Deprecated('Use AppPalette.white via AppPalette')
  static const Color surfaceCard = Color(AppPalette.white);

  @Deprecated('Use AppPalette.ink900')
  static const Color textPrimary = Color(AppPalette.ink900);

  @Deprecated('Use AppPalette.ink700')
  static const Color textSecondary = Color(AppPalette.ink700);

  @Deprecated('Use AppPalette.ink500')
  static const Color textMuted = Color(AppPalette.ink500);

  @Deprecated('Use AppPalette.ink300')
  static const Color border = Color(AppPalette.ink300);

  @Deprecated('Use AppPalette.navy800')
  static const Color primary = Color(AppPalette.navy800);

  @Deprecated('Use AppPalette.white')
  static const Color primaryText = Color(AppPalette.white);

  @Deprecated('Use AppPalette.blue600')
  static const Color accentBlue = Color(AppPalette.blue600);

  @Deprecated('Use AppPalette.green600')
  static const Color success = Color(AppPalette.green600);

  @Deprecated('Use AppPalette.gold600')
  static const Color warning = Color(AppPalette.gold600);

  @Deprecated('Use AppPalette.red600')
  static const Color danger = Color(AppPalette.red600);

  // Semantik arka planlar
  @Deprecated('Use AppPalette.green100')
  static const Color successBg = Color(AppPalette.green100);

  @Deprecated('Use AppPalette.gold100')
  static const Color warningBg = Color(AppPalette.gold100);

  @Deprecated('Use AppPalette.red100')
  static const Color dangerBg = Color(AppPalette.red100);

  @Deprecated('Use AppPalette.blue100')
  static const Color accentBlueBg = Color(AppPalette.blue100);

  // Eski neutral kademesi
  @Deprecated('Use AppPalette.ink900')
  static const Color black = Color(AppPalette.ink900);

  @Deprecated('Use AppPalette.white')
  static const Color white = Color(AppPalette.white);

  @Deprecated('Use AppPalette.ink900')
  static const Color ink900 = Color(AppPalette.ink900);

  @Deprecated('Use AppPalette.ink800')
  static const Color ink800 = Color(AppPalette.ink800);

  @Deprecated('Use AppPalette.ink700')
  static const Color ink700 = Color(AppPalette.ink700);

  @Deprecated('Use AppPalette.ink600')
  static const Color ink600 = Color(AppPalette.ink600);

  @Deprecated('Use AppPalette.ink500')
  static const Color ink500 = Color(AppPalette.ink500);

  @Deprecated('Use AppPalette.ink400')
  static const Color ink400 = Color(AppPalette.ink400);

  @Deprecated('Use AppPalette.ink300')
  static const Color ink300 = Color(AppPalette.ink300);

  @Deprecated('Use AppPalette.ink200')
  static const Color ink200 = Color(AppPalette.ink200);

  @Deprecated('Use AppPalette.ink100')
  static const Color ink100 = Color(AppPalette.ink100);

  @Deprecated('Use AppPalette.ink50')
  static const Color ink50 = Color(AppPalette.ink50);

  // Dark tema eski
  @Deprecated('Use AppSemanticColors.dark.background')
  static const Color darkBg = Color(AppPalette.navy900);

  @Deprecated('Use AppSemanticColors.dark.surface')
  static const Color darkSurface = Color(AppPalette.navy800);

  @Deprecated('Use AppSemanticColors.dark.surfaceElevated')
  static const Color darkSurfaceAlt = Color(AppPalette.navy700);

  @Deprecated('Use AppSemanticColors.dark.border')
  static const Color darkBorder = Color(AppPalette.navy500);

  @Deprecated('Use AppSemanticColors.dark.textPrimary')
  static const Color darkTextPrimary = Color(AppPalette.white);

  @Deprecated('Use AppSemanticColors.dark.textSecondary')
  static const Color darkTextSecondary = Color(AppPalette.navy200);

  @Deprecated('Use AppSemanticColors.dark.textMuted')
  static const Color darkTextMuted = Color(AppPalette.navy500);

  // Durum renkleri
  @Deprecated('Use AppPalette.blue600')
  static const Color statusOpen = Color(AppPalette.blue600);
  @Deprecated('Use AppPalette.ink700')
  static const Color statusAccepted = Color(AppPalette.ink700);
  @Deprecated('Use AppPalette.amber500')
  static const Color statusInProgress = Color(AppPalette.amber500);
  @Deprecated('Use AppPalette.green600')
  static const Color statusCompleted = Color(AppPalette.green600);
  @Deprecated('Use AppPalette.ink500')
  static const Color statusCancelled = Color(AppPalette.ink500);

  // Diğer
  @Deprecated('Use AppPalette.transparent')
  static const Color transparent = Color(AppPalette.transparent);
  @Deprecated('Use 0x73000000 directly')
  static const Color overlay = Color(0x73000000);
  @Deprecated('Use 0x1F000000 directly')
  static const Color overlayLight = Color(0x1F000000);

  // Semantic (light) — eski AppSemanticColors referansı
  @Deprecated('Use AppSemanticColors.light')
  static const AppSemanticColors semanticLight = AppSemanticColors.light;

  @Deprecated('Use AppSemanticColors.dark')
  static const AppSemanticColors semanticDark = AppSemanticColors.dark;
}
