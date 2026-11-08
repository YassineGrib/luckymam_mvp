import 'package:flutter/material.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/emotion.dart';

class EmotionPicker extends StatelessWidget {
  const EmotionPicker({
    super.key,
    required this.selectedEmotions,
    required this.onChanged,
  });
  final List<Emotion> selectedEmotions;
  final ValueChanged<List<Emotion>> onChanged;
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final hint = lang == 'ar'
        ? 'اختاري من شعور واحد إلى ثلاثة'
        : lang == 'en'
        ? 'Choose one to three emotions'
        : 'Choisissez une à trois émotions';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(hint, style: theme.textTheme.titleSmall)),
            const SizedBox(width: 12),
            Text(
              '${selectedEmotions.length} / 3',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final height = (52 + MediaQuery.textScalerOf(context).scale(28))
                .clamp(84.0, 180.0);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth >= 600 ? 4 : 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: height,
              ),
              itemCount: Emotion.values.length,
              itemBuilder: (context, index) {
                final emotion = Emotion.values[index];
                final selected = selectedEmotions.contains(emotion);
                final enabled = selected || selectedEmotions.length < 3;
                return Semantics(
                  selected: selected,
                  button: true,
                  enabled: enabled,
                  child: Opacity(
                    opacity: enabled ? 1 : 0.45,
                    child: Material(
                      color: selected
                          ? emotion.color.withValues(alpha: 0.12)
                          : theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: selected
                              ? emotion.color
                              : theme.colorScheme.outlineVariant,
                          width: selected ? 1.8 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: ValueKey('emotion-${emotion.name}'),
                        onTap: !enabled
                            ? null
                            : () {
                                final updated = List<Emotion>.from(
                                  selectedEmotions,
                                );
                                if (selected) {
                                  updated.remove(emotion);
                                } else {
                                  updated.add(emotion);
                                }
                                onChanged(updated);
                              },
                        child: Stack(
                          children: [
                            PositionedDirectional(
                              end: -8,
                              bottom: -12,
                              child: IgnorePointer(
                                child: Icon(
                                  emotion.icon,
                                  size: 64,
                                  color: emotion.color.withValues(alpha: 0.07),
                                ),
                              ),
                            ),
                            if (selected)
                              PositionedDirectional(
                                top: 8,
                                end: 8,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 17,
                                  color: emotion.color,
                                ),
                              ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      emotion.icon,
                                      size: 22,
                                      color: emotion.color,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      emotion.getLabel(lang),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
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
                  ),
                );
              },
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
