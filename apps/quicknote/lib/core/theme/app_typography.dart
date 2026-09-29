import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography matching Apple Glassmorphic Luxury aesthetic:
/// - Plus Jakarta Sans: Distinctive, modern luxury geometric sans-serif for UI, titles, and body.
/// - Vazirmatn: Elegant Persian font family fallback for Persian/Arabic text.
/// - JetBrains Mono: Monospace for code blocks and snippets.
class AppTypography {
  static final String? _vazir = GoogleFonts.vazirmatn().fontFamily;
  static List<String> get _persianFallback => _vazir != null ? [_vazir!] : const [];

  static TextStyle display(Color color, {double size = 32, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.03 * size,
    ).copyWith(fontFamilyFallback: _persianFallback);
  }

  static TextStyle headline(Color color, {double size = 22, FontWeight weight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.02 * size,
    ).copyWith(fontFamilyFallback: _persianFallback);
  }

  static TextStyle title(Color color, {double size = 15, FontWeight weight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.01 * size,
    ).copyWith(fontFamilyFallback: _persianFallback);
  }

  static TextStyle body(Color color, {double size = 14, FontWeight weight = FontWeight.w400, FontStyle? fontStyle}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.5,
      fontStyle: fontStyle,
      letterSpacing: -0.005 * size,
    ).copyWith(fontFamilyFallback: _persianFallback);
  }

  static TextStyle caption(Color color, {double size = 11, FontWeight weight = FontWeight.w500, FontStyle? fontStyle}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: 0.02 * size,
    ).copyWith(fontFamilyFallback: _persianFallback);
  }

  static TextStyle code(Color color, {double size = 12, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.5,
    ).copyWith(fontFamilyFallback: _persianFallback);
  }
}
