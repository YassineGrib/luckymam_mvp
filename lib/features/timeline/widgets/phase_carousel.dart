import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/phase.dart';

/// Data class holding completion statistics for a life phase.
class PhaseStats {
  final int completed;
  final int total;

  const PhaseStats({
    required this.completed,
    required this.total,
  });

  double get progress =>
      total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
  int get percentage => (progress * 100).toInt();
}

/// Horizontal carousel for navigating between life phases with Home-Bento aesthetics.
/// Displays live milestone completion stats, progress percentages, and current indicators.
class PhaseCarousel extends StatelessWidget {
  final Phase currentPhase;
  final Phase selectedPhase;
  final Map<Phase, PhaseStats>? phaseStats;
  final ValueChanged<Phase> onPhaseSelected;

  const PhaseCarousel({
    super.key,
    required this.currentPhase,
    required this.selectedPhase,
    this.phaseStats,
    required this.onPhaseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
        ),
        itemCount: Phase.values.length,
        itemBuilder: (context, index) {
          final phase = Phase.values[index];
          final isSelected = phase == selectedPhase;
          final isCurrent = phase == currentPhase;
          final stats = phaseStats?[phase] ?? const PhaseStats(completed: 0, total: 0);

          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: index < Phase.values.length - 1 ? 10 : 0,
            ),
            child: _PhaseCardItem(
              phase: phase,
              isSelected: isSelected,
              isCurrent: isCurrent,
              stats: stats,
              onTap: () => onPhaseSelected(phase),
            ),
          );
        },
      ),
    );
  }
}

class _PhaseCardItem extends StatefulWidget {
  final Phase phase;
  final bool isSelected;
  final bool isCurrent;
  final PhaseStats stats;
  final VoidCallback onTap;

  const _PhaseCardItem({
    required this.phase,
    required this.isSelected,
    required this.isCurrent,
    required this.stats,
    required this.onTap,
  });

  @override
  State<_PhaseCardItem> createState() => _PhaseCardItemState();
}

class _PhaseCardItemState extends State<_PhaseCardItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final phase = widget.phase;
    final isSelected = widget.isSelected;
    final isCurrent = widget.isCurrent;
    final stats = widget.stats;

    final double progress = stats.progress;
    final int percentage = stats.percentage;

    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          width: 160,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            phase.color.withValues(alpha: 0.30),
                            phase.color.withValues(alpha: 0.12),
                          ]
                        : [
                            phase.lightColor.withValues(alpha: 0.85),
                            phase.lightColor.withValues(alpha: 0.40),
                          ],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0xFF1E1E26) : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? phase.color.withValues(alpha: 0.50)
                  : (isDark
                      ? AppColors.dividerDark
                      : const Color(0xFFECECEF)),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: phase.color.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Corner watermark icon bleeding subtly into the edge
              PositionedDirectional(
                bottom: -10,
                end: -8,
                child: IgnorePointer(
                  child: Icon(
                    phase.icon,
                    size: 64,
                    color: phase.color.withValues(
                      alpha: isSelected
                          ? (isDark ? 0.22 : 0.14)
                          : (isDark ? 0.08 : 0.035),
                    ),
                  ),
                ),
              ),

              // Content layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: squircle icon badge + optional current pill + percentage badge
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? phase.color.withValues(alpha: 0.22)
                              : (isDark
                                  ? Colors.white10
                                  : phase.color.withValues(alpha: 0.09)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            phase.icon,
                            size: 17,
                            color: isSelected
                                ? (isDark ? Colors.white : phase.color)
                                : (isDark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: phase.color,
                            borderRadius: BorderRadius.circular(6.5),
                          ),
                          child: Text(
                            l10n.timelinePhaseCurrent,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Percentage badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? phase.color.withValues(alpha: 0.22)
                              : (isDark
                                  ? Colors.white10
                                  : phase.color.withValues(alpha: 0.10)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$percentage%',
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? (isDark ? Colors.white : phase.color)
                                : (isDark ? Colors.white70 : phase.color),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle: Phase label + completion text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phase.getLabel(lang),
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected
                              ? (isDark ? Colors.white : phase.color)
                              : (isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 11,
                            color: isSelected
                                ? (isDark ? Colors.white70 : AppColors.success)
                                : AppColors.success,
                          ),
                          const SizedBox(width: 3.5),
                          Expanded(
                            child: Text(
                              lang == 'ar'
                                  ? '${stats.completed} من ${stats.total} مكتمل'
                                  : (lang == 'en'
                                      ? '${stats.completed}/${stats.total} done'
                                      : '${stats.completed}/${stats.total} complétés'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : AppColors.textSecondaryLight)
                                    : secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Progress bar indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: isSelected
                          ? phase.color.withValues(alpha: 0.18)
                          : (isDark
                              ? Colors.white12
                              : const Color(0xFFE5E5EB)),
                      valueColor: AlwaysStoppedAnimation<Color>(phase.color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
