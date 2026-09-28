import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Expandable FAQ section addressing common subscription & payment concerns.
class SubscriptionFaqSection extends StatelessWidget {
  const SubscriptionFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final faqItems = [
      _FaqItem(
        question: l10n.subscriptionFaqQ1,
        answer: l10n.subscriptionFaqA1,
        icon: Icons.auto_stories_rounded,
      ),
      _FaqItem(
        question: l10n.subscriptionFaqQ2,
        answer: l10n.subscriptionFaqA2,
        icon: Icons.verified_user_rounded,
      ),
      _FaqItem(
        question: l10n.subscriptionFaqQ3,
        answer: l10n.subscriptionFaqA3,
        icon: Icons.upgrade_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.casablanca.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.casablanca,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subscriptionFaqTitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      l10n.subscriptionFaqSubtitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xs),
          ...faqItems.map((item) {
            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  if (expanded) HapticFeedback.selectionClick();
                },
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 16,
                    color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                  ),
                ),
                title: Text(
                  item.question,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                iconColor: const Color(0xFFFF8F00),
                collapsedIconColor: subTextColor,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.answer,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12.5,
                        color: textColor.withValues(alpha: 0.85),
                      ).copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}
