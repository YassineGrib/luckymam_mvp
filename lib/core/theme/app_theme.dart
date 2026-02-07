import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
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
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: _buildAppBarTheme(isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      textButtonTheme: _buildTextButtonTheme(isDark: true),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: true),
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: _buildAppBarTheme(isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      textButtonTheme: _buildTextButtonTheme(isDark: false),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: false),
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
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme({required bool isDark}) {
    final Color textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final Color secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.outfit(
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

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
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
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
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
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme({required bool isDark}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.primaryDark
            : AppColors.primaryLight,
        textStyle: GoogleFonts.outfit(
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
      hintStyle: GoogleFonts.outfit(fontSize: 14, color: hintColor),
      labelStyle: GoogleFonts.outfit(fontSize: 14, color: hintColor),
      floatingLabelStyle: GoogleFonts.outfit(
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
