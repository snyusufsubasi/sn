import 'package:flutter/material.dart';

/// Uber-esque tasarım sisteminin geometri tokenları.
class AppSpacing {
  AppSpacing._();
  // 4'lük grid
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

  // Yatay sayfa kenar boşluğu standardı
  static const double pageHorizontal = 20;

  // Component arası dikey boşluk
  static const double sectionGap = 32;
}

class AppRadius {
  AppRadius._();
  // Uber'in radius'u büyük; tüm primary surface'lerde 12-16dp.
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double pill = 999;
}

class AppIconSize {
  AppIconSize._();
  static const double xs = 14;
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 28;
  static const double xl = 36;
}

class AppDuration {
  AppDuration._();
  // Uber benzeri motion: hızlı, net, bounce'suz.
  static const Duration micro = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration deliberate = Duration(milliseconds: 480);
}

class AppMotion {
  AppMotion._();

  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasized = Cubic(0.3, 0.0, 0.0, 1.0);
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

abstract class AppText {
  static TextStyle get labelXS =>
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
  static TextStyle get labelSM =>
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get caption =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle get captionBold =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get numeric =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
}
