import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../reels/screens/reels_screen.dart';
import '../data/vaccine_education_data.dart';
import '../models/vaccine.dart';
import '../models/vaccine_status.dart';
import '../providers/vaccine_providers.dart';
import '../../../shared/widgets/medical_disclaimer_banner.dart';

/// Redesigned flagship medical vaccine detail screen for LuckyMam.
/// Follows the boutique Squircle Bento visual identity:
/// - 24px squircle containers with calibrated pastel tints and soft borders
/// - Atmospheric ambient top lighting harmonized with the vaccine's accent color
/// - Full Arabic / French / English localization (fixes raw English/French name bug)
/// - Direction-aware RTL layout and corner-bleeding watermark icons
/// - Rich vertical bento flow: Protection Shield, Mechanism, Post-Vaccine Care Tips,
///   Child Status Record, Linked Milestone Capsule, and Pediatric Reels.
class VaccineDetailScreen extends ConsumerWidget {
  const VaccineDetailScreen({
    super.key,
    required this.vaccine,
    required this.childId,
    required this.vaccineGroupId,
  });

  final Vaccine vaccine;
  final String childId;
  final String vaccineGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF131114)
        : const Color(0xFFFAF7F8);
    final surfaceColor = isDark
        ? const Color(0xFF1E1A1E)
        : Colors.white;
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF1E161C);
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF6B6067);

    // Vaccine specific education metadata & curated accent color
    final info = vaccineEducationFor(vaccine.code);
    final accentColor = info?.color ?? const Color(0xFF0D9488);
    final headerIcon = info?.icon ?? Icons.vaccines_rounded;

    // Vaccine group & Vaccination status lookup
    final calendarAsync = ref.watch(vaccineCalendarProvider);
    final group = calendarAsync.whenOrNull(
      data: (cal) => cal.groups.where((g) => g.id == vaccineGroupId).firstOrNull,
    );

    final statusesAsync = ref.watch(childVaccinationStatusesProvider(childId));
    final status = statusesAsync.whenOrNull(
      data: (list) => list.where((s) => s.vaccineGroupId == vaccineGroupId).firstOrNull,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Atmospheric Ambient Glow Tinted by Vaccine Color ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.20 : 0.14),
                      accentColor.withValues(alpha: isDark ? 0.05 : 0.03),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // ─── Main Scrollable Bento Content ───
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. Floating Top Navigation Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Frosted Squircle Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFE8E0E4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.25 : 0.04,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isRtl
                                    ? Icons.arrow_forward_ios_rounded
                                    : Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),

                        // Center: Vaccine Group Timing Badge
                        if (group != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  group.getAgeLabel(lang),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Trailing placeholder to keep center aligned with 42px back button
                        const SizedBox(width: 42),
                      ],
                    ),
                  ),
                ),

                // 2. Bento Scroll Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 80),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ─── Medical Disclaimer (Google Play Health Policy) ──
                      const MedicalDisclaimerBanner(),
                      const SizedBox(height: 10),

                      // ─── Hero Squircle Card ───────────────────────
                      _buildHeroCard(
                        context: context,
                        isDark: isDark,
                        lang: lang,
                        accentColor: accentColor,
                        headerIcon: headerIcon,
                        textColor: textColor,
                        secondaryText: secondaryText,
                      ),

                      const SizedBox(height: 14),

                      // ─── Bento 1: Protection Shield Card ─────────
                      _buildProtectionShieldCard(
                        context: context,
                        isDark: isDark,
                        lang: lang,
                        accentColor: accentColor,
                        textColor: textColor,
                        secondaryText: secondaryText,
                      ),

                      const SizedBox(height: 14),

                      // ─── Bento 2: Medical Purpose & Mechanism ────
                      if (info != null) ...[
                        _buildMedicalPurposeCard(
                          context: context,
                          isDark: isDark,
                          lang: lang,
                          info: info,
                          accentColor: accentColor,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          secondaryText: secondaryText,
                        ),
                        const SizedBox(height: 14),
                      ] else ...[
                        _buildFallbackCard(
                          context: context,
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                          secondaryText: secondaryText,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ─── Bento 3: Post-Vaccination Care & Tips ───
                      if (info != null) ...[
                        _buildPostCareCard(
                          context: context,
                          isDark: isDark,
                          lang: lang,
                          info: info,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          secondaryText: secondaryText,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ─── Bento 4: Milestone Memory Capsule ───────
                      _buildCapsuleSection(
                        context: context,
                        ref: ref,
                        isDark: isDark,
                        lang: lang,
                        accentColor: accentColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        status: status,
                      ),

                      const SizedBox(height: 14),

                      // ─── Bento 5: Educational Reels Card ─────────
                      _buildReelsSection(
                        context: context,
                        isDark: isDark,
                        accentColor: accentColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        secondaryText: secondaryText,
                      ),

                      const SizedBox(height: 14),

                      // ─── Bento 6: Pediatric Medical Disclaimer ────
                      _buildDisclaimerCard(
                        context: context,
                        isDark: isDark,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // HERO SQUIRCLE CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required Color accentColor,
    required IconData headerIcon,
    required Color textColor,
    required Color secondaryText,
  }) {
    final cardBg = isDark
        ? Color.alphaBlend(
            accentColor.withValues(alpha: 0.12),
            const Color(0xFF1E1A1E),
          )
        : Color.alphaBlend(
            accentColor.withValues(alpha: 0.08),
            Colors.white,
          );
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : accentColor.withValues(alpha: 0.18);

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
                : accentColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Corner-bleeding watermark icon (RTL aware)
            PositionedDirectional(
              bottom: -22,
              end: -15,
              child: IgnorePointer(
                child: Icon(
                  headerIcon,
                  size: 104,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : accentColor.withValues(alpha: 0.09),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Squircle Gradient Icon
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor,
                              Color.alphaBlend(
                                Colors.black.withValues(alpha: 0.2),
                                accentColor,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.32),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          headerIcon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Code & Localized Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vaccine.code,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                height: 1.1,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Localized Name (Ar / Fr / En)
                            Text(
                              vaccine.getName(lang),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
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

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO 1: PROTECTION SHIELD CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildProtectionShieldCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required Color accentColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    const shieldColor = Color(0xFF0284C7); // Rich protective oceanic cyan
    final cardBg = isDark
        ? const Color(0xFF14202B)
        : const Color(0xFFF0F9FF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFBAE6FD);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : shieldColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              bottom: -20,
              end: -14,
              child: IgnorePointer(
                child: Icon(
                  Icons.shield_rounded,
                  size: 92,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : shieldColor.withValues(alpha: 0.09),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Micro-Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: shieldColor.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 13,
                          color: shieldColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.vaccineShieldTitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: shieldColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    l10n.vaccineDetailProtectsAgainst(
                      vaccine.getProtects(lang),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.4,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO 2: MEDICAL PURPOSE & HOW IT WORKS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMedicalPurposeCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required VaccineEducation info,
    required Color accentColor,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    final cardBg = surfaceColor;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEDE8EB);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              bottom: -22,
              end: -16,
              child: IgnorePointer(
                child: Icon(
                  Icons.biotech_rounded,
                  size: 94,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : accentColor.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Micro-Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: accentColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.vaccineDetailPurposeTitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Purpose description
                  Text(
                    info.getDescription(lang),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mechanism callout box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF9F7F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFEFEAEE),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology_alt_rounded,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.vaccineDetailHowItWorks,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          info.getHowItWorks(lang),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO 3: POST-VACCINE CARE & SIDE EFFECTS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPostCareCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required VaccineEducation info,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    const careAccent = Color(0xFFE11D48); // Gentle reassuring rose
    final cardBg = isDark
        ? const Color(0xFF26191E)
        : const Color(0xFFFFF1F4);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFFFE0E6);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : careAccent.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              bottom: -22,
              end: -16,
              child: IgnorePointer(
                child: Icon(
                  Icons.healing_rounded,
                  size: 96,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : careAccent.withValues(alpha: 0.09),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Micro-Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: careAccent.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: careAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.vaccinePostCareTitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: careAccent,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Expected side effects explanation
                  Text(
                    info.getSideEffects(lang),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Maternal Comfort Checklist
                  _buildCareTipItem(
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF0284C7),
                    text: l10n.vaccineCareTipCompress,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildCareTipItem(
                    icon: Icons.child_friendly_rounded,
                    color: const Color(0xFFD97706),
                    text: l10n.vaccineCareTipHydrate,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildCareTipItem(
                    icon: Icons.thermostat_rounded,
                    color: const Color(0xFFE11D48),
                    text: l10n.vaccineCareTipFever,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareTipItem({
    required IconData icon,
    required Color color,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF382F35),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO 4: LINKED MILESTONE MEMORY CAPSULE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCapsuleSection({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required String lang,
    required Color accentColor,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
    required VaccineStatus? status,
  }) {
    final capsuleId = status?.capsuleId;

    if (capsuleId == null) {
      return _buildCapsuleCTA(
        context: context,
        isDark: isDark,
        accentColor: accentColor,
        surfaceColor: surfaceColor,
        textColor: textColor,
        secondaryText: secondaryText,
      );
    }

    final capsulesAsync = ref.watch(capsulesProvider);
    return capsulesAsync.when(
      loading: () => Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: accentColor,
          ),
        ),
      ),
      error: (_, _) => _buildCapsuleCTA(
        context: context,
        isDark: isDark,
        accentColor: accentColor,
        surfaceColor: surfaceColor,
        textColor: textColor,
        secondaryText: secondaryText,
      ),
      data: (list) {
        final capsule = list.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) {
          return _buildCapsuleCTA(
            context: context,
            isDark: isDark,
            accentColor: accentColor,
            surfaceColor: surfaceColor,
            textColor: textColor,
            secondaryText: secondaryText,
          );
        }
        return _buildLinkedCapsuleRow(
          context: context,
          capsule: capsule,
          isDark: isDark,
          lang: lang,
          accentColor: accentColor,
          surfaceColor: surfaceColor,
          textColor: textColor,
          secondaryText: secondaryText,
        );
      },
    );
  }

  Widget _buildLinkedCapsuleRow({
    required BuildContext context,
    required Capsule capsule,
    required bool isDark,
    required String lang,
    required Color accentColor,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    final cardBg = surfaceColor;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEDE8EB);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              bottom: -22,
              end: -16,
              child: IgnorePointer(
                child: Icon(
                  Icons.camera_enhance_rounded,
                  size: 94,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : accentColor.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Micro-Pill Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(
                            alpha: isDark ? 0.16 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: accentColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              l10n.vaccineLinkedMemory,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF3EEF1),
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 13,
                          color: isDark ? Colors.white70 : const Color(0xFF4A4442),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Capsule item row
                  GestureDetector(
                    onTap: () {
                      AnalyticsService().logEvent(
                        'vax_capsule_viewed',
                        parameters: {
                          'childId': childId,
                          'vaccineGroupId': vaccineGroupId,
                          'capsuleId': capsule.id,
                        },
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CapsuleDetailScreen(capsule: capsule),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 68,
                            height: 68,
                            child: Hero(
                              tag: 'capsule_${capsule.id}',
                              child: CachedNetworkImage(
                                imageUrl: capsule.photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                  highlightColor: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[100]!,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.vaccineCapsuleTitle,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : const Color(0xFFF6F2F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      capsule.emotion.icon,
                                      size: 13,
                                      color: secondaryText,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      capsule.emotion.getLabel(lang),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleCTA({
    required BuildContext context,
    required bool isDark,
    required Color accentColor,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    final cardBg = surfaceColor;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEDE8EB);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              bottom: -22,
              end: -16,
              child: IgnorePointer(
                child: Icon(
                  Icons.camera_enhance_rounded,
                  size: 94,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : accentColor.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: isDark ? 0.16 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 13,
                          color: accentColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.vaccineMemorySection,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.vaccineMemoryPrompt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateCapsuleScreen(
                              vaccineGroupId: vaccineGroupId,
                              preselectedChildId: childId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(
                        l10n.capsule,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO 5: REELS SECTION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildReelsSection({
    required BuildContext context,
    required bool isDark,
    required Color accentColor,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    const reelsAccent = Color(0xFF6366F1); // Modern educational indigo
    final cardBg = isDark
        ? const Color(0xFF191B28)
        : const Color(0xFFF5F6FF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE0E3FF);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : reelsAccent.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              bottom: -22,
              end: -16,
              child: IgnorePointer(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 96,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : reelsAccent.withValues(alpha: 0.09),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: reelsAccent.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.smart_display_rounded,
                          size: 13,
                          color: reelsAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.vaccineReelsTitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: reelsAccent,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.vaccineReelsSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AnalyticsService().logEvent(
                          'vax_reels_opened',
                          parameters: {
                            'childId': childId,
                            'vaccineCode': vaccine.code,
                          },
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReelsScreen(
                              initialVaccineCodes: [vaccine.code],
                              initialVaccineLabel: vaccine.code,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.vaccineReelsButton,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: reelsAccent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO 6: DISCLAIMER CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDisclaimerCard({
    required BuildContext context,
    required bool isDark,
  }) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.08)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.2)
              : const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            size: 20,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.vaccineDetailDisclaimer,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFFFDE68A)
                    : const Color(0xFF92400E),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCard({
    required BuildContext context,
    required bool isDark,
    required Color surfaceColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.vaccineDetailFallback,
        style: TextStyle(
          fontSize: 13.5,
          color: secondaryText,
          height: 1.5,
        ),
      ),
    );
  }
}
