import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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

  Color _getEmotionColor(Emotion emotion) {
    switch (emotion) {
      case Emotion.happy:
        return const Color(0xFFF59E0B);
      case Emotion.love:
        return const Color(0xFFE11D48);
      case Emotion.tender:
        return const Color(0xFFFB923C);
      case Emotion.sad:
        return const Color(0xFF3B82F6);
      case Emotion.surprised:
        return const Color(0xFF06B6D4);
      case Emotion.sleepy:
        return const Color(0xFF8B5CF6);
      case Emotion.proud:
        return const Color(0xFF10B981);
      case Emotion.worried:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mood_rounded, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              l10n.capsuleEmotion,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.capsuleRequired,
              style: AppTypography.fromContext(
                context,
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: Emotion.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final emotion = Emotion.values[index];
            final isSelected = selectedEmotion == emotion;
            final emotionColor = _getEmotionColor(emotion);

            return GestureDetector(
              onTap: () => onEmotionSelected(emotion),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? emotionColor.withValues(alpha: isDark ? 0.22 : 0.12)
                      : (isDark
                            ? const Color(0xFF22202A)
                            : const Color(0xFFF7F5FA)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? emotionColor : (isDark ? Colors.white10 : const Color(0xFFECEAEF)),
                    width: isSelected ? 1.8 : 0.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: emotionColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      emotion.icon,
                      size: 22,
                      color: isSelected ? emotionColor : secondaryText,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emotion.getLabel(lang),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? emotionColor : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context,
            icon: Icons.auto_awesome_rounded,
            label: l10n.marketplaceAllCategories,
            isSelected: selectedEmotion == null,
            onTap: () => onEmotionSelected(null),
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.xs),
          ...Emotion.values.map(
            (emotion) => Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
              child: _buildChip(
                context,
                icon: emotion.icon,
                label: emotion.getLabel(lang),
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
