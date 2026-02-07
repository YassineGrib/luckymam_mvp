import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Social login button for Google/Apple sign-in.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.isGoogle = false,
    this.isApple = false,
  });

  final String text;
  final String iconPath;
  final VoidCallback? onPressed;
  final bool isGoogle;
  final bool isApple;

  factory SocialButton.google({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SocialButton(
      text: text,
      iconPath: 'google',
      onPressed: onPressed,
      isGoogle: true,
    );
  }

  factory SocialButton.apple({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SocialButton(
      text: text,
      iconPath: 'apple',
      onPressed: onPressed,
      isApple: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.inputBorderDark
        : AppColors.inputBorderLight;
    final textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;

    return Container(
      height: AppTheme.buttonHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(isDark),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    if (isGoogle) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.googleRed,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    } else if (isApple) {
      return Icon(
        Icons.apple,
        size: 22,
        color: isDark ? Colors.white : Colors.black,
      );
    }
    return const SizedBox(width: 20);
  }
}
