import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/extensions/l10n_extension.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// LM-CROSS-001: Unified Luxury State Views across LuckyMam screens.
/// Enforces:
/// - No blank white screens
/// - Clean, compassionate, non-technical error messages
/// - Responsive touch targets >= 44x44
/// - Retry callbacks on all error handlers
/// - Automated non-PII error logging (LM-CROSS-003)

/// 1. Unified Centered Loading View
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.message,
    this.color = AppColors.coral,
  });

  final String? message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3.2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : const Color(0xFF6B5E6D),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 2. Unified Boutique Empty State View
class AppEmptyStateView extends StatelessWidget {
  const AppEmptyStateView({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.auto_stories_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ambient Squircle Icon Container
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : const Color(0xFFFFD4E2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 34,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTypography.fromContext(
                context,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              style: AppTypography.fromContext(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: secondaryText,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional CTA Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAction!();
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  label: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 3. Unified Error View with Friendly Guidance & Retry Action
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.friendlyTitle,
    this.friendlyMessage,
    this.rawError,
    this.stepContext = 'screen_load',
    this.onRetry,
  });

  final String? friendlyTitle;
  final String? friendlyMessage;
  final dynamic rawError;
  final String stepContext;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    // Log the error automatically if rawError was provided (LM-CROSS-003)
    if (rawError != null) {
      AnalyticsService().logTechnicalError(
        errorType: 'view_error_displayed',
        step: stepContext,
        rawMessage: rawError.toString(),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft Error Icon Squircle
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2E1C22)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFDA4AF).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: Color(0xFFE11D48),
              ),
            ),
            const SizedBox(height: 18),

            // Friendly Title
            Text(
              friendlyTitle ?? 'Une petite pause réseau',
              style: AppTypography.fromContext(
                context,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Friendly Compassionate Message (No raw tech dump)
            Text(
              friendlyMessage ??
                  'Vos souvenirs restent en sécurité. Touchez « Réessayer » pour actualiser l\'affichage.',
              style: AppTypography.fromContext(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: secondaryText,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry!();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Réessayer',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coral,
                  side: const BorderSide(color: AppColors.coral, width: 1.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

