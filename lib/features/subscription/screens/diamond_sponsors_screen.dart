import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Inventory page for Luckymam advertising placements.
/// Shows available sponsor slots and a contact CTA for brands.
class DiamondSponsorsScreen extends StatelessWidget {
  const DiamondSponsorsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  List<_AdSlotData> _slots(AppLocalizations l10n) => [
    _AdSlotData(
      icon: Icons.rocket_launch_outlined,
      title: l10n.subscriptionAdSlotSplashTitle,
      description: l10n.subscriptionAdSlotSplashDesc,
      accent: AppColors.magentaPink,
    ),
    _AdSlotData(
      icon: Icons.play_circle_outline_rounded,
      title: l10n.subscriptionAdSlotReelsTitle,
      description: l10n.subscriptionAdSlotReelsDesc,
      accent: AppColors.smaltBlue,
    ),
    _AdSlotData(
      icon: Icons.fullscreen_rounded,
      title: l10n.subscriptionAdSlotInterstitialTitle,
      description: l10n.subscriptionAdSlotInterstitialDesc,
      accent: AppColors.casablanca,
    ),
    _AdSlotData(
      icon: Icons.diamond_outlined,
      title: l10n.subscriptionAdSlotDiamondTitle,
      description: l10n.subscriptionAdSlotDiamondDesc,
      accent: const Color(0xFF4FC3F7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slots = _slots(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                l10n.subscriptionDiamondSponsorsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingH,
          AppSpacing.md,
          AppSpacing.screenPaddingH,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroBanner(
              l10n: l10n,
              primary: primary,
              onPill: (label, icon) => _FeaturePill(label: label, icon: icon),
            ),

            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Icon(Icons.grid_view_rounded, size: 20, color: primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.subscriptionDiamondLogosSection,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.subscriptionDiamondOfficialPartners,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            ...slots.map(
              (slot) => _AvailableSlotCard(
                slot: slot,
                availableLabel: l10n.subscriptionDiamondBadge,
                isDark: isDark,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              l10n.subscriptionAdSpaceWhyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            _BenefitRow(
              icon: Icons.groups_outlined,
              title: l10n.subscriptionAdSpaceBenefit1Title,
              description: l10n.subscriptionAdSpaceBenefit1Desc,
              accent: primary,
              isDark: isDark,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            _BenefitRow(
              icon: Icons.verified_user_outlined,
              title: l10n.subscriptionAdSpaceBenefit2Title,
              description: l10n.subscriptionAdSpaceBenefit2Desc,
              accent: AppColors.smaltBlue,
              isDark: isDark,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            _BenefitRow(
              icon: Icons.view_carousel_outlined,
              title: l10n.subscriptionAdSpaceBenefit3Title,
              description: l10n.subscriptionAdSpaceBenefit3Desc,
              accent: AppColors.casablanca,
              isDark: isDark,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),

            const SizedBox(height: AppSpacing.xl),

            _ContactCta(
              l10n: l10n,
              primary: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.l10n,
    required this.primary,
    required this.onPill,
  });

  final AppLocalizations l10n;
  final Color primary;
  final Widget Function(String label, IconData icon) onPill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            primary.withValues(alpha: 0.92),
            AppColors.coral.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.subscriptionDiamondBadge,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.subscriptionDiamondPartnersHero,
            style: AppTypography.fromContext(
              context,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.subscriptionDiamondPartnersSubtitle,
            style: AppTypography.fromContext(
              context,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              onPill(
                l10n.subscriptionDiamondPillExclusive,
                Icons.visibility_outlined,
              ),
              onPill(
                l10n.subscriptionDiamondPillPremium,
                Icons.ads_click_outlined,
              ),
              onPill(
                l10n.subscriptionDiamondPillCertified,
                Icons.handshake_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.fromContext(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableSlotCard extends StatelessWidget {
  const _AvailableSlotCard({
    required this.slot,
    required this.availableLabel,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  final _AdSlotData slot;
  final String availableLabel;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: slot.accent.withValues(alpha: 0.35),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: slot.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(slot.icon, color: slot.accent, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slot.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF4ADE80).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 12,
                            color: const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            availableLabel,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  slot.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCta extends StatelessWidget {
  const _ContactCta({required this.l10n, required this.primary});

  final AppLocalizations l10n;
  final Color primary;

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: l10n.subscriptionDiamondContactEmail),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.subscriptionAdSpaceEmailCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copyEmail(context),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, AppColors.coral],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.subscriptionDiamondJoinTitle,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.subscriptionDiamondJoinSubtitle,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.subscriptionDiamondContactEmail,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.content_copy_rounded, size: 16, color: primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdSlotData {
  const _AdSlotData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
}
