import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Full Privacy Policy & Terms of Use screen.
/// Accessible from the signup consent mention and from profile settings.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.authPrivacyTitle,
          style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authPrivacyHeroTitle,
                    style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.authPrivacyLastUpdated,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── POLITIQUE DE CONFIDENTIALITÉ ─────────────────────────────
            _SectionTitle(
              icon: Icons.lock_outline_rounded,
              title: l10n.authPrivacyPolicyTitle,
              color: AppColors.magentaPink,
              textColor: textColor,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authPrivacySection1Title,
              content: l10n.authPrivacySection1Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authPrivacySection2Title,
              content: l10n.authPrivacySection2Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authPrivacySection3Title,
              content: l10n.authPrivacySection3Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authPrivacySection4Title,
              content: l10n.authPrivacySection4Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authPrivacySection5Title,
              content: l10n.authPrivacySection5Body,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── CONDITIONS D'UTILISATION ─────────────────────────────────
            _SectionTitle(
              icon: Icons.gavel_rounded,
              title: l10n.authTermsTitle,
              color: AppColors.smaltBlue,
              textColor: textColor,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authTermsSection1Title,
              content: l10n.authTermsSection1Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authTermsSection2Title,
              content: l10n.authTermsSection2Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authTermsSection3Title,
              content: l10n.authTermsSection3Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authTermsSection4Title,
              content: l10n.authTermsSection4Body,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: l10n.authTermsSection5Title,
              content: l10n.authTermsSection5Body,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Contact block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.magentaPink,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authPrivacyQuestionsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.authPrivacyContactEmail,
                    style: AppTypography.fromContext(context, fontSize: 13, color: secondaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.cardColor,
    required this.secondaryColor,
    required this.textColor,
    required this.title,
    required this.content,
  });

  final Color cardColor;
  final Color secondaryColor;
  final Color textColor;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.fromContext(context, fontSize: 13, color: secondaryColor, height: 1.6),
          ),
        ],
      ),
    );
  }
}
