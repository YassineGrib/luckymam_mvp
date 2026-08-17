// Flutter 3.44 moved CupertinoPageTransitionsBuilder out of material.dart —
// it now lives in the cupertino library.
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// App theme with dark-first design matching the reference UI.
/// Features soft rounded corners, premium feel, and accessibility-compliant contrasts.
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON VALUES
  // ═══════════════════════════════════════════════════════════════════════════

  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusSmall = 8.0;

  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData darkTheme(Locale locale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.familyFor(locale),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        secondary: AppColors.smaltBlue,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(locale: locale, isDark: true),
      appBarTheme: _buildAppBarTheme(locale: locale, isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(locale),
      outlinedButtonTheme: _buildOutlinedButtonTheme(locale: locale, isDark: true),
      textButtonTheme: _buildTextButtonTheme(locale: locale, isDark: true),
      inputDecorationTheme: _buildInputDecorationTheme(locale: locale, isDark: true),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.onSurfaceDark),
      pageTransitionsTheme: _buildPageTransitions(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData lightTheme(Locale locale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.familyFor(locale),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        secondary: AppColors.smaltBlue,
        onSecondary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme(locale: locale, isDark: false),
      appBarTheme: _buildAppBarTheme(locale: locale, isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(locale),
      outlinedButtonTheme: _buildOutlinedButtonTheme(locale: locale, isDark: false),
      textButtonTheme: _buildTextButtonTheme(locale: locale, isDark: false),
      inputDecorationTheme: _buildInputDecorationTheme(locale: locale, isDark: false),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.onSurfaceLight),
      pageTransitionsTheme: _buildPageTransitions(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TRANSITIONS (Soft fade + slide)
  // ═══════════════════════════════════════════════════════════════════════════

  static PageTransitionsTheme _buildPageTransitions() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static AppBarTheme _buildAppBarTheme({
    required Locale locale,
    required bool isDark,
  }) {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTypography.style(
        locale,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Locale locale) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.magentaPink,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        textStyle: AppTypography.style(
          locale,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    required Locale locale,
    required bool isDark,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.onSurfaceDark
            : AppColors.onSurfaceLight,
        minimumSize: const Size(double.infinity, buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(
          color: isDark
              ? AppColors.inputBorderDark
              : AppColors.inputBorderLight,
        ),
        textStyle: AppTypography.style(
          locale,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme({
    required Locale locale,
    required bool isDark,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.primaryDark
            : AppColors.primaryLight,
        textStyle: AppTypography.style(
          locale,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATION THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static InputDecorationTheme _buildInputDecorationTheme({
    required Locale locale,
    required bool isDark,
  }) {
    final fillColor = isDark
        ? AppColors.inputBackgroundDark
        : AppColors.inputBackgroundLight;
    final borderColor = isDark
        ? AppColors.inputBorderDark
        : AppColors.inputBorderLight;
    final hintColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: AppTypography.style(locale, fontSize: 14, color: hintColor),
      labelStyle: AppTypography.style(locale, fontSize: 14, color: hintColor),
      floatingLabelStyle: AppTypography.style(
        locale,
        fontSize: 12,
        color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}
