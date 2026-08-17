import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Diamond Sponsor showcase page.
/// Displays logos and information about Luckymam's diamond-tier sponsors.
class DiamondSponsorsScreen extends StatelessWidget {
  const DiamondSponsorsScreen({super.key});

  List<_SponsorData> _sponsors(AppLocalizations l10n) => [
    _SponsorData(
      name: l10n.subscriptionDiamondPartner1Name,
      category: l10n.subscriptionDiamondPartner1Category,
      description: l10n.subscriptionDiamondPartner1Description,
      emoji: '🏥',
      color: const Color(0xFF2196F3),
    ),
    _SponsorData(
      name: l10n.subscriptionDiamondPartner2Name,
      category: l10n.subscriptionDiamondPartner2Category,
      description: l10n.subscriptionDiamondPartner2Description,
      emoji: '🍼',
      color: const Color(0xFFFF9800),
    ),
    _SponsorData(
      name: l10n.subscriptionDiamondPartner3Name,
      category: l10n.subscriptionDiamondPartner3Category,
      description: l10n.subscriptionDiamondPartner3Description,
      emoji: '🛍️',
      color: const Color(0xFF9C27B0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sponsors = _sponsors(l10n);
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
          l10n.subscriptionDiamondSponsorsTitle,
          style: AppTypography.fromContext(context, 
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Diamond icon with shimmer effect
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB9F2FF), Color(0xFF4FC3F7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.subscriptionDiamondPartnersHero,
                    style: AppTypography.fromContext(context, 
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subscriptionDiamondPartnersSubtitle,
                    style: AppTypography.fromContext(context, 
                      fontSize: 13,
                      color: Colors.white60,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Diamond pills row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _diamondPill(context, l10n.subscriptionDiamondPillExclusive),
                      const SizedBox(width: 8),
                      _diamondPill(context, l10n.subscriptionDiamondPillPremium),
                      const SizedBox(width: 8),
                      _diamondPill(context, l10n.subscriptionDiamondPillCertified),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Section title
            Text(
              l10n.subscriptionDiamondLogosSection,
              style: AppTypography.fromContext(context, 
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.subscriptionDiamondOfficialPartners,
              style: AppTypography.fromContext(context, fontSize: 13, color: secondaryColor),
            ),

            const SizedBox(height: AppSpacing.md),

            // Sponsors grid
            ...sponsors.map(
              (sponsor) => _SponsorCard(
                sponsor: sponsor,
                diamondBadgeLabel: l10n.subscriptionDiamondBadge,
                isDark: isDark,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Become sponsor CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE85A71), Color(0xFFFF8C94)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.handshake_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.subscriptionDiamondJoinTitle,
                    style: AppTypography.fromContext(context, 
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.subscriptionDiamondJoinSubtitle,
                    style: AppTypography.fromContext(context, 
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.subscriptionDiamondContactEmail,
                      style: AppTypography.fromContext(context, 
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.magentaPink,
                      ),
                    ),
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

  Widget _diamondPill(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: AppTypography.fromContext(context, 
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SponsorCard extends StatelessWidget {
  const _SponsorCard({
    required this.sponsor,
    required this.diamondBadgeLabel,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  final _SponsorData sponsor;
  final String diamondBadgeLabel;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: sponsor.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sponsor.color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(sponsor.emoji, style: const TextStyle(fontSize: 28)),
            ),
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
                        sponsor.name,
                        style: AppTypography.fromContext(context, 
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Diamond badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB9F2FF), Color(0xFF4FC3F7)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            diamondBadgeLabel,
                            style: AppTypography.fromContext(context, 
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sponsor.category,
                  style: AppTypography.fromContext(context, 
                    fontSize: 11,
                    color: sponsor.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sponsor.description,
                  style: AppTypography.fromContext(context, 
                    fontSize: 12,
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

class _SponsorData {
  const _SponsorData({
    required this.name,
    required this.category,
    required this.description,
    required this.emoji,
    required this.color,
  });

  final String name;
  final String category;
  final String description;
  final String emoji;
  final Color color;
}
