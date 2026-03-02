import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../../vaccines/providers/vaccine_providers.dart';
import '../../vaccines/screens/vaccine_detail_screen.dart';

/// Card widget displaying a vaccine group with collapsible details.
class VaccineCard extends StatefulWidget {
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
  State<VaccineCard> createState() => _VaccineCardState();
}

class _VaccineCardState extends State<VaccineCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

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
      child: Column(
        children: [
          // Header — always visible, tappable to expand/collapse
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    _buildStatusIcon(isDark, primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vaccineGroup.group.ageFr,
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
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: secondaryText,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Collapsible details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetails(
              isDark,
              textColor,
              secondaryText,
              primary,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    bool isDark,
    Color textColor,
    Color secondaryText,
    Color primary,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Vaccine list
          ...widget.vaccineGroup.group.vaccines.map(
            (vaccine) => Padding(
              padding: const EdgeInsets.only(left: 44, top: AppSpacing.xxs),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.vaccineGroup.isCompleted
                          ? AppColors.success
                          : secondaryText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccine.code,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          vaccine.nameFr,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // En savoir plus link
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VaccineDetailScreen(vaccine: vaccine),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 12,
                            color: primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Détails',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notes if completed
          if (widget.vaccineGroup.status?.notes != null &&
              widget.vaccineGroup.status!.notes!.isNotEmpty) ...[
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
                    Icon(Icons.notes_rounded, size: 14, color: secondaryText),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        widget.vaccineGroup.status!.notes!,
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

          // Mark action button inside details
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: widget.vaccineGroup.isCompleted
                ? OutlinedButton.icon(
                    onPressed: widget.onMarkIncomplete,
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: Text(
                      'Annuler le vaccin',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: widget.onMarkComplete,
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Marquer comme fait',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (widget.vaccineGroup.statusType) {
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

    switch (widget.vaccineGroup.statusType) {
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

    switch (widget.vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        final date = widget.vaccineGroup.status?.completedAt;
        text = date != null
            ? 'Fait le ${DateFormat('d MMM yyyy', 'fr').format(date)}'
            : 'Complété';
        color = AppColors.success;
        break;
      case VaccineStatusType.overdue:
        text = 'En retard de ${-widget.vaccineGroup.daysUntilDue} jours';
        color = AppColors.error;
        break;
      case VaccineStatusType.dueSoon:
        if (widget.vaccineGroup.daysUntilDue == 0) {
          text = 'Prévu aujourd\'hui';
        } else {
          text = 'Dans ${widget.vaccineGroup.daysUntilDue} jours';
        }
        color = AppColors.casablanca;
        break;
      case VaccineStatusType.upcoming:
        text = DateFormat(
          'd MMM yyyy',
          'fr',
        ).format(widget.vaccineGroup.expectedDate);
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
    if (widget.vaccineGroup.isCompleted) {
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
