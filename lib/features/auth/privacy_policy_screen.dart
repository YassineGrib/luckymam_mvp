import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/auth_logo_background.dart';

/// Available legal tabs for the combined legal compliance center.
enum LegalTab {
  privacy,
  terms,
}

/// Flagship Privacy Policy & Terms of Use screen redesigned with LuckyMam Home-Bento aesthetics.
/// Features a luxury frosted header, dual-tab segmented control, Squircle Bento section cards,
/// and Algerian Law 18-07 privacy certifications.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({
    super.key,
    this.initialTab = LegalTab.privacy,
  });

  final LegalTab initialTab;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late LegalTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardColor = isDark ? const Color(0xFF221A24) : Colors.white;

    const coral = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── 1. Corner Brand Watermark Logo ──
          const AuthLogoBackground(
            lightOpacity: 0.08,
            darkOpacity: 0.14,
          ),

          // ── 2. Ambient Top Atmosphere Glow ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      coral.withValues(alpha: isDark ? 0.16 : 0.08),
                      const Color(0xFFFF8F00).withValues(alpha: isDark ? 0.08 : 0.03),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── 3. Luxury Interactive Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Frosted Squircle Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
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

                      const SizedBox(width: 14),

                      // Header Titles
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'ar'
                                  ? 'الخصوصية والشروط'
                                  : (lang == 'fr'
                                      ? 'Confidentialité & Conditions'
                                      : 'Privacy & Terms'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == 'ar'
                                  ? 'حماية بياناتكِ والتزامات الخدمة'
                                  : (lang == 'fr'
                                      ? 'Protection des données & engagements'
                                      : 'Data protection & legal compliance'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Compliance Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00C853).withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 13,
                              color: Color(0xFF00C853),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lang == 'ar' ? 'معتمد 18-07' : 'Loi 18-07',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── 4. Main Scrollable Content ──
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Hero Trust Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPaddingH,
                            vertical: 6,
                          ),
                          child: _LegalHeroBanner(
                            isDark: isDark,
                            isRtl: isRtl,
                            lang: lang,
                            l10n: l10n,
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 14)),

                      // Segmented Dual-Tab Switcher (Privacy vs Terms)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPaddingH,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFE8E0E4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.03,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Tab 1: Privacy Policy
                                Expanded(
                                  child: _TabButton(
                                    title: l10n.authPrivacyPolicyTitle,
                                    icon: Icons.shield_outlined,
                                    isSelected: _selectedTab == LegalTab.privacy,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _selectedTab = LegalTab.privacy;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Tab 2: Terms of Use
                                Expanded(
                                  child: _TabButton(
                                    title: l10n.authTermsTitle,
                                    icon: Icons.gavel_rounded,
                                    isSelected: _selectedTab == LegalTab.terms,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _selectedTab = LegalTab.terms;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 18)),

                      // Section Content Cards
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingH,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            _selectedTab == LegalTab.privacy
                                ? _buildPrivacyCards(
                                    context,
                                    cardColor,
                                    secondaryColor,
                                    textColor,
                                    isDark,
                                  )
                                : _buildTermsCards(
                                    context,
                                    cardColor,
                                    secondaryColor,
                                    textColor,
                                    isDark,
                                  ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Contact & Support Bento Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPaddingH,
                          ),
                          child: _LegalContactCard(
                            cardColor: cardColor,
                            secondaryColor: secondaryColor,
                            textColor: textColor,
                            isDark: isDark,
                            lang: lang,
                            l10n: l10n,
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Legal Footer Seal
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Center(
                            child: Text(
                              lang == 'ar'
                                  ? 'لاكي مام © 2026 • متوافق مع القانون الجزائري 18-07 لحماية المعطيات ذات الطابع الشخصي'
                                  : 'LuckyMam © 2026 • Conforme à la Loi 18-07 sur la protection des données',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: secondaryColor.withValues(alpha: 0.7),
                              ),
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
        ],
      ),
    );
  }

  List<Widget> _buildPrivacyCards(
    BuildContext context,
    Color cardColor,
    Color secondaryColor,
    Color textColor,
    bool isDark,
  ) {
    final l10n = context.l10n;

    return [
      _BentoSectionCard(
        number: '01',
        title: l10n.authPrivacySection1Title,
        content: l10n.authPrivacySection1Body,
        accentColor: const Color(0xFF00B0FF),
        icon: Icons.inventory_2_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '02',
        title: l10n.authPrivacySection2Title,
        content: l10n.authPrivacySection2Body,
        accentColor: const Color(0xFF7C4DFF),
        icon: Icons.tune_rounded,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '03',
        title: l10n.authPrivacySection3Title,
        content: l10n.authPrivacySection3Body,
        accentColor: const Color(0xFFFF9100),
        icon: Icons.lock_clock_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '04',
        title: l10n.authPrivacySection4Title,
        content: l10n.authPrivacySection4Body,
        accentColor: const Color(0xFF00C853),
        icon: Icons.verified_user_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '05',
        title: l10n.authPrivacySection5Title,
        content: l10n.authPrivacySection5Body,
        accentColor: const Color(0xFFFF5252),
        icon: Icons.account_balance_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
    ];
  }

  List<Widget> _buildTermsCards(
    BuildContext context,
    Color cardColor,
    Color secondaryColor,
    Color textColor,
    bool isDark,
  ) {
    final l10n = context.l10n;

    return [
      _BentoSectionCard(
        number: '01',
        title: l10n.authTermsSection1Title,
        content: l10n.authTermsSection1Body,
        accentColor: const Color(0xFF00B0FF),
        icon: Icons.handshake_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '02',
        title: l10n.authTermsSection2Title,
        content: l10n.authTermsSection2Body,
        accentColor: const Color(0xFF7C4DFF),
        icon: Icons.baby_changing_station_rounded,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '03',
        title: l10n.authTermsSection3Title,
        content: l10n.authTermsSection3Body,
        accentColor: const Color(0xFFFF9100),
        icon: Icons.health_and_safety_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '04',
        title: l10n.authTermsSection4Title,
        content: l10n.authTermsSection4Body,
        accentColor: const Color(0xFF00C853),
        icon: Icons.workspace_premium_outlined,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
      _BentoSectionCard(
        number: '05',
        title: l10n.authTermsSection5Title,
        content: l10n.authTermsSection5Body,
        accentColor: const Color(0xFFFF5252),
        icon: Icons.published_with_changes_rounded,
        cardColor: cardColor,
        secondaryColor: secondaryColor,
        textColor: textColor,
        isDark: isDark,
      ),
    ];
  }
}

// ─── Dual-Tab Segment Button ─────────────────────────────────────────

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF5252);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? coral : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: coral.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF8E7E88),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF8E7E88),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Legal Hero Banner ───────────────────────────────────────────────

class _LegalHeroBanner extends StatelessWidget {
  const _LegalHeroBanner({
    required this.isDark,
    required this.isRtl,
    required this.lang,
    required this.l10n,
  });

  final bool isDark;
  final bool isRtl;
  final String lang;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF5252);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C1E26), const Color(0xFF24161F)]
              : [const Color(0xFFFFF0F3), const Color(0xFFFFF7F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? coral.withValues(alpha: 0.3)
              : coral.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: coral.withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 3D Shield Watermark
            Positioned(
              right: isRtl ? null : -15,
              left: isRtl ? -15 : null,
              bottom: -15,
              child: IgnorePointer(
                child: Icon(
                  Icons.shield_rounded,
                  size: 130,
                  color: coral.withValues(alpha: isDark ? 0.08 : 0.06),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: coral.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00C853),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00C853),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lang == 'ar'
                              ? 'مشفر بالكامل ومحمي قانونياً 🔒'
                              : (lang == 'fr'
                                  ? 'Chiffré & 100% Conforme 🔒'
                                  : '100% Encrypted & Compliant 🔒'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: coral,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Headline
                  Text(
                    l10n.authPrivacyHeroTitle,
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF22161A),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Last updated
                  Text(
                    l10n.authPrivacyLastUpdated,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF755B64),
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
}

// ─── Bento Section Card ──────────────────────────────────────────────

class _BentoSectionCard extends StatelessWidget {
  const _BentoSectionCard({
    required this.number,
    required this.title,
    required this.content,
    required this.accentColor,
    required this.icon,
    required this.cardColor,
    required this.secondaryColor,
    required this.textColor,
    required this.isDark,
  });

  final String number;
  final String title;
  final String content;
  final Color accentColor;
  final IconData icon;
  final Color cardColor;
  final Color secondaryColor;
  final Color textColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEFE8EC),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Icon Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),

              const SizedBox(width: 10),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),

              // Number Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Content body
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: secondaryColor,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact & Support Bento Card ────────────────────────────────────

class _LegalContactCard extends StatelessWidget {
  const _LegalContactCard({
    required this.cardColor,
    required this.secondaryColor,
    required this.textColor,
    required this.isDark,
    required this.lang,
    required this.l10n,
  });

  final Color cardColor;
  final Color secondaryColor;
  final Color textColor;
  final bool isDark;
  final String lang;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF5252);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEFE8EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: coral.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: coral,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.authPrivacyQuestionsTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.authPrivacyContactEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: coral,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'ar'
                ? 'فريق الدعم وحماية المعطيات متواجد للإجابة على جميع تساؤلاتكِ.'
                : 'Notre équipe dédiée à la protection des données est à votre écoute.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
