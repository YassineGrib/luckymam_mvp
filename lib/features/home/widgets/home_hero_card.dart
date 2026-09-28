import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/profile_screen.dart';
import '../../profile/providers/profile_providers.dart';

/// Central Hero Companion Card on the Home Dashboard.
/// Features soft pastel gradients, double-bezel squircle contours,
/// dynamic profile completion tracking circle, tactile pill CTAs,
/// and contextual guidance for Mom/Pregnant/Hope states.
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

    final childrenAsync = ref.watch(childrenProvider);
    final children = childrenAsync.valueOrNull ?? const [];
    final completionPercentage = _calculateProfileCompletion(profile, children);

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
                            AppColors.primaryLight.withValues(
                              alpha: isDark ? 0.15 : 0.22,
                            ),
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
                      // Top Row: Category pill tag + Dynamic Profile Completion Circle
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

                          // Dynamic larger profile completion circle (48px)
                          _buildDynamicProgressIndicator(
                            context: context,
                            percentage: completionPercentage,
                            isDark: isDark,
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

                      const SizedBox(height: 20),

                      // Bottom Row: Profile status badge + tactile action pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProfileStatusBadge(
                            context,
                            profile,
                            completionPercentage,
                            isDark,
                          ),

                          // Dark high-contrast Pill button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF161618),
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

  /// Dynamic circular progress indicator showing real profile completion.
  /// 48px diameter with semi-transparent frosted center.
  Widget _buildDynamicProgressIndicator({
    required BuildContext context,
    required int percentage,
    required bool isDark,
  }) {
    final progress = (percentage / 100.0).clamp(0.0, 1.0);
    final strokeColor = AppColors.primaryLight;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.primaryLight.withValues(alpha: 0.18);
    final centerBg = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.55);

    return Tooltip(
      message: context.l10n.navProfile,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress ring
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(strokeColor),
                ),
              ),
              // Semi-transparent translucent center circle
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: centerBg,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.6),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E1B24),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatusBadge(
    BuildContext context,
    UserProfile? profile,
    int percentage,
    bool isDark,
  ) {
    final l10n = context.l10n;
    final name = profile?.displayName?.trim();
    final hasName = name != null && name.isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasName ? Icons.verified_user_rounded : Icons.person_outline_rounded,
              size: 14,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 5),
            Text(
              hasName ? name : l10n.navProfile,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF2C243B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateProfileCompletion(UserProfile? profile, List<Child> children) {
    if (profile == null) return 20;
    int score = 0;

    // 1. Account / Email active
    if (profile.email != null && profile.email!.trim().isNotEmpty) {
      score += 10;
    } else {
      score += 10;
    }

    // 2. Display Name
    if (profile.displayName != null && profile.displayName!.trim().isNotEmpty) {
      score += 20;
    }

    // 3. Profile Photo
    if (profile.photoUrl != null && profile.photoUrl!.trim().isNotEmpty) {
      score += 15;
    }

    // 4. Phone
    if (profile.phone != null && profile.phone!.trim().isNotEmpty) {
      score += 15;
    }

    // 5. Wilaya / Location
    if (profile.wilaya != null && profile.wilaya!.trim().isNotEmpty) {
      score += 15;
    }

    // 6. Contextual Status Data
    switch (profile.status) {
      case UserStatus.mom:
        if (children.isNotEmpty) {
          score += 25;
        } else if (profile.birthDate != null) {
          score += 15;
        }
        break;
      case UserStatus.pregnant:
        if (profile.lastPregnancyDate != null) {
          score += 25;
        } else if (profile.birthDate != null) {
          score += 15;
        }
        break;
      case UserStatus.hope:
        if (profile.cycleInfo.lastPeriodDate != null ||
            profile.cycleInfo.isTracking) {
          score += 25;
        } else if (profile.birthDate != null) {
          score += 15;
        }
        break;
    }

    return score.clamp(10, 100);
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
          tagText: l10n.dashboardHealthPregnancy.toUpperCase(),
          title: l10n.dashboardPregnantBannerTitle,
          subtitle: l10n.dashboardPregnantBannerSubtitle,
          buttonText: l10n.cycleActivateTracking,
        );
      case UserStatus.hope:
        return _HeroContent(
          tagIcon: Icons.wb_twilight_rounded,
          tagText: l10n.cycleTrackingTitle.toUpperCase(),
          title: l10n.dashboardHopeBannerTitle,
          subtitle: l10n.dashboardHopeBannerSubtitle,
          buttonText: l10n.cycleLogPeriod,
        );
      case UserStatus.mom:
        return _HeroContent(
          tagIcon: Icons.auto_awesome_rounded,
          tagText: l10n.homeYourChildren.toUpperCase(),
          title: l10n.dashboardMyMemories,
          subtitle: l10n.homeRecentCapsulesEmpty,
          buttonText: l10n.timeline_add,
        );
    }
  }
}

class _HeroContent {
  final IconData tagIcon;
  final String tagText;
  final String title;
  final String subtitle;
  final String buttonText;

  _HeroContent({
    required this.tagIcon,
    required this.tagText,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}
