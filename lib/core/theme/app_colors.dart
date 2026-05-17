import 'package:flutter/material.dart';

/// ARACIYOK tasarım sistemi — renk tokenları.
/// Kaynak: Uber-benzeri CSS değişkenleri (`:root` paleti).
///
/// Kullanım: doğrudan referans yok; `AppTheme` ve `AppSemanticColors` üzerinden.
class AppColors {
  AppColors._();

  // —— :root tokenları (birebir) ——
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F6F6);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF545454);
  static const Color textMuted = Color(0xFF8A8A8A);

  static const Color border = Color(0xFFE5E5E5);

  static const Color primary = Color(0xFF000000);
  static const Color primaryText = Color(0xFFFFFFFF);

  static const Color accentBlue = Color(0xFF276EF1);
  static const Color success = Color(0xFF47B275);
  static const Color warning = Color(0xFFFFC043);
  static const Color danger = Color(0xFFF25138);

  // Semantik arka plan tonları (token + beyaz karışımı)
  static const Color successBg = Color(0xFFE8F7EF);
  static const Color warningBg = Color(0xFFFFF6E0);
  static const Color dangerBg = Color(0xFFFEEEEB);
  static const Color accentBlueBg = Color(0xFFEEF4FE);

  // Geriye uyumluluk / kademeli geçiş
  static const Color brandPrimary = primary;
  static const Color brandPrimaryDark = primary;
  static const Color brandPrimaryLight = accentBlueBg;
  static const Color brandPrimaryBg = surface;

  // Nötr kademe (token’lara hizalı)
  static const Color black = textPrimary;
  static const Color white = background;
  static const Color ink900 = textPrimary;
  static const Color ink800 = Color(0xFF262626);
  static const Color ink700 = textSecondary;
  static const Color ink600 = textSecondary;
  static const Color ink500 = textMuted;
  static const Color ink400 = Color(0xFFADADAD);
  static const Color ink300 = Color(0xFFD4D4D4);
  static const Color ink200 = border;
  static const Color ink100 = Color(0xFFF0F0F0);
  static const Color ink50 = surface;

  // Dark (light token seti dışı — sistem dark için)
  static const Color darkBg = Color(0xFF0B0B0B);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceAlt = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFD4D4D4);
  static const Color darkTextMuted = Color(0xFFA3A3A3);

  static const Color error = danger;
  static const Color errorBg = dangerBg;
  static const Color info = accentBlue;
  static const Color infoBg = accentBlueBg;
  static const Color star = warning;

  // Durum (semantik; dekoratif geniş alan yok)
  static const Color statusOpen = accentBlue;
  static const Color statusAccepted = textSecondary;
  static const Color statusInProgress = warning;
  static const Color statusCompleted = success;
  static const Color statusCancelled = textMuted;

  // Overlay / harita
  static const Color transparent = Color(0x00000000);
  static const Color overlay = Color(0x73000000);
  static const Color overlayLight = Color(0x1F000000);
  static const Color mapRoute = primary;
  static const Color mapMarkerActive = primary;
  static const Color mapMarkerMuted = textMuted;

  static const AppSemanticColors semanticLight = AppSemanticColors(
    background: background,
    surface: surfaceCard,
    surfaceSubtle: surface,
    border: border,
    divider: ink100,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    accent: accentBlue,
    accentSubtle: accentBlueBg,
    cta: primary,
    onCta: primaryText,
    error: danger,
    errorSubtle: dangerBg,
    success: success,
    successSubtle: successBg,
    warning: warning,
    warningSubtle: warningBg,
    info: accentBlue,
    infoSubtle: accentBlueBg,
  );

  static const AppSemanticColors semanticDark = AppSemanticColors(
    background: darkBg,
    surface: darkSurface,
    surfaceSubtle: darkSurfaceAlt,
    border: darkBorder,
    divider: darkBorder,
    textPrimary: darkTextPrimary,
    textSecondary: darkTextSecondary,
    textMuted: darkTextMuted,
    accent: accentBlue,
    accentSubtle: Color(0xFF1A2F4D),
    cta: darkTextPrimary,
    onCta: darkBg,
    error: Color(0xFFFF7A6B),
    errorSubtle: Color(0xFF3A1D1D),
    success: Color(0xFF6FD49A),
    successSubtle: Color(0xFF193126),
    warning: Color(0xFFFFD06B),
    warningSubtle: Color(0xFF342A17),
    info: Color(0xFF5B9BFF),
    infoSubtle: Color(0xFF1C2B39),
  );
}

class AppSemanticColors {
  const AppSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSubtle,
    required this.cta,
    required this.onCta,
    required this.error,
    required this.errorSubtle,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.info,
    required this.infoSubtle,
  });

  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSubtle;
  final Color cta;
  final Color onCta;
  final Color error;
  final Color errorSubtle;
  final Color success;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color info;
  final Color infoSubtle;
}
