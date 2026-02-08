import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/milestone.dart';
import '../models/phase.dart';
import '../services/timeline_service.dart';

/// Card displaying a single milestone
class MilestoneCard extends StatelessWidget {
  final MilestoneWithDueDate milestone;
  final bool isToday;
  final bool compact;
  final VoidCallback? onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.isToday = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = milestone.milestone;
    final category = m.category;

    if (compact) {
      return _buildCompactCard(context, isDark, m, category);
    }

    return _buildFullCard(context, isDark, m, category);
  }

  Widget _buildFullCard(
    BuildContext context,
    bool isDark,
    Milestone m,
    MilestoneCategory category,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? category.color
                : isDark
                ? AppColors.dividerDark
                : AppColors.dividerLight,
            width: isToday ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isToday ? category.color : Colors.black).withValues(
                alpha: 0.08,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(category.icon, size: 24, color: category.color),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.titleFr,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.descriptionFr,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Action button
            if (m.canHaveCapsule)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Capturer',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    bool isDark,
    Milestone m,
    MilestoneCategory category,
  ) {
    final dateFormat = DateFormat('d MMM', 'fr_FR');
    final dueText = milestone.dueDate != null
        ? dateFormat.format(milestone.dueDate!)
        : m.ageRange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            // Category indicator
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Icon
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: AppSpacing.sm),
            // Title
            Expanded(
              child: Text(
                m.titleFr,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.onSurfaceDark
                      : AppColors.onSurfaceLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Days until due
            Text(
              milestone.daysUntilDue > 0
                  ? 'J+${milestone.daysUntilDue}'
                  : dueText,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: category.color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
