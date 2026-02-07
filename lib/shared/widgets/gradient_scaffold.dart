import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Scaffold with gradient background for splash/onboarding screens.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.child,
    this.useOverlay = false,
  });

  final Widget child;
  final bool useOverlay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : const LinearGradient(
                  colors: [Color(0xFFFFF5F5), Color(0xFFF5F5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: useOverlay
            ? Stack(
                children: [
                  child,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.softOverlayGradient,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : child,
      ),
    );
  }
}
