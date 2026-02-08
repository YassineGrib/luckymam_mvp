import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/providers/profile_providers.dart';
import '../../timeline/models/phase.dart';
import '../../timeline/screens/milestone_detail_screen.dart';
import '../../timeline/services/timeline_service.dart';
import '../providers/home_providers.dart';

/// Hero card displaying today's most important milestone.
class TodayMilestoneCard extends ConsumerWidget {
  const TodayMilestoneCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final milestone = ref.watch(heroMilestoneProvider);
    final selectedChild = ref.watch(selectedChildProvider).value;

    if (milestone == null) {
      return _buildEmptyState(context, isDark);
    }

    return _buildMilestoneCard(context, ref, milestone, isDark, selectedChild);
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 40,
            color: textColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Pas de jalon aujourd\'hui',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Profitez de cette journée tranquille!',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    WidgetRef ref,
    MilestoneWithDueDate milestone,
    bool isDark,
    child,
  ) {
    final m = milestone.milestone;
    final category = m.category;

    // Gradient based on category
    final gradientColors = isDark
        ? [AppColors.magentaPink, AppColors.coral]
        : [category.color, category.color.withValues(alpha: 0.7)];

    return GestureDetector(
      onTap: () {
        if (child != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MilestoneDetailScreen(
                milestone: milestone,
                childId: child.id,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern Overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/heroPatern.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.volunteer_activism_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AUJOURD\'HUI',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(category.icon, size: 32, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Milestone title
                  Text(
                    m.titleFr,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    m.descriptionFr,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  // CTA Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (child != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MilestoneDetailScreen(
                                  milestone: milestone,
                                  childId: child.id,
                                ),
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 20,
                                color: gradientColors.first,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Capturer ce moment',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: gradientColors.first,
                                ),
                              ),
                            ],
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
    );
  }
}
