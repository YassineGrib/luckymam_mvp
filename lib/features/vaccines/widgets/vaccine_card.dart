import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../../vaccines/providers/vaccine_providers.dart';

/// Card widget displaying a vaccine group with its status.
class VaccineCard extends StatelessWidget {
  const VaccineCard({
    super.key,
    required this.vaccineGroup,
    required this.onMarkComplete,
    required this.onMarkIncomplete,
  });

  final VaccineGroupWithStatus vaccineGroup;
  final VoidCallback onMarkComplete;
  final VoidCallback onMarkIncomplete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(isDark), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: vaccineGroup.isCompleted ? onMarkIncomplete : onMarkComplete,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with status icon and age
                Row(
                  children: [
                    _buildStatusIcon(isDark, primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vaccineGroup.group.ageFr,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildStatusText(secondaryText, primary),
                        ],
                      ),
                    ),
                    _buildActionButton(isDark, primary, textColor),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Vaccine list
                ...vaccineGroup.group.vaccines.map(
                  (vaccine) => Padding(
                    padding: const EdgeInsets.only(
                      left: 44,
                      top: AppSpacing.xxs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: vaccineGroup.isCompleted
                                ? AppColors.success
                                : secondaryText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            vaccine.code,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notes if completed
                if (vaccineGroup.status?.notes != null &&
                    vaccineGroup.status!.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 14,
                            color: secondaryText,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              vaccineGroup.status!.notes!,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        return AppColors.success.withValues(alpha: 0.5);
      case VaccineStatusType.overdue:
        return AppColors.error.withValues(alpha: 0.5);
      case VaccineStatusType.dueSoon:
        return AppColors.warning.withValues(alpha: 0.5);
      case VaccineStatusType.upcoming:
        return isDark ? AppColors.dividerDark : AppColors.dividerLight;
    }
  }

  Widget _buildStatusIcon(bool isDark, Color primary) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        icon = Icons.check_circle_rounded;
        color = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.15);
        break;
      case VaccineStatusType.overdue:
        icon = Icons.warning_rounded;
        color = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.15);
        break;
      case VaccineStatusType.dueSoon:
        icon = Icons.schedule_rounded;
        color = AppColors.warning;
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        break;
      case VaccineStatusType.upcoming:
        icon = Icons.calendar_today_rounded;
        color = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        bgColor = color.withValues(alpha: 0.1);
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusText(Color secondaryText, Color primary) {
    String text;
    Color color = secondaryText;

    switch (vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        final date = vaccineGroup.status?.completedAt;
        text = date != null
            ? 'Fait le ${DateFormat('d MMM yyyy', 'fr').format(date)}'
            : 'Complété';
        color = AppColors.success;
        break;
      case VaccineStatusType.overdue:
        text = 'En retard de ${-vaccineGroup.daysUntilDue} jours';
        color = AppColors.error;
        break;
      case VaccineStatusType.dueSoon:
        if (vaccineGroup.daysUntilDue == 0) {
          text = 'Prévu aujourd\'hui';
        } else {
          text = 'Dans ${vaccineGroup.daysUntilDue} jours';
        }
        color = AppColors.casablanca;
        break;
      case VaccineStatusType.upcoming:
        text = DateFormat('d MMM yyyy', 'fr').format(vaccineGroup.expectedDate);
        break;
    }

    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildActionButton(bool isDark, Color primary, Color textColor) {
    if (vaccineGroup.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              'Fait',
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Marquer',
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
