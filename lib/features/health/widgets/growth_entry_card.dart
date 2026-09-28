import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/growth_entry.dart';

String _healthDateLocale(String languageCode) =>
    languageCode == 'fr' ? 'fr_FR' : languageCode;

/// Luxury Squircle Bento Card displaying a single growth measurement entry.
class GrowthEntryCard extends StatelessWidget {
  const GrowthEntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  final GrowthEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E2128) : Colors.white;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final dateLocale = _healthDateLocale(lang);
    final dayStr = DateFormat('dd', dateLocale).format(entry.date);
    final monthStr = DateFormat('MMM yyyy', dateLocale).format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : AppColors.onSurfaceLight.withValues(alpha: 0.07),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date Squircle Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.coral.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayStr,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coral,
                  ),
                ),
                Text(
                  monthStr,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.coral.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Measurements & Notes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Measurement chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (entry.weightKg != null)
                      _SquircleMetricPill(
                        label: l10n.healthWeightValue(
                          entry.weightKg!.toStringAsFixed(1),
                        ),
                        icon: Icons.monitor_weight_outlined,
                        color: AppColors.coral,
                        isDark: isDark,
                      ),
                    if (entry.heightCm != null)
                      _SquircleMetricPill(
                        label: l10n.healthHeightValue(
                          entry.heightCm!.toStringAsFixed(1),
                        ),
                        icon: Icons.height_rounded,
                        color: AppColors.smaltBlue,
                        isDark: isDark,
                      ),
                  ],
                ),

                // Notes if present
                if (entry.notes != null && entry.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 13,
                        color: secondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          entry.notes!.trim(),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Delete Action Squircle
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquircleMetricPill extends StatelessWidget {
  const _SquircleMetricPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.09),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.fromContext(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
