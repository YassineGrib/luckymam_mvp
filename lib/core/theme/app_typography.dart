import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Locale-aware typography — IBM Plex Sans Arabic for Arabic, Outfit for Latin.
abstract final class AppTypography {
  static bool isArabic(Locale locale) => locale.languageCode == 'ar';

  static TextStyle style(
    Locale locale, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final arabic = isArabic(locale);
    final spacing = letterSpacing ?? (arabic ? 0.0 : null);
    final lineHeight = height ?? (arabic ? 1.5 : null);

    if (arabic) {
      return TextStyle(
        fontFamily: AppFonts.arabic,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: spacing,
        height: lineHeight,
      );
    }

    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle fromContext(
    BuildContext context, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return style(
      Localizations.localeOf(context),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextTheme textTheme({
    required Locale locale,
    required bool isDark,
  }) {
    final textColor =
        isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    TextStyle t({
      required double size,
      FontWeight weight = FontWeight.normal,
      Color? color,
      double? letterSpacing,
    }) {
      return style(
        locale,
        fontSize: size,
        fontWeight: weight,
        color: color ?? textColor,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      displayLarge: t(size: 57, weight: FontWeight.bold, letterSpacing: -0.25),
      displayMedium: t(size: 45, weight: FontWeight.bold),
      displaySmall: t(size: 36, weight: FontWeight.w600),
      headlineLarge: t(size: 32, weight: FontWeight.w600),
      headlineMedium: t(size: 28, weight: FontWeight.w600),
      headlineSmall: t(size: 24, weight: FontWeight.w600),
      titleLarge: t(size: 22, weight: FontWeight.w600),
      titleMedium: t(size: 16, weight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: t(size: 14, weight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: t(size: 16, letterSpacing: 0.5),
      bodyMedium: t(size: 14, letterSpacing: 0.25),
      bodySmall: t(size: 12, color: secondaryColor, letterSpacing: 0.4),
      labelLarge: t(size: 14, weight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: t(size: 12, weight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: t(
        size: 11,
        weight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Active font family name for the given locale (debug / theming).
  static String familyFor(Locale locale) =>
      isArabic(locale) ? AppFonts.arabic : AppFonts.latin;
}
