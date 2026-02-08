import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/phase.dart';

/// Horizontal carousel for navigating between life phases
class PhaseCarousel extends StatelessWidget {
  final Phase currentPhase;
  final Phase selectedPhase;
  final ValueChanged<Phase> onPhaseSelected;

  const PhaseCarousel({
    super.key,
    required this.currentPhase,
    required this.selectedPhase,
    required this.onPhaseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
        ),
        itemCount: Phase.values.length,
        itemBuilder: (context, index) {
          final phase = Phase.values[index];
          final isSelected = phase == selectedPhase;
          final isCurrent = phase == currentPhase;

          return Padding(
            padding: EdgeInsets.only(
              right: index < Phase.values.length - 1 ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onPhaseSelected(phase),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 140,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? phase.color.withOpacity(isDark ? 0.3 : 0.15)
                      : isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? phase.color
                        : isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: phase.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and current badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          phase.icon,
                          size: 24,
                          color: isSelected ? phase.color : null,
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: phase.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Actuel',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Phase label
                    Text(
                      phase.labelFr,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? phase.color
                            : isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Progress indicator
                    _buildPhaseProgress(phase, isSelected),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseProgress(Phase phase, bool isSelected) {
    // Placeholder progress - in real app, calculate from milestones completed
    final double progress = phase == currentPhase
        ? 0.3
        : phase.index < currentPhase.index
        ? 1.0
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: phase.color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(phase.color),
          ),
        ),
      ],
    );
  }
}
