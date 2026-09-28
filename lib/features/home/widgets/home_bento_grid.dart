import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capsules/screens/create_capsule_screen.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../reels/screens/reels_screen.dart';

/// Asymmetric Bento Grid layout with aesthetic corner-bleeding watermark icons
/// and zero RenderFlex overflows.
/// - Left: Tall Health & Vitality Card with clipped corner watermark.
/// - Right Top: Memory Capsule Card with clipped corner watermark.
/// - Right Bottom: Dedicated Reels & Video Tips Card with clipped corner watermark.
class HomeBentoGrid extends ConsumerWidget {
  const HomeBentoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileProvider);
    final status = profileAsync.valueOrNull?.status ?? UserStatus.mom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Left Tall Bento Card (Santé & Suivi) ───────────────────
          Expanded(
            flex: 5,
            child: _TallHealthBentoCard(isDark: isDark, status: status),
          ),
          const SizedBox(width: 14),

          // ─── Right Stacked Bento Cards ──────────────────────────────
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Top: Capsule Capture card (spacious, watermark in corner)
                _MemoryBentoCard(isDark: isDark),
                const SizedBox(height: 14),
                // Bottom: Dedicated Reels card (spacious, watermark in corner)
                _ReelsBentoCard(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Left Tall Card: Health & Vitality ───────────────────────────────────────

class _TallHealthBentoCard extends StatefulWidget {
  final bool isDark;
  final UserStatus status;

  const _TallHealthBentoCard({required this.isDark, required this.status});

  @override
  State<_TallHealthBentoCard> createState() => _TallHealthBentoCardState();
}

class _TallHealthBentoCardState extends State<_TallHealthBentoCard> {
  bool _pressed = false;

  IconData _watermarkIcon(UserStatus status) {
    switch (status) {
      case UserStatus.pregnant:
        return Icons.pregnant_woman_rounded;
      case UserStatus.hope:
        return Icons.spa_rounded;
      case UserStatus.mom:
        return Icons.child_care_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    final bg = isDark ? const Color(0xFF281F15) : const Color(0xFFFFF2DF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFFFDFB5);
    final textColor = isDark ? Colors.white : const Color(0xFF2B1D0E);
    final subtextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF7A5832);

    final watermarkIcon = _watermarkIcon(widget.status);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HealthHubScreen()),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          height: 226,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFFF0D5B5).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // ─── Watermark Icon Shifted Further Down & Right ─────
                // Only a portion is visible inside the card (~65%),
                // and the rest is elegantly clipped off the corner.
                Positioned(
                  bottom: -36,
                  right: -30,
                  child: IgnorePointer(
                    child: Icon(
                      watermarkIcon,
                      size: 132,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFE8833A).withValues(alpha: 0.10),
                    ),
                  ),
                ),

                // ─── Foreground Content ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    size: 12,
                                    color: Color(0xFFE8833A),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.status == UserStatus.pregnant
                                          ? 'Grossesse'
                                          : widget.status == UserStatus.hope
                                              ? 'Cycle'
                                              : 'Bébé',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF5A3915),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: subtextColor,
                          ),
                        ],
                      ),

                      // Title and details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.status == UserStatus.pregnant
                                ? 'Vitalité & Mouvements'
                                : widget.status == UserStatus.hope
                                    ? 'Cycle & Ovulation'
                                    : 'Santé & Éveil',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Suivi quotidien • Bien-être',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: subtextColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),

                      // Bottom Caregiver / Specialist snippet (No overflow guaranteed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Dr. Suivi',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    'Mon carnet',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: subtextColor,
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
        ),
      ),
    );
  }
}

// ─── Right Top Card: Memory Capture ──────────────────────────────────────────

class _MemoryBentoCard extends StatefulWidget {
  final bool isDark;

  const _MemoryBentoCard({required this.isDark});

  @override
  State<_MemoryBentoCard> createState() => _MemoryBentoCardState();
}

class _MemoryBentoCardState extends State<_MemoryBentoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF182332) : const Color(0xFFE8F3FF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFC7E2FF);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2640);
    final subtextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF386088);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          height: 106,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : const Color(0xFFC2DCF7).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ─── Watermark Camera Shifted Further Down & Right ───
                Positioned(
                  bottom: -26,
                  right: -20,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 94,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFF2C74B3).withValues(alpha: 0.11),
                    ),
                  ),
                ),

                // ─── Foreground Content ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'MÉMOIRE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF1E5185),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 15,
                            color: subtextColor,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capsule du Jour',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Créer un souvenir ↗',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
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
}

// ─── Right Bottom Card: Dedicated Reels ──────────────────────────────────────

class _ReelsBentoCard extends StatefulWidget {
  final bool isDark;

  const _ReelsBentoCard({required this.isDark});

  @override
  State<_ReelsBentoCard> createState() => _ReelsBentoCardState();
}

class _ReelsBentoCardState extends State<_ReelsBentoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF2C1924) : const Color(0xFFFDE8F3);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF9C6E3);
    final textColor = isDark ? Colors.white : const Color(0xFF4A1535);
    final subtextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF8E3B68);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReelsScreen()),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          height: 106,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : const Color(0xFFF5CFE3).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ─── Watermark Play Icon Shifted Further Down & Right ─
                Positioned(
                  bottom: -26,
                  right: -20,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 94,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFF8E44AD).withValues(alpha: 0.11),
                    ),
                  ),
                ),

                // ─── Foreground Content ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 11,
                                    color: Color(0xFF8E44AD),
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'REELS',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF8E44AD),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 15,
                            color: subtextColor,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Astuces & Vidéos',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Conseils sages-femmes ↗',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
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
}
