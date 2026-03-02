import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/milestone.dart';
import '../models/phase.dart';
import '../services/timeline_service.dart';

/// View mode toggle for the timeline — controlled by parent (timeline_screen)
enum TimelineViewMode { horizontal, vertical }

/// Status of a milestone node
enum _NodeStatus { completed, overdue, current, upcoming }

// ─────────────────────────────────────────────────────────────────────────────
// TimelineRail — view mode is controlled externally via [viewMode]
// The toggle button lives in the screen's title bar (trailing slot)
// ─────────────────────────────────────────────────────────────────────────────
class TimelineRail extends StatelessWidget {
  final List<MilestoneWithDueDate> milestones;
  final Phase phase;
  final void Function(MilestoneWithDueDate) onMilestoneTap;

  /// Controlled from outside — drives horizontal vs vertical layout
  final TimelineViewMode viewMode;

  const TimelineRail({
    super.key,
    required this.milestones,
    required this.phase,
    required this.onMilestoneTap,
    required this.viewMode,
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

    final sorted = List<MilestoneWithDueDate>.from(milestones)
      ..sort(
        (a, b) => a.milestone.orderInPhase.compareTo(b.milestone.orderInPhase),
      );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: viewMode == TimelineViewMode.horizontal
          ? _HorizontalTimeline(
              key: const ValueKey('horizontal'),
              milestones: sorted,
              phase: phase,
              statusOf: _status,
              onTap: onMilestoneTap,
            )
          : _VerticalTimeline(
              key: const ValueKey('vertical'),
              milestones: sorted,
              phase: phase,
              statusOf: _status,
              onTap: onMilestoneTap,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal timeline (cards in a row with dot connectors)
// ─────────────────────────────────────────────────────────────────────────────
class _HorizontalTimeline extends StatelessWidget {
  const _HorizontalTimeline({
    super.key,
    required this.milestones,
    required this.phase,
    required this.statusOf,
    required this.onTap,
  });

  final List<MilestoneWithDueDate> milestones;
  final Phase phase;
  final _NodeStatus Function(MilestoneWithDueDate) statusOf;
  final void Function(MilestoneWithDueDate) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.xs,
      ),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final m = milestones[index];
        final status = statusOf(m);
        return _HorizontalNode(
          milestone: m,
          status: status,
          phase: phase,
          isFirst: index == 0,
          isLast: index == milestones.length - 1,
          onTap: () => onTap(m),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical timeline (classic rail with line on the left)
// ─────────────────────────────────────────────────────────────────────────────
class _VerticalTimeline extends StatelessWidget {
  const _VerticalTimeline({
    super.key,
    required this.milestones,
    required this.phase,
    required this.statusOf,
    required this.onTap,
  });

  final List<MilestoneWithDueDate> milestones;
  final Phase phase;
  final _NodeStatus Function(MilestoneWithDueDate) statusOf;
  final void Function(MilestoneWithDueDate) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.xs,
      ),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final m = milestones[index];
        final status = statusOf(m);
        return _VerticalNode(
          milestone: m,
          status: status,
          phase: phase,
          isFirst: index == 0,
          isLast: index == milestones.length - 1,
          onTap: () => onTap(m),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
Color _nodeColor(_NodeStatus status, Phase phase) {
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

/// LuckyMam SVG logo as a connector node
Widget _luckymamLogo(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.12),
      border: Border.all(color: color, width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ],
    ),
    child: ClipOval(
      child: Padding(
        padding: EdgeInsets.all(size * 0.15),
        child: SvgPicture.asset(
          'assets/logo/logo svg.svg',
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    ),
  );
}

/// Completed capsule icon (checkmark with camera overlay)
Widget _completedIcon(double size) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success,
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: size * 0.55,
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: Container(
          width: size * 0.38,
          height: size * 0.38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            Icons.photo_camera_rounded,
            color: AppColors.success,
            size: size * 0.22,
          ),
        ),
      ),
    ],
  );
}

Widget _buildStatusBadge(_NodeStatus status, Phase phase) {
  String label;
  Color bgColor;
  Color textColor;

  switch (status) {
    case _NodeStatus.completed:
      label = '✓ Réalisé';
      bgColor = AppColors.success.withValues(alpha: 0.15);
      textColor = AppColors.success;
      break;
    case _NodeStatus.overdue:
      label = 'À rattraper';
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

String _formatCompletedDate(DateTime date) {
  return DateFormat('d MMM yyyy', 'fr_FR').format(date);
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal node
// ─────────────────────────────────────────────────────────────────────────────
class _HorizontalNode extends StatelessWidget {
  const _HorizontalNode({
    required this.milestone,
    required this.status,
    required this.phase,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final MilestoneWithDueDate milestone;
  final _NodeStatus status;
  final Phase phase;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = milestone.milestone;

    final isCurrent = status == _NodeStatus.current;
    final isCompleted = status == _NodeStatus.completed;
    final isOverdue = status == _NodeStatus.overdue;
    final color = _nodeColor(status, phase);

    final titleColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    const cardWidth = 200.0;
    const dotSize = 22.0;
    const activeDotSize = 30.0;
    final currentDotSize = (isCurrent || isOverdue) ? activeDotSize : dotSize;

    return SizedBox(
      width: cardWidth + 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Connector row: line — logo/dot — line ──────────────
          SizedBox(
            height: activeDotSize + 4,
            child: Row(
              children: [
                // Left line
                Expanded(
                  child: isFirst
                      ? const SizedBox()
                      : Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.25),
                                color.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                ),

                // Dot — logo LuckyMam for active/overdue
                isCompleted
                    ? _completedIcon(currentDotSize)
                    : isOverdue
                    ? _luckymamLogo(currentDotSize, AppColors.error)
                    : isCurrent
                    ? _luckymamLogo(currentDotSize, phase.color)
                    : _plainDot(dotSize, color, isDark),

                // Right line
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : Container(
                          height: 2.5,
                          color: color.withValues(alpha: 0.25),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Card ──────────────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            child: _MilestoneCard(
              m: m,
              milestone: milestone,
              status: status,
              phase: phase,
              isDark: isDark,
              isCompleted: isCompleted,
              isOverdue: isOverdue,
              isCurrent: isCurrent,
              color: color,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              width: cardWidth,
              isHorizontal: true,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _plainDot(double size, Color color, bool isDark) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      border: Border.all(color: color, width: 2),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical node
// ─────────────────────────────────────────────────────────────────────────────
class _VerticalNode extends StatelessWidget {
  const _VerticalNode({
    required this.milestone,
    required this.status,
    required this.phase,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final MilestoneWithDueDate milestone;
  final _NodeStatus status;
  final Phase phase;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = milestone.milestone;
    final isCurrent = status == _NodeStatus.current;
    final isCompleted = status == _NodeStatus.completed;
    final isOverdue = status == _NodeStatus.overdue;
    final color = _nodeColor(status, phase);

    final titleColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    const railWidth = 44.0;
    const dotSize = 22.0;
    const activeDotSize = 30.0;
    final currentDotSize = (isCurrent || isOverdue) ? activeDotSize : dotSize;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left rail: line + logo/dot ─────────────────────────
          SizedBox(
            width: railWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isFirst)
                  Container(
                    width: 2.5,
                    height: 16,
                    color: color.withValues(alpha: 0.5),
                  )
                else
                  const SizedBox(height: 16),

                // Node icon
                isCompleted
                    ? _completedIcon(currentDotSize)
                    : isOverdue
                    ? _luckymamLogo(currentDotSize, AppColors.error)
                    : isCurrent
                    ? _luckymamLogo(currentDotSize, phase.color)
                    : _plainDot(dotSize, color, isDark),

                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 16,
                    color: color.withValues(alpha: 0.25),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Card ───────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: _MilestoneCard(
                m: m,
                milestone: milestone,
                status: status,
                phase: phase,
                isDark: isDark,
                isCompleted: isCompleted,
                isOverdue: isOverdue,
                isCurrent: isCurrent,
                color: color,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                isHorizontal: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card content (used by both horizontal and vertical nodes)
// ─────────────────────────────────────────────────────────────────────────────
class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.m,
    required this.milestone,
    required this.status,
    required this.phase,
    required this.isDark,
    required this.isCompleted,
    required this.isOverdue,
    required this.isCurrent,
    required this.color,
    required this.titleColor,
    required this.subtitleColor,
    required this.isHorizontal,
    this.width,
  });

  final Milestone m;
  final MilestoneWithDueDate milestone;
  final _NodeStatus status;
  final Phase phase;
  final bool isDark;
  final bool isCompleted;
  final bool isOverdue;
  final bool isCurrent;
  final Color color;
  final Color titleColor;
  final Color subtitleColor;
  final bool isHorizontal;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.only(
        right: isHorizontal ? 16 : 0,
        top: isHorizontal ? 0 : 6,
        bottom: isHorizontal ? 0 : 6,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? color
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
                  color: color.withValues(alpha: 0.18),
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
          // Category icon + status badge
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: m.category.lightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    m.category.icon,
                    size: 14,
                    color: m.category.color,
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(status, phase),
            ],
          ),

          const SizedBox(height: 8),

          // Title — clean, no strikethrough
          Text(
            m.titleFr,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isCompleted ? subtitleColor : titleColor,
            ),
            maxLines: isHorizontal ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Description
          Text(
            m.descriptionFr,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: subtitleColor,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Date row: completed date OR due date + age range
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: phase.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m.ageRange,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: phase.color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: isCompleted && milestone.completedAt != null
                    ? Row(
                        children: [
                          const Icon(
                            Icons.event_available_rounded,
                            size: 11,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              _formatCompletedDate(milestone.completedAt!),
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : milestone.dueDate != null
                    ? Text(
                        _formatDue(milestone),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: isOverdue ? AppColors.error : subtitleColor,
                          fontWeight: isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),

          // Capture CTA for actionable, non-completed milestones
          if (m.canHaveCapsule && !isCompleted) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Capturer',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // "Voir la capsule" CTA for completed milestones with capsule
          if (isCompleted && milestone.capsuleId != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.success,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Voir la capsule',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
