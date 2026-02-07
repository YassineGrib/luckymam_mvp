import 'package:flutter/material.dart';

/// App color system with distinct dark and light mode palettes.
/// Dark mode: Pink/magenta accent (#A7316E)
/// Light mode: Warm coral accent (#E85A71)
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary pink/magenta for dark mode
  static const Color magentaPink = Color(0xFFA7316E);

  /// Warm coral for light mode
  static const Color coral = Color(0xFFE85A71);

  /// Teal accent
  static const Color smaltBlue = Color(0xFF4F8289);

  /// Cream/peach
  static const Color negroni = Color(0xFFFEE4C1);

  /// Near black
  static const Color oil = Color(0xFF130F0B);

  /// Soft green-white
  static const Color willowBrook = Color(0xFFE0EBDD);

  /// Soft orange
  static const Color hitPink = Color(0xFFFAB187);

  /// Gold
  static const Color goldenrod = Color(0xFFFED672);

  /// Orange
  static const Color casablanca = Color(0xFFF9AD4A);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primaryDark = magentaPink;
  static const Color onPrimaryDark = Colors.white;
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceContainerDark = Color(0xFF1E1E1E);
  static const Color onBackgroundDark = Colors.white;
  static const Color onSurfaceDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color inputBackgroundDark = Color(0xFF1E1E1E);
  static const Color inputBorderDark = Color(0xFF333333);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primaryLight = coral;
  static const Color onPrimaryLight = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceContainerLight = Color(0xFFF0F0F0);
  static const Color onBackgroundLight = Color(0xFF1A1A1A);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color inputBackgroundLight = Color(0xFFF0F0F0);
  static const Color inputBorderLight = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFE5E5E5);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = goldenrod;
  static const Color info = smaltBlue;

  // ═══════════════════════════════════════════════════════════════════════════
  // SOCIAL BUTTON COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color googleRed = Color(0xFFDB4437);
  static const Color appleDark = Color(0xFF000000);
  static const Color appleLight = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary button gradient (pink)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [magentaPink, Color(0xFFD64A8E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Background gradient for splash/onboarding (dark)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF1A0A10), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Soft gradient overlay
  static const LinearGradient softOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0x80000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
