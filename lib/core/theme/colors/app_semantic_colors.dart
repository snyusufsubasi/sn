import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Semantik renk haritası — light/dark tema için ayrı ayrı.
///
/// Kullanım: tema oluştururken bir kere üret, sonra widget'larda
/// `Theme.of(context).extension<AppSemanticColors>()` ile eriş.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.cta,
    required this.ctaText,
    required this.ctaHover,
    required this.accent,
    required this.accentBg,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
    required this.info,
    required this.infoBg,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color cta;
  final Color ctaText;
  final Color ctaHover;
  final Color accent;
  final Color accentBg;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;
  final Color info;
  final Color infoBg;

  /// Light tema — sıcak beyaz, lacivert CTA, kehribar accent
  static const light = AppSemanticColors(
    background: Color(AppPalette.ink50),
    surface: Color(AppPalette.ink100),
    surfaceElevated: Color(AppPalette.white),
    border: Color(AppPalette.ink300),
    divider: Color(AppPalette.ink200),
    textPrimary: Color(AppPalette.ink900),
    textSecondary: Color(AppPalette.ink700),
    textMuted: Color(AppPalette.ink500),
    cta: Color(AppPalette.navy800),
    ctaText: Color(AppPalette.white),
    ctaHover: Color(AppPalette.navy700),
    accent: Color(AppPalette.amber500),
    accentBg: Color(AppPalette.amber50),
    success: Color(AppPalette.green600),
    successBg: Color(AppPalette.green100),
    warning: Color(AppPalette.gold600),
    warningBg: Color(AppPalette.gold100),
    error: Color(AppPalette.red600),
    errorBg: Color(AppPalette.red100),
    info: Color(AppPalette.blue600),
    infoBg: Color(AppPalette.blue100),
  );

  /// Dark tema — koyu lacivert, beyaz metin, aynı accent
  static const dark = AppSemanticColors(
    background: Color(AppPalette.navy900),
    surface: Color(AppPalette.navy800),
    surfaceElevated: Color(AppPalette.navy700),
    border: Color(AppPalette.navy500),
    divider: Color(AppPalette.navy700),
    textPrimary: Color(AppPalette.white),
    textSecondary: Color(AppPalette.navy200),
    textMuted: Color(AppPalette.navy500),
    cta: Color(AppPalette.amber500),
    ctaText: Color(AppPalette.white),
    ctaHover: Color(AppPalette.amber400),
    accent: Color(AppPalette.amber400),
    accentBg: Color(AppPalette.navy700),
    success: Color(AppPalette.green600),
    successBg: Color(AppPalette.navy700),
    warning: Color(AppPalette.gold600),
    warningBg: Color(AppPalette.navy700),
    error: Color(AppPalette.red600),
    errorBg: Color(AppPalette.navy700),
    info: Color(AppPalette.blue600),
    infoBg: Color(AppPalette.navy700),
  );

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? cta,
    Color? ctaText,
    Color? ctaHover,
    Color? accent,
    Color? accentBg,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? error,
    Color? errorBg,
    Color? info,
    Color? infoBg,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      cta: cta ?? this.cta,
      ctaText: ctaText ?? this.ctaText,
      ctaHover: ctaHover ?? this.ctaHover,
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      cta: Color.lerp(cta, other.cta, t)!,
      ctaText: Color.lerp(ctaText, other.ctaText, t)!,
      ctaHover: Color.lerp(ctaHover, other.ctaHover, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
    );
  }
}
