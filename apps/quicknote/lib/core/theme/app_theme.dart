import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final String? _primaryFont = GoogleFonts.plusJakartaSans().fontFamily;
  static final List<String> _fallbacks = [GoogleFonts.vazirmatn().fontFamily!];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _primaryFont,
      fontFamilyFallback: _fallbacks,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        secondary: AppColors.darkSecondary,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _primaryFont,
      fontFamilyFallback: _fallbacks,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        secondary: AppColors.lightSecondary,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
      ),
    );
  }
}
