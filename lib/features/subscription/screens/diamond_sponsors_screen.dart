import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Inventory page for Luckymam advertising placements.
/// Shows available sponsor slots and a contact CTA for brands.
/// Redesigned with the boutique Squircle Bento visual identity:
/// - Soft ambient palette & frosted squircle containers
/// - Unified status indicators and clean typography hierarchy
/// - Clean modal sheet integration with non-overlapping header
class DiamondSponsorsScreen extends StatelessWidget {
  const DiamondSponsorsScreen({
    super.key,
    this.showAppBar = true,
    this.onSkip,
  });

  final bool showAppBar;
  final VoidCallback? onSkip;

  List<_AdSlotData> _slots(AppLocalizations l10n) => [
    _AdSlotData(
      icon: Icons.rocket_launch_rounded,
      title: l10n.subscriptionAdSlotSplashTitle,
      description: l10n.subscriptionAdSlotSplashDesc,
      accent: AppColors.magentaPink,
    ),
    _AdSlotData(
      icon: Icons.play_circle_rounded,
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
      icon: Icons.diamond_rounded,
      title: l10n.subscriptionAdSlotDiamondTitle,
      description: l10n.subscriptionAdSlotDiamondDesc,
      accent: const Color(0xFF0284C7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slots = _slots(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF131114)
        : const Color(0xFFFAF7F8);
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF1E161C);
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF6B6067);
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
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
              ),
            )
          : null,
      body: showAppBar
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
              child: _buildContent(
                context: context,
                l10n: l10n,
                slots: slots,
                primary: primary,
                textColor: textColor,
                secondaryColor: secondaryColor,
                isDark: isDark,
              ),
            )
          : Column(
              children: [
                // Top Grabber & Sheet Bar (when shown inside bottom sheet / modal)
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (onSkip != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withValues(
                                    alpha: isDark ? 0.2 : 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'LUCKYMAM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: primary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: onSkip,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Text(
                                    context.isRtl ? 'تخطي ‹' : 'Passer ›',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ] else ...[
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                    child: _buildContent(
                      context: context,
                      l10n: l10n,
                      slots: slots,
                      primary: primary,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required List<_AdSlotData> slots,
    required Color primary,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroBanner(
          l10n: l10n,
          primary: primary,
          isDark: isDark,
          textColor: textColor,
          secondaryColor: secondaryColor,
        ),

        const SizedBox(height: 18),

        // Section Header: Placements
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary.withValues(
                  alpha: isDark ? 0.2 : 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscriptionDiamondLogosSection,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    l10n.subscriptionDiamondOfficialPartners,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...slots.map(
          (slot) => _AvailableSlotCard(
            slot: slot,
            availableLabel: l10n.subscriptionDiamondBadge,
            isDark: isDark,
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
        ),

        const SizedBox(height: 14),

        _BenefitsCard(
          l10n: l10n,
          isDark: isDark,
          textColor: textColor,
          secondaryColor: secondaryColor,
          primary: primary,
        ),

        const SizedBox(height: 18),

        _ContactCta(
          l10n: l10n,
          primary: primary,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.l10n,
    required this.primary,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  final AppLocalizations l10n;
  final Color primary;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Color.alphaBlend(
            primary.withValues(alpha: 0.12),
            const Color(0xFF1E1A1E),
          )
        : Color.alphaBlend(
            primary.withValues(alpha: 0.06),
            Colors.white,
          );
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : primary.withValues(alpha: 0.18);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient watermark icon
            PositionedDirectional(
              bottom: -16,
              end: -10,
              child: IgnorePointer(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 96,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : primary.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Micro-Pill: Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(
                        alpha: isDark ? 0.16 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(
                          alpha: isDark ? 0.3 : 0.25,
                        ),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.subscriptionDiamondBadge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Hero Title
                  Text(
                    l10n.subscriptionDiamondPartnersHero,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    l10n.subscriptionDiamondPartnersSubtitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: secondaryColor,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3 Simplified Value Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeaturePill(
                        label: l10n.subscriptionDiamondPillExclusive,
                        icon: Icons.visibility_outlined,
                        primary: primary,
                        isDark: isDark,
                      ),
                      _FeaturePill(
                        label: l10n.subscriptionDiamondPillPremium,
                        icon: Icons.ads_click_outlined,
                        primary: primary,
                        isDark: isDark,
                      ),
                      _FeaturePill(
                        label: l10n.subscriptionDiamondPillCertified,
                        icon: Icons.handshake_outlined,
                        primary: primary,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.label,
    required this.icon,
    required this.primary,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final Color primary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : primary.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : primary,
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
    final surface = isDark ? const Color(0xFF1E1A1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEDE8EB),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Squircle icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: slot.accent.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(slot.icon, color: slot.accent, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  slot.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: secondaryColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Clean subtle status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(
                alpha: isDark ? 0.16 : 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  availableLabel,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
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

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({
    required this.l10n,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
    required this.primary,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF1E1A1E) : Colors.white;

    final benefits = [
      (
        icon: Icons.groups_rounded,
        title: l10n.subscriptionAdSpaceBenefit1Title,
        desc: l10n.subscriptionAdSpaceBenefit1Desc,
        accent: primary,
      ),
      (
        icon: Icons.verified_user_rounded,
        title: l10n.subscriptionAdSpaceBenefit2Title,
        desc: l10n.subscriptionAdSpaceBenefit2Desc,
        accent: AppColors.smaltBlue,
      ),
      (
        icon: Icons.view_carousel_rounded,
        title: l10n.subscriptionAdSpaceBenefit3Title,
        desc: l10n.subscriptionAdSpaceBenefit3Desc,
        accent: AppColors.casablanca,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEDE8EB),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subscriptionAdSpaceWhyTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < benefits.length; i++) ...[
            if (i > 0)
              Divider(
                height: 20,
                thickness: 0.8,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF3EFF1),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: benefits[i].accent.withValues(
                          alpha: isDark ? 0.2 : 0.12,
                        ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    benefits[i].icon,
                    size: 19,
                    color: benefits[i].accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefits[i].title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        benefits[i].desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactCta extends StatelessWidget {
  const _ContactCta({
    required this.l10n,
    required this.primary,
    required this.isDark,
  });

  final AppLocalizations l10n;
  final Color primary;
  final bool isDark;

  Future<void> _copyEmail(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(
      ClipboardData(text: l10n.subscriptionDiamondContactEmail),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(l10n.subscriptionAdSpaceEmailCopied),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                primary,
                Color.alphaBlend(
                  AppColors.coral.withValues(alpha: 0.8),
                  primary,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.subscriptionDiamondJoinTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                l10n.subscriptionDiamondJoinSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.subscriptionDiamondContactEmail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.content_copy_rounded,
                      size: 15,
                      color: primary,
                    ),
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
