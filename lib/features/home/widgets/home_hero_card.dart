import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/profile_screen.dart';
import '../../profile/providers/profile_providers.dart';

/// Central Hero Companion Card on the Home Dashboard.
/// Features soft pastel gradients, subtle asset pattern overlay,
/// double-bezel squircle contours, linear progress line with SVG logo dot,
/// and a prominent square black action card for capturing memories.
class HomeHeroCompanionCard extends ConsumerStatefulWidget {
  const HomeHeroCompanionCard({super.key});

  @override
  ConsumerState<HomeHeroCompanionCard> createState() =>
      _HomeHeroCompanionCardState();
}

class _HomeHeroCompanionCardState extends ConsumerState<HomeHeroCompanionCard>
    with SingleTickerProviderStateMixin {
  bool _isCardPressed = false;
  bool _isAddPressed = false;
  late AnimationController _animController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    // Emil Kowalski animation framework:
    // Starts fast for instant feedback, decelerates with silky-smooth cubic curve.
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isCardPressed = true),
        onTapUp: (_) {
          setState(() => _isCardPressed = false);
          _handleAction(context, status);
        },
        onTapCancel: () => setState(() => _isCardPressed = false),
        child: AnimatedScale(
          scale: _isCardPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: bgGradient,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.28)
                      : const Color(0xFFD6C8E6).withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  // Subtle calm asset pattern overlay across background
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDark ? 0.05 : 0.08,
                      child: Image.asset(
                        'assets/images/heroPatern.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        color: isDark ? Colors.white.withValues(alpha: 0.85) : null,
                      ),
                    ),
                  ),

                  // Decorative abstract corner glow
                  Positioned(
                    top: -20,
                    right: -20,
                    child: IgnorePointer(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryLight.withValues(
                                alpha: isDark ? 0.14 : 0.20,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main card content: Left side (Text + Progress Line), Right side (Big Square Action Button)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Column: Title, Subtitle, and Progress Line with SVG dot
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                content.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                content.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: subtextColor,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              // Progress Line with SVG Logo Dot
                              _buildProgressLine(
                                context: context,
                                percentage: completionPercentage,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Right: Big Square Black Action Button
                        _buildBigSquareActionCard(
                          context: context,
                          content: content,
                          status: status,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontal progress line with sliding SVG logo thumb dot.
  Widget _buildProgressLine({
    required BuildContext context,
    required int percentage,
    required bool isDark,
  }) {
    final l10n = context.l10n;
    final progressRatio = (percentage / 100.0).clamp(0.0, 1.0);
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.primaryLight.withValues(alpha: 0.18);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) {
        final animatedRatio =
            (_progressAnimation.value * progressRatio).clamp(0.0, 1.0);
        final currentPercent =
            (_progressAnimation.value * percentage).round();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Percentage & Profile label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentPercent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E1B24),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l10n.navProfile,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : const Color(0xFF6B6375),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Progress Track with Sliding SVG Logo Dot
              LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const thumbSize = 22.0;
                  const trackHeight = 5.0;
                  final travelDistance = (totalWidth - thumbSize).clamp(0.0, totalWidth);
                  final thumbOffset = travelDistance * animatedRatio;
                  final fillWidth = thumbOffset + (thumbSize / 2);

                  return SizedBox(
                    width: totalWidth,
                    height: thumbSize,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background track
                        Container(
                          width: totalWidth,
                          height: trackHeight,
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius:
                                BorderRadius.circular(trackHeight / 2),
                          ),
                        ),

                        // Filled active progress line
                        Container(
                          width: fillWidth.clamp(trackHeight, totalWidth),
                          height: trackHeight,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                Color(0xFFFF85A1),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(trackHeight / 2),
                          ),
                        ),

                        // SVG Logo Thumb Dot
                        Positioned(
                          left: thumbOffset.clamp(0.0, travelDistance),
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.16),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.primaryLight
                                    .withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2.5),
                            child: SvgPicture.asset(
                              'assets/logo/logo svg.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Big square softened dark action card with corner watermark icon (matching Bento / Quick Access design)
  Widget _buildBigSquareActionCard({
    required BuildContext context,
    required _HeroContent content,
    required UserStatus status,
    required bool isDark,
  }) {
    // Softened dark surface with subtle transparency so it doesn't appear overly harsh or dense
    final cardBg = isDark
        ? const Color(0xFF34283E).withValues(alpha: 0.78)
        : const Color(0xFF221B28).withValues(alpha: 0.82);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isAddPressed = true),
      onTapUp: (_) {
        setState(() => _isAddPressed = false);
        _handleAction(context, status);
      },
      onTapCancel: () => setState(() => _isAddPressed = false),
      child: AnimatedScale(
        scale: _isAddPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.20),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1627).withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Corner-bleeding Watermark Icon (Accès Rapide / Bento signature pattern)
                PositionedDirectional(
                  bottom: -10,
                  end: -8,
                  child: IgnorePointer(
                    child: Icon(
                      content.bigIcon,
                      size: 54,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),

                // Foreground Content: Top Action Icon + Bottom Label
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Frosted micro circle with action plus/camera icon
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                            width: 0.8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Bold Action Label
                      Text(
                        content.buttonText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          title: l10n.dashboardPregnantBannerTitle,
          subtitle: l10n.dashboardPregnantBannerSubtitle,
          buttonText: l10n.cycleActivateTracking,
          bigIcon: Icons.monitor_heart_rounded,
        );
      case UserStatus.hope:
        return _HeroContent(
          title: l10n.dashboardHopeBannerTitle,
          subtitle: l10n.dashboardHopeBannerSubtitle,
          buttonText: l10n.cycleLogPeriod,
          bigIcon: Icons.calendar_month_rounded,
        );
      case UserStatus.mom:
        return _HeroContent(
          title: l10n.dashboardMyMemories,
          subtitle: l10n.homeRecentCapsulesEmpty,
          buttonText: l10n.timeline_add,
          bigIcon: Icons.photo_camera_rounded,
        );
    }
  }
}

class _HeroContent {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData bigIcon;

  _HeroContent({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.bigIcon,
  });
}
