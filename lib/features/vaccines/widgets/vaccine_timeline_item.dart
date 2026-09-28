import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/vaccine_status.dart';

/// Renders a single vaccination card within a connected vertical timeline rail.
class VaccineTimelineItem extends StatelessWidget {
  final Widget child;
  final VaccineStatusType statusType;
  final bool isFirst;
  final bool isLast;

  const VaccineTimelineItem({
    super.key,
    required this.child,
    required this.statusType,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color nodeColor;
    final IconData nodeIcon;
    final bool isCompleted = statusType == VaccineStatusType.completed;
    final bool isOverdue = statusType == VaccineStatusType.overdue;
    final bool isDueSoon = statusType == VaccineStatusType.dueSoon;

    if (isCompleted) {
      nodeColor = AppColors.success;
      nodeIcon = Icons.check_rounded;
    } else if (isOverdue) {
      nodeColor = AppColors.error;
      nodeIcon = Icons.priority_high_rounded;
    } else if (isDueSoon) {
      nodeColor = AppColors.warning;
      nodeIcon = Icons.schedule_rounded;
    } else {
      nodeColor = isDark ? Colors.white30 : const Color(0xFFCDC9D5);
      nodeIcon = Icons.circle;
    }

    const double nodeSize = 26.0;
    const double railWidth = 32.0;

    final lineColor = isCompleted
        ? AppColors.success.withValues(alpha: 0.45)
        : (isDark ? Colors.white12 : const Color(0xFFE5E2EB));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline rail (line + node) ──
          SizedBox(
            width: railWidth,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical Line
                Positioned.fill(
                  top: isFirst ? 26 : 0,
                  bottom: isLast ? null : 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2.2,
                      height: isLast ? 26 : double.infinity,
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Indicator Node
                Positioned(
                  top: 18,
                  child: Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.success
                          : (isOverdue
                              ? AppColors.error
                              : (isDueSoon
                                  ? AppColors.warning
                                  : (isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white))),
                      border: Border.all(
                        color: nodeColor,
                        width: 2.0,
                      ),
                      boxShadow: (isCompleted || isOverdue || isDueSoon)
                          ? [
                              BoxShadow(
                                color: nodeColor.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted || isOverdue || isDueSoon
                          ? Icon(
                              nodeIcon,
                              size: 14,
                              color: Colors.white,
                            )
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: nodeColor,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── The Vaccine Card ──
          Expanded(child: child),
        ],
      ),
    );
  }
}
