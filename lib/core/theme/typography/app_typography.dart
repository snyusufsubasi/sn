import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ARACIYOK tipografi sistemi.
///
/// Başlıklar: Plus Jakarta Sans (sıcak, yuvarlak, premium)
/// Gövde: Inter (en okunaklı, nötr)
///
/// 40+ kullanıcı için optimize boyutlar: tüm boyutlar 1-2px büyütüldü,
/// satır yükseklikleri artırıldı, kalınlıklar düşürüldü.
class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme({
    Color headingColor = const Color(0xFF1A1A1A),
    Color bodyColor = const Color(0xFF4A4A4A),
    Color bodyMutedColor = const Color(0xFF8E8E8E),
    Color labelColor = const Color(0xFF1A1A1A),
  }) {
    return TextTheme(
      // ── Display — splash, büyük landing ──────────────────────
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: headingColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: headingColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: headingColor,
      ),

      // ── Headline — sayfa başlıkları ──────────────────────────
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: headingColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: headingColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: headingColor,
      ),

      // ── Title — kart başlıkları, section başlıkları ──────────
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: headingColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: headingColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: headingColor,
      ),

      // ── Body — okuma metni (Inter, düşük weight) ────────────
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: bodyMutedColor,
      ),

      // ── Label — buton, chip, küçük UI ───────────────────────
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
        color: labelColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.1,
        color: bodyColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.3,
        color: bodyMutedColor,
      ),
    );
  }
}
