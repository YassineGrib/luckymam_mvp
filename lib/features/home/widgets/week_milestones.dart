import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/providers/profile_providers.dart';
import '../../timeline/models/phase.dart';
import '../../timeline/screens/milestone_detail_screen.dart';
import '../../timeline/services/timeline_service.dart';
import '../providers/home_providers.dart';

/// Vertical list of upcoming milestones for this week.
class WeekMilestones extends ConsumerWidget {
  const WeekMilestones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    final milestones = ref.watch(weekMilestonesProvider);
    final selectedChild = ref.watch(selectedChildProvider).value;

    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'CETTE SEMAINE',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Milestones list
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: Column(
            children: milestones.asMap().entries.map((entry) {
              final index = entry.key;
              final milestone = entry.value;
              final isLast = index == milestones.length - 1;

              return _buildMilestoneItem(
                context: context,
                milestone: milestone,
                textColor: textColor,
                secondaryColor: secondaryColor,
                isDark: isDark,
                isLast: isLast,
                childId: selectedChild?.id,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem({
    required BuildContext context,
    required MilestoneWithDueDate milestone,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
    required bool isLast,
    required String? childId,
  }) {
    final m = milestone.milestone;
    final category = m.category;
    final daysUntil = milestone.daysUntilDue;

    String dueLabel;
    if (daysUntil == 0) {
      dueLabel = 'Aujourd\'hui';
    } else if (daysUntil == 1) {
      dueLabel = 'Demain';
    } else if (milestone.dueDate != null) {
      dueLabel = DateFormat('EEEE', 'fr_FR').format(milestone.dueDate!);
    } else {
      dueLabel = 'J+$daysUntil';
    }

    return InkWell(
      onTap: () {
        if (childId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  MilestoneDetailScreen(milestone: milestone, childId: childId),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(category.icon, size: 16, color: category.color),
              ),
            ),
            const SizedBox(width: 14),
            // Title and due date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.titleFr,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dueLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: daysUntil <= 1 ? category.color : secondaryColor,
                      fontWeight: daysUntil <= 1
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(Icons.chevron_right_rounded, color: secondaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
