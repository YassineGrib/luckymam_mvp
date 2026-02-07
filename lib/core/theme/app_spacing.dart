/// Consistent spacing system based on 8dp grid.
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double unit = 8.0;

  // Common spacing values
  static const double xxs = 4.0; // unit * 0.5
  static const double xs = 8.0; // unit * 1
  static const double sm = 12.0; // unit * 1.5
  static const double md = 16.0; // unit * 2
  static const double lg = 24.0; // unit * 3
  static const double xl = 32.0; // unit * 4
  static const double xxl = 48.0; // unit * 6
  static const double xxxl = 64.0; // unit * 8

  // Screen padding
  static const double screenPaddingH = 24.0;
  static const double screenPaddingV = 16.0;

  // Component spacing
  static const double inputGap = 16.0;
  static const double sectionGap = 32.0;
  static const double cardPadding = 20.0;
}
