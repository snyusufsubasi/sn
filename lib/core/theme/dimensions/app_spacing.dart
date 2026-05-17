import 'package:flutter/material.dart';

import '../colors/app_palette.dart';

/// ARACIYOK geometri tokenları.
///
/// 4px grid bazlı spacing, radius, elevation sistemi.
class AppSpacing {
  AppSpacing._();

  // ── Spacing (4px grid) ─────────────────────────────────────────
  static const double quarks = 2;        // İkon ile text arası
  static const double xs = 4;            // Minimal boşluk
  static const double sm = 8;            // Element içi
  static const double md = 12;           // Element arası
  static const double lg = 16;           // Bölüm içi
  static const double xl = 20;           // Bölüm arası
  static const double xxl = 24;          // Section arası
  static const double xxxl = 32;         // Büyük bölüm arası
  static const double huge = 48;         // Sayfa içi büyük boşluk
  static const double massive = 64;      // Sayfa başı / sonu

  // ── Özel boyutlar ──────────────────────────────────────────────
  /// Sayfa kenar boşluğu (24px — daha ferah)
  static const double pageHorizontal = 24;

  /// Kart içi standart padding (20px)
  static const double cardPadding = 20;

  /// Küçük kartlar için padding (14px)
  static const double cardPaddingSmall = 14;

  /// Minimum dokunma hedefi boyutu (48px)
  static const double touchTarget = 48;

  /// Section'lar arası dikey boşluk (32px)
  static const double sectionGap = 32;

  /// Liste öğeleri arası boşluk (12px)
  static const double listItemGap = 12;
}

/// Yuvarlatılmış köşe radius'ları.
class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double xs = 4;      // Avatar, küçük badge
  static const double sm = 8;      // Input içi element
  static const double md = 12;     // Buton, input
  static const double lg = 16;     // Kart, card
  static const double xl = 20;     // Bottom sheet üst köşe
  static const double xxl = 28;    // Dialog, modal
  static const double pill = 999;  // Tam yuvarlak
}

/// İkon boyutları.
class AppIconSize {
  AppIconSize._();

  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
  static const double xl = 40;
  static const double hero = 56;
}

/// Gölge / elevation sistemi.
///
/// ```dart
/// Container(
///   decoration: AppElevation.cardDecoration(elevation: 4),
///   child: ...
/// )
/// ```
class AppElevation {
  AppElevation._();

  static const int none = 0;
  static const int low = 1;       // Kart
  static const int medium = 4;    // Sheet, modal
  static const int high = 8;      // FAB, sticky
  static const int highest = 16;  // Dialog

  /// Kart/container için hazır gölgeli dekorasyon.
  static BoxDecoration cardDecoration({
    int elevation = AppElevation.low,
    Color? color,
    double radius = AppRadius.lg,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? const Color(AppPalette.ink100),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: elevation > 0 ? _shadows(elevation) : null,
      border: borderColor != null
          ? Border.all(color: borderColor)
          : null,
    );
  }

  static List<BoxShadow> _shadows(int elevation) {
    final c = const Color(AppPalette.ink900).withOpacity(0.08);
    switch (elevation) {
      case 1:
        return [BoxShadow(blurRadius: 2, offset: const Offset(0, 1), color: c)];
      case 4:
        return [
          BoxShadow(blurRadius: 4, offset: const Offset(0, 2), color: c),
          BoxShadow(blurRadius: 12, offset: const Offset(0, 4), color: c.withOpacity(0.04)),
        ];
      case 8:
        return [
          BoxShadow(blurRadius: 8, offset: const Offset(0, 4), color: c),
          BoxShadow(blurRadius: 24, offset: const Offset(0, 8), color: c.withOpacity(0.08)),
        ];
      case 16:
        return [
          BoxShadow(blurRadius: 16, offset: const Offset(0, 8), color: c),
          BoxShadow(blurRadius: 48, offset: const Offset(0, 16), color: c.withOpacity(0.12)),
        ];
      default:
        return [];
    }
  }
}
