import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/analytics_service.dart';
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
    final lang = Localizations.localeOf(context).languageCode;
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
                    m.getTitle(lang),
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
                    m.getDescription(lang),
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
            // Thumbnail or souvenir badge
            if (milestone.capsuleId != null)
              _MilestoneThumbnail(milestone: milestone)
            else if (m.canHaveCapsule)
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
                      lang == 'ar' ? 'توثيق' : lang == 'en' ? 'Capture' : 'Capturer',
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
    final lang = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('d MMM', lang);
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
                m.getTitle(lang),
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
            // Capsule badge or days until due
            if (milestone.capsuleId != null)
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.success,
              )
            else
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

/// Shows a capsule thumbnail if available, otherwise the "Souvenir ✓" badge.
/// Fires milestone_thumbnail_rendered analytics on first paint.
class _MilestoneThumbnail extends StatefulWidget {
  const _MilestoneThumbnail({required this.milestone});
  final MilestoneWithDueDate milestone;

  @override
  State<_MilestoneThumbnail> createState() => _MilestoneThumbnailState();
}

class _MilestoneThumbnailState extends State<_MilestoneThumbnail> {
  bool _analyticsLogged = false;

  @override
  Widget build(BuildContext context) {
    final url = widget.milestone.thumbnailUrl;

    if (url != null && url.isNotEmpty) {
      if (!_analyticsLogged) {
        _analyticsLogged = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AnalyticsService().logEvent(
            'milestone_thumbnail_rendered',
            parameters: {
              'milestone_id': widget.milestone.milestone.id,
              'capsule_id': widget.milestone.capsuleId ?? '',
            },
          );
        });
      }

      final isDark = Theme.of(context).brightness == Brightness.dark;
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 56,
              height: 56,
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.magentaPink,
                    ),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              _souveniurBadge(),
        ),
      );
    }

    return _souveniurBadge();
  }

  Widget _souveniurBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 15),
          const SizedBox(width: 4),
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'ذكرى'
                : Localizations.localeOf(context).languageCode == 'en'
                    ? 'Memory'
                    : 'Souvenir',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
