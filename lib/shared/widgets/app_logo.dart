import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable LuckyMam SVG logo widget — uses the real brand asset.
/// Replaces the old AppLogo which used placeholder PNGs.
class LuckyMamLogo extends StatelessWidget {
  const LuckyMamLogo({
    super.key,
    this.size = 36,
    this.color,
    this.showText = false,
  });

  /// Size of the SVG icon
  final double size;

  /// Optional color tint (null = use original SVG colors)
  final Color? color;

  /// Whether to show "LuckyMam" text next to the logo
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final svgWidget = SvgPicture.asset(
      'assets/logo/logo svg.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );

    if (!showText) return svgWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        svgWidget,
        const SizedBox(width: 8),
        Text(
          'LuckyMam',
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w800,
            color: color ?? const Color(0xFFE91E8C),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Displays the Luckymam logo with configurable size.
/// Now properly uses the SVG asset. Old PNG variant kept for compatibility.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = LogoVariant.vertical,
    this.size = LogoSize.medium,
  });

  final LogoVariant variant;
  final LogoSize size;

  double get _iconSize {
    switch (size) {
      case LogoSize.small:
        return 48;
      case LogoSize.medium:
        return 72;
      case LogoSize.large:
        return 96;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (variant == LogoVariant.horizontal) {
      return LuckyMamLogo(size: _iconSize, showText: true);
    }
    return LuckyMamLogo(size: _iconSize);
  }
}

enum LogoVariant { horizontal, vertical }

enum LogoSize { small, medium, large }
