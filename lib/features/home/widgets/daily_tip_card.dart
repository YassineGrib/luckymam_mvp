import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_providers.dart';

/// Inspirational daily tip card.
class DailyTipCard extends ConsumerWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final tip = ref.watch(dailyTipProvider);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: secondaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                context.l10n.dailyTipSectionTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.2,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tip card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.surfaceDark, AppColors.surfaceContainerDark]
                    : [
                        AppColors.negroni.withValues(alpha: 0.3),
                        AppColors.willowBrook.withValues(alpha: 0.3),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.goldenrod.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote icon
                Text(
                  '"',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.goldenrod.withValues(alpha: 0.6)
                        : AppColors.goldenrod,
                    height: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Tip text
                Text(
                  tip,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Footer
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      context.l10n.dailyTipFooter,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
