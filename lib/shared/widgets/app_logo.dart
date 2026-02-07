import 'package:flutter/material.dart';

/// Displays the Luckymam logo with configurable size.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = LogoVariant.vertical,
    this.size = LogoSize.medium,
  });

  final LogoVariant variant;
  final LogoSize size;

  double get _width {
    switch (size) {
      case LogoSize.small:
        return variant == LogoVariant.horizontal ? 120 : 80;
      case LogoSize.medium:
        return variant == LogoVariant.horizontal ? 180 : 120;
      case LogoSize.large:
        return variant == LogoVariant.horizontal ? 240 : 160;
    }
  }

  String get _assetPath {
    return variant == LogoVariant.horizontal
        ? 'assets/logo/herizontal_logo.png'
        : 'assets/logo/vertical_logo.png';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(_assetPath, width: _width, fit: BoxFit.contain);
  }
}

enum LogoVariant { horizontal, vertical }

enum LogoSize { small, medium, large }
