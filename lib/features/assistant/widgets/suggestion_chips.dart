import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/l10n_extension.dart';

/// Quick suggestion prompt chips shown at the start of a conversation.
class SuggestionChips extends StatelessWidget {
  const SuggestionChips({
    super.key,
    required this.onSuggestionSelected,
  });

  final Function(String) onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final suggestions = [
      (Icons.wb_sunny_rounded, l10n.assistantSuggestionOutingToday),
      (Icons.medical_services_rounded, l10n.assistantSuggestionNextVaccine),
      (Icons.auto_awesome_rounded, l10n.assistantSuggestionGiftIdea),
      (Icons.auto_stories_rounded, l10n.assistantSuggestionMakeAlbum),
    ];

    final chipBg = isDark
        ? const Color(0xFF282332)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.primaryLight.withValues(alpha: 0.25);
    final textColor = isDark ? Colors.white : const Color(0xFF2D2538);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: suggestions.map((item) {
          final icon = item.$1;
          final label = item.$2;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ActionChip(
              avatar: Icon(icon, size: 16, color: AppColors.primaryLight),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              backgroundColor: chipBg,
              side: BorderSide(color: borderColor, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              onPressed: () => onSuggestionSelected(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}
