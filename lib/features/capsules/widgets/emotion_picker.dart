import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/emotion.dart';

/// Grid picker for selecting an emotion.
class EmotionPicker extends StatelessWidget {
  const EmotionPicker({
    super.key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
  });

  final Emotion? selectedEmotion;
  final ValueChanged<Emotion> onEmotionSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mood_rounded, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(
              'Émotion',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: Emotion.values.map((emotion) {
            final isSelected = selectedEmotion == emotion;
            return GestureDetector(
              onTap: () => onEmotionSelected(emotion),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.primaryDark.withValues(alpha: 0.2)
                            : AppColors.primaryLight.withValues(alpha: 0.15))
                      : (isDark
                            ? AppColors.surfaceContainerDark
                            : AppColors.surfaceContainerLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      emotion.icon,
                      size: 20,
                      color: isSelected
                          ? (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                          : textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      emotion.labelFr,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? (isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight)
                            : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Compact emotion picker for filter sheet.
class EmotionFilterChips extends StatelessWidget {
  const EmotionFilterChips({
    super.key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
  });

  final Emotion? selectedEmotion;
  final ValueChanged<Emotion?> onEmotionSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "All" chip
          _buildChip(
            context,
            icon: Icons.auto_awesome_rounded,
            label: 'Tous',
            isSelected: selectedEmotion == null,
            onTap: () => onEmotionSelected(null),
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.xs),
          // Emotion chips
          ...Emotion.values.map(
            (emotion) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _buildChip(
                context,
                icon: emotion.icon,
                label: emotion.labelFr,
                isSelected: selectedEmotion == emotion,
                onTap: () => onEmotionSelected(emotion),
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.15)
              : (isDark
                    ? AppColors.surfaceContainerDark
                    : AppColors.surfaceContainerLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? primary
                  : (isDark ? Colors.white : AppColors.onSurfaceLight),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? primary
                    : (isDark ? Colors.white : AppColors.onSurfaceLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
