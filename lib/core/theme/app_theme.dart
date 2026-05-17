import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors/app_palette.dart';
import 'colors/app_semantic_colors.dart';
import 'dimensions/app_spacing.dart';
import 'typography/app_typography.dart';

/// ARACIYOK tema fabrikası.
///
/// Light tema: sıcak beyaz arka plan, lacivert CTA, kehribar accent
/// Dark tema: koyu lacivert arka plan, kehribar CTA, aynı accent
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      semantic: AppSemanticColors.light,
      overlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      semantic: AppSemanticColors.dark,
      overlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors semantic,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
    );
    final textTheme = AppTypography.buildTextTheme(
      headingColor: semantic.textPrimary,
      bodyColor: semantic.textSecondary,
      bodyMutedColor: semantic.textMuted,
      labelColor: semantic.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: semantic.background,
      canvasColor: semantic.background,
      extensions: [semantic],
      colorScheme: _colorScheme(brightness: brightness, semantic: semantic),
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.background,
        foregroundColor: semantic.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: semantic.textPrimary,
        ),
        iconTheme: const IconThemeData(size: 24),
        systemOverlayStyle: overlayStyle,
        surfaceTintColor: Color(AppPalette.transparent),
      ),

      // ── Bottom Navigation ─────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: semantic.surface,
        selectedItemColor: semantic.textPrimary,
        unselectedItemColor: semantic.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: semantic.surface,
        elevation: 0,
        indicatorColor: semantic.border,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? semantic.textPrimary
                : semantic.textMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),

      // ── Butonlar ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: semantic.cta,
          foregroundColor: semantic.ctaText,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: AppElevation.low.toDouble(),
          shadowColor: semantic.textPrimary.withOpacity(0.15),
          textStyle: textTheme.labelLarge?.copyWith(color: semantic.ctaText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: semantic.textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: semantic.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: semantic.textPrimary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: semantic.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: semantic.textSecondary),
        floatingLabelStyle:
            textTheme.bodyMedium?.copyWith(color: semantic.textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: semantic.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: semantic.cta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: semantic.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: semantic.error, width: 1.5),
        ),
        errorStyle: textTheme.labelSmall?.copyWith(color: semantic.error),
      ),

      // ── Kart ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: AppElevation.low.toDouble(),
        color: semantic.surface,
        surfaceTintColor: Color(AppPalette.transparent),
        shadowColor: semantic.textPrimary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: semantic.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: semantic.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ──────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: semantic.surface,
        selectedColor: semantic.cta,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: semantic.ctaText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.surface,
        surfaceTintColor: Color(AppPalette.transparent),
        elevation: AppElevation.medium.toDouble(),
        modalElevation: AppElevation.medium.toDouble(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        showDragHandle: true,
        dragHandleColor: semantic.border,
      ),

      // ── Dialog ────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: semantic.surfaceElevated,
        surfaceTintColor: Color(AppPalette.transparent),
        elevation: AppElevation.highest.toDouble(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── SnackBar ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: semantic.textPrimary,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: semantic.ctaText),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ── Genel ─────────────────────────────────────────────────
      splashColor: semantic.accentBg,
      highlightColor: semantic.accentBg,
      iconTheme: IconThemeData(color: semantic.textPrimary, size: 24),
      dividerColor: semantic.divider,
      disabledColor: semantic.textMuted,

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: semantic.cta,
        foregroundColor: semantic.ctaText,
        elevation: AppElevation.medium.toDouble(),
      ),

      // ── Page transitions ──────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Material 3 ColorScheme — nötr tonlar, otomatik tint yok.
  static ColorScheme _colorScheme({
    required Brightness brightness,
    required AppSemanticColors semantic,
  }) {
    final isDark = brightness == Brightness.dark;
    return ColorScheme(
      brightness: brightness,
      primary: semantic.cta,
      onPrimary: semantic.ctaText,
      primaryContainer: semantic.accentBg,
      onPrimaryContainer: semantic.textPrimary,
      secondary: semantic.accent,
      onSecondary: semantic.ctaText,
      secondaryContainer: semantic.accentBg,
      onSecondaryContainer: semantic.textPrimary,
      tertiary: semantic.textMuted,
      onTertiary: semantic.ctaText,
      error: semantic.error,
      onError: semantic.ctaText,
      errorContainer: semantic.errorBg,
      onErrorContainer: semantic.error,
      surface: semantic.surface,
      onSurface: semantic.textPrimary,
      surfaceDim: semantic.background,
      surfaceBright: semantic.surface,
      surfaceContainerLowest: semantic.background,
      surfaceContainerLow: semantic.surface,
      surfaceContainer: semantic.surface,
      surfaceContainerHigh: semantic.surface,
      surfaceContainerHighest: semantic.border,
      onSurfaceVariant: semantic.textSecondary,
      outline: semantic.border,
      outlineVariant: semantic.divider,
      shadow: semantic.textPrimary,
      scrim: semantic.textPrimary.withOpacity(0.4),
      inverseSurface: isDark ? const Color(AppPalette.ink50) : const Color(AppPalette.ink800),
      onInverseSurface: isDark ? const Color(AppPalette.ink800) : const Color(AppPalette.ink50),
      inversePrimary: semantic.ctaText,
    );
  }
}
