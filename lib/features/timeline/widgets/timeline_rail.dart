import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

import '../models/phase.dart';
import '../services/timeline_service.dart';

/// Status of a milestone node on the timeline
enum _NodeStatus { completed, overdue, current, upcoming }

/// A vertical "rail" timeline that shows milestones as nodes connected by a line.
class TimelineRail extends StatelessWidget {
  final List<MilestoneWithDueDate> milestones;
  final Phase phase;
  final void Function(MilestoneWithDueDate) onMilestoneTap;

  const TimelineRail({
    super.key,
    required this.milestones,
    required this.phase,
    required this.onMilestoneTap,
  });

  _NodeStatus _status(MilestoneWithDueDate m) {
    if (m.isCompleted) return _NodeStatus.completed;
    if (m.dueDate == null) return _NodeStatus.upcoming;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(m.dueDate!.year, m.dueDate!.month, m.dueDate!.day);
    if (due.isBefore(today.subtract(const Duration(days: 7)))) {
      return _NodeStatus.overdue;
    }
    if (due.isBefore(today.add(const Duration(days: 1)))) {
      return _NodeStatus.current;
    }
    return _NodeStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    // Sort by orderInPhase
    final sorted = List<MilestoneWithDueDate>.from(milestones)
      ..sort(
        (a, b) => a.milestone.orderInPhase.compareTo(b.milestone.orderInPhase),
      );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.sm,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final m = sorted[index];
        final status = _status(m);
        final isFirst = index == 0;
        final isLast = index == sorted.length - 1;

        return _TimelineNode(
          milestone: m,
          status: status,
          phase: phase,
          isFirst: isFirst,
          isLast: isLast,
          onTap: () => onMilestoneTap(m),
        );
      },
    );
  }
}

/// A single node in the timeline rail
class _TimelineNode extends StatelessWidget {
  final MilestoneWithDueDate milestone;
  final _NodeStatus status;
  final Phase phase;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineNode({
    required this.milestone,
    required this.status,
    required this.phase,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  Color get _nodeColor {
    switch (status) {
      case _NodeStatus.completed:
        return AppColors.success;
      case _NodeStatus.overdue:
        return AppColors.error;
      case _NodeStatus.current:
        return phase.color;
      case _NodeStatus.upcoming:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = milestone.milestone;
    final category = m.category;
    final isCurrent = status == _NodeStatus.current;
    final isCompleted = status == _NodeStatus.completed;
    final isOverdue = status == _NodeStatus.overdue;

    // Sizes
    const railWidth = 40.0;
    const dotSize = 20.0;
    const activeDotSize = 28.0;
    final currentDotSize = (isCurrent || isOverdue) ? activeDotSize : dotSize;

    // Text colors
    final titleColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Left rail (line + dot) ───
          SizedBox(
            width: railWidth,
            child: Column(
              children: [
                // Top segment of the line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isCompleted || isCurrent || isOverdue
                                ? _nodeColor.withValues(alpha: 0.6)
                                : Colors.grey.withValues(alpha: 0.25),
                            _nodeColor.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),

                // The dot / node
                _buildDot(currentDotSize, isDark),

                // Bottom segment of the line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      color: _nodeColor.withValues(alpha: 0.25),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ─── Right content card ───
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(
                  top: isFirst ? 0 : 6,
                  bottom: isLast ? 80 : 6,
                ),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCurrent
                        ? _nodeColor
                        : isOverdue
                        ? AppColors.error.withValues(alpha: 0.5)
                        : isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                    width: isCurrent ? 2 : 1,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: _nodeColor.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: category chip + date
                    Row(
                      children: [
                        // Category icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: category.lightBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              category.icon,
                              size: 16,
                              color: category.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Title
                        Expanded(
                          child: Text(
                            m.titleFr,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? subtitleColor : titleColor,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status badge
                        _buildStatusBadge(isDark),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      m.descriptionFr,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Bottom row: age range + due date + action
                    Row(
                      children: [
                        // Age range chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: phase.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.ageRange,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: phase.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Due date
                        if (milestone.dueDate != null)
                          Text(
                            _formatDue(milestone),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: isOverdue
                                  ? AppColors.error
                                  : subtitleColor,
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        const Spacer(),
                        // Action hint
                        if (m.canHaveCapsule && !isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Capturer',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
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
                            size: 18,
                            color: subtitleColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double size, bool isDark) {
    final isBig =
        status == _NodeStatus.current || status == _NodeStatus.overdue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status == _NodeStatus.upcoming
            ? (isDark ? AppColors.surfaceDark : Colors.white)
            : _nodeColor,
        border: Border.all(color: _nodeColor, width: isBig ? 3 : 2),
        boxShadow: isBig
            ? [
                BoxShadow(
                  color: _nodeColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: status == _NodeStatus.completed
            ? Icon(Icons.check_rounded, size: size * 0.6, color: Colors.white)
            : status == _NodeStatus.overdue
            ? Icon(
                Icons.priority_high_rounded,
                size: size * 0.55,
                color: Colors.white,
              )
            : status == _NodeStatus.current
            ? Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case _NodeStatus.completed:
        label = '✓';
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        break;
      case _NodeStatus.overdue:
        label = 'En retard';
        bgColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        break;
      case _NodeStatus.current:
        label = 'Maintenant';
        bgColor = phase.color.withValues(alpha: 0.12);
        textColor = phase.color;
        break;
      case _NodeStatus.upcoming:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDue(MilestoneWithDueDate m) {
    if (m.dueDate == null) return '';
    final now = DateTime.now();
    final diff = m.dueDate!.difference(now).inDays;
    if (diff.abs() < 1) return "Aujourd'hui";
    if (diff < 0) return 'il y a ${-diff}j';
    if (diff <= 30) return 'dans ${diff}j';
    if (diff <= 365) {
      final months = (diff / 30).round();
      return 'dans $months mois';
    }
    final years = (diff / 365).round();
    return 'dans $years an${years > 1 ? 's' : ''}';
  }
}
