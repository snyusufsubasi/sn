import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Uber tipografi sistemi — Inter font, ağır weight'ler başlıklarda.
class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme({
    Color headingColor = AppColors.ink900,
    Color bodyColor = AppColors.ink700,
    Color bodyMutedColor = AppColors.ink600,
    Color labelColor = AppColors.ink900,
  }) {
    return TextTheme(
      // Display — splash, büyük landing başlıkları
      displayLarge: GoogleFonts.interTight(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
        color: headingColor,
      ),
      displayMedium: GoogleFonts.interTight(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        height: 1.15,
        color: headingColor,
      ),
      displaySmall: GoogleFonts.interTight(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
        color: headingColor,
      ),

      // Headline — sayfa başlıkları
      headlineLarge: GoogleFonts.interTight(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.25,
        color: headingColor,
      ),
      headlineMedium: GoogleFonts.interTight(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: headingColor,
      ),
      headlineSmall: GoogleFonts.interTight(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.35,
        color: headingColor,
      ),

      // Title — kart başlıkları, section başlıkları
      titleLarge: GoogleFonts.interTight(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: headingColor,
      ),
      titleMedium: GoogleFonts.interTight(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: headingColor,
      ),
      titleSmall: GoogleFonts.interTight(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: headingColor,
      ),

      // Body — okuma metni
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: bodyMutedColor,
      ),

      // Label — buton, chip, küçük UI metinleri
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
        color: labelColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
        color: bodyColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
        color: bodyMutedColor,
      ),
    );
  }
}
