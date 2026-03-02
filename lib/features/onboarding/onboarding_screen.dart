import 'package:flutter/material.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_logo.dart';

/// Onboarding screen with hero image, brand text, and swipe-to-start.
/// Matches the reference design with dark gradient overlay.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/images/Splash_img.jpg', fit: BoxFit.cover),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.85),
                  Colors.black,
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),

                  // Logo
                  const AppLogo(
                    variant: LogoVariant.horizontal,
                    size: LogoSize.small,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Title with highlighted phrase
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Des souvenirs \u00e0 transmettre,\n',
                          style: TextStyle(color: AppColors.magentaPink),
                        ),
                        const TextSpan(
                          text: 'des \u00e9motions \u00e0 revivre',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Subtitle
                  Text(
                    l10n.welcomeSubtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Swipe to Get Started Button
                  _SwipeToStartButton(onCompleted: () => context.go('/login')),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive swipe-to-start button matching reference design.
class _SwipeToStartButton extends StatefulWidget {
  const _SwipeToStartButton({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_SwipeToStartButton> createState() => _SwipeToStartButtonState();
}

class _SwipeToStartButtonState extends State<_SwipeToStartButton> {
  double _dragPosition = 0;
  final double _buttonSize = 52;
  final double _padding = 4;

  double get _maxDrag =>
      MediaQuery.of(context).size.width -
      (AppSpacing.screenPaddingH * 2) -
      _buttonSize -
      (_padding * 2);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: _buttonSize + (_padding * 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Stack(
        children: [
          // Center Text
          Center(
            child: Text(
              l10n.swipeToGetStarted,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),

          // Arrows
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.keyboard_double_arrow_right,
                color: Colors.white.withOpacity(0.5),
                size: 24,
              ),
            ),
          ),

          // Draggable Button
          Positioned(
            left: _padding + _dragPosition,
            top: _padding,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition = (_dragPosition + details.delta.dx).clamp(
                    0.0,
                    _maxDrag,
                  );
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragPosition > _maxDrag * 0.7) {
                  widget.onCompleted();
                } else {
                  setState(() {
                    _dragPosition = 0;
                  });
                }
              },
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.magentaPink.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
