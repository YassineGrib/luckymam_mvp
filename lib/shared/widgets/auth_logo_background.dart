import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Decorative Luckymam logo watermark for auth / welcome screens.
///
/// Placed in the bottom-end corner with partial bleed-off for a cover pattern.
/// RTL-aware via [PositionedDirectional].
class AuthLogoBackground extends StatelessWidget {
  const AuthLogoBackground({
    super.key,
    this.opacity,
    this.lightOpacity = 0.11,
    this.darkOpacity = 0.16,
  });

  /// When set, overrides theme-based opacity (e.g. onboarding dark hero).
  final double? opacity;
  final double lightOpacity;
  final double darkOpacity;

  static const _asset = 'assets/logo/logo svg.svg';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedOpacity =
        opacity ?? (isDark ? darkOpacity : lightOpacity);
    final size = MediaQuery.sizeOf(context);
    final patternSize = size.width * 1.05;

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            end: -patternSize * 0.32,
            bottom: -patternSize * 0.06,
            width: patternSize,
            height: patternSize * 1.05,
            child: Opacity(
              opacity: resolvedOpacity,
              child: SvgPicture.asset(
                _asset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
