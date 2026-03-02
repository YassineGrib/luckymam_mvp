import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Diamond Sponsor showcase page.
/// Displays logos and information about Luckymam's diamond-tier sponsors.
class DiamondSponsorsScreen extends StatelessWidget {
  const DiamondSponsorsScreen({super.key});

  // Placeholder diamond sponsors data
  static const List<_SponsorData> _sponsors = [
    _SponsorData(
      name: 'Partenaire Diamant 1',
      category: 'Santé & Maternité',
      description: 'Leader en solutions de santé pour femmes et enfants.',
      emoji: '🏥',
      color: Color(0xFF2196F3),
    ),
    _SponsorData(
      name: 'Partenaire Diamant 2',
      category: 'Nutrition Infantile',
      description: 'Experts en nutrition pour bébés et jeunes enfants.',
      emoji: '🍼',
      color: Color(0xFFFF9800),
    ),
    _SponsorData(
      name: 'Partenaire Diamant 3',
      category: 'Puériculture',
      description: 'Équipements premium pour l\'éveil de votre bébé.',
      emoji: '🛍️',
      color: Color(0xFF9C27B0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Sponsors Diamant',
          style: GoogleFonts.outfit(
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
                          color: const Color(0xFF4FC3F7).withOpacity(0.4),
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
                    'Nos Partenaires Diamant',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Des marques de confiance qui accompagnent\nchaque maman dans son parcours',
                    style: GoogleFonts.outfit(
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
                      _diamondPill('💎 Exclusif'),
                      const SizedBox(width: 8),
                      _diamondPill('⭐ Premium'),
                      const SizedBox(width: 8),
                      _diamondPill('✅ Certifié'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Section title
            Text(
              'Logos & Partenaires',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Partenaires officiels de l\'application Luckymam',
              style: GoogleFonts.outfit(fontSize: 13, color: secondaryColor),
            ),

            const SizedBox(height: AppSpacing.md),

            // Sponsors grid
            ..._sponsors.map(
              (sponsor) => _SponsorCard(
                sponsor: sponsor,
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
                    'Rejoignez nos Sponsors Diamant',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atteignez des milliers de mamans algériennes.\nContactez-nous pour un partenariat Diamant.',
                    style: GoogleFonts.outfit(
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
                      'sponsors@luckymam.com',
                      style: GoogleFonts.outfit(
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

  Widget _diamondPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
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
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  final _SponsorData sponsor;
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
            color: Colors.black.withOpacity(0.05),
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
              color: sponsor.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sponsor.color.withOpacity(0.3)),
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
                        style: GoogleFonts.outfit(
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
                            'Diamant',
                            style: GoogleFonts.outfit(
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
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: sponsor.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sponsor.description,
                  style: GoogleFonts.outfit(
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
