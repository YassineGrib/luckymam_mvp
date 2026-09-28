import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A rich, atmospheric ambient gradient that sits at the top of screens.
/// Transitions smoothly from a warm rose/coral tint down into transparent,
/// giving a luxurious, cohesive boutique feel across the application.
class TopAmbientGradient extends StatelessWidget {
  final double height;
  final double? opacityMultiplier;

  const TopAmbientGradient({
    super.key,
    this.height = 340,
    this.opacityMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final multiplier = opacityMultiplier ?? 1.0;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.38, 0.72, 1.0],
              colors: [
                primary.withValues(alpha: (isDark ? 0.22 : 0.28) * multiplier),
                primary.withValues(alpha: (isDark ? 0.10 : 0.13) * multiplier),
                primary.withValues(alpha: (isDark ? 0.03 : 0.04) * multiplier),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
