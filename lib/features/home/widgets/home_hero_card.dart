import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/home_providers.dart';

/// Central Hero Companion Card on the Home Dashboard.
/// Inspired by the flagship cards in modern lifestyle/health mobile apps.
/// Features soft pastel gradients, double-bezel squircle contours,
/// tactile pill CTAs, and contextual guidance for Mom/Pregnant/Hope states.
class HomeHeroCompanionCard extends ConsumerStatefulWidget {
  const HomeHeroCompanionCard({super.key});

  @override
  ConsumerState<HomeHeroCompanionCard> createState() =>
      _HomeHeroCompanionCardState();
}

class _HomeHeroCompanionCardState extends ConsumerState<HomeHeroCompanionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    final status = profile?.status ?? UserStatus.mom;
    final tip = ref.watch(dailyTipProvider);

    final l10n = context.l10n;

    // Palette & Content based on user status
    final content = _resolveContent(status, profile, l10n);

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF281C30), Color(0xFF231B26)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1E9FD), Color(0xFFFFEEF3)],
          );

    final textColor = isDark ? Colors.white : const Color(0xFF1D1B20);
    final subtextColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF5A5364);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _handleAction(context, status);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: bgGradient,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFFD6C8E6).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative abstract floating glow / ring in the corner
                Positioned(
                  top: -24,
                  right: -24,
                  child: IgnorePointer(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryLight.withValues(alpha: isDark ? 0.15 : 0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main card content
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Category pill tag + progress circle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  content.tagIcon,
                                  size: 13,
                                  color: AppColors.primaryLight,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  content.tagText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF2C243B),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Circular indicator pill (e.g. "2/3" or trimester or streak)
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.9),
                              border: Border.all(
                                color: AppColors.primaryLight.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              content.progressText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E1B24),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Headline
                      Text(
                        content.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle / guidance
                      Text(
                        content.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: subtextColor,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── Integrated Daily Tip Bubble ─────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFD6C8E6).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              size: 15,
                              color: AppColors.casablanca,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Bottom Row: Avatar stack + tactile action pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Social / Milestones avatar stack
                          _buildAvatarStack(isDark),

                          // Dark high-contrast Pill button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : const Color(0xFF161618),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  content.buttonText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF161618)
                                        : Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFF161618)
                                      : Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildAvatarStack(bool isDark) {
    final border = Border.all(
      color: isDark ? const Color(0xFF281C30) : const Color(0xFFF1E9FD),
      width: 2,
    );

    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF8FA3),
              border: border,
            ),
            child: const Icon(Icons.child_care_rounded, size: 16, color: Colors.white),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8E94F2),
                border: border,
              ),
              child: const Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
            ),
          ),
          Transform.translate(
            offset: const Offset(-16, 0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5CC8A5),
                border: border,
              ),
              child: const Icon(Icons.verified_user_rounded, size: 14, color: Colors.white),
            ),
          ),
          Transform.translate(
            offset: const Offset(-20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFF2C243B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+3',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, UserStatus status) {
    if (status == UserStatus.pregnant || status == UserStatus.hope) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HealthHubScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
      );
    }
  }

  _HeroContent _resolveContent(
    UserStatus status,
    UserProfile? profile,
    dynamic l10n,
  ) {
    switch (status) {
      case UserStatus.pregnant:
        return _HeroContent(
          tagIcon: Icons.pregnant_woman_rounded,
          tagText: 'SUIVI GROSSESSE',
          progressText: 'T2',
          title: 'Bébé grandit chaque jour',
          subtitle: 'Semaine 24 • Enregistrez les mouvements et votre hydratation',
          buttonText: 'SUIVRE',
        );
      case UserStatus.hope:
        return _HeroContent(
          tagIcon: Icons.wb_twilight_rounded,
          tagText: 'CYCLE & FERTILITÉ',
          progressText: 'J14',
          title: 'Fenêtre de Fertilité Optimale',
          subtitle: 'Phase ovulatoire • Écoutez votre corps et notez vos ressentis',
          buttonText: 'NOTER',
        );
      case UserStatus.mom:
        return _HeroContent(
          tagIcon: Icons.auto_awesome_rounded,
          tagText: 'ESPACE MAMAN',
          progressText: '100%',
          title: 'Chaque instant est précieux',
          subtitle: 'Capturez un sourire ou une nouvelle découverte aujourd\'hui',
          buttonText: 'CAPTURER',
        );
    }
  }
}

class _HeroContent {
  final IconData tagIcon;
  final String tagText;
  final String progressText;
  final String title;
  final String subtitle;
  final String buttonText;

  _HeroContent({
    required this.tagIcon,
    required this.tagText,
    required this.progressText,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}
