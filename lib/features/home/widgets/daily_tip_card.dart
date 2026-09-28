import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_providers.dart';

/// Redesigned inspirational daily tip card.
/// Features a boutique squircle container, warm sunshine tint,
/// corner-bleeding lightbulb watermark, and non-italic typography.
class DailyTipCard extends ConsumerWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final bg = isDark ? const Color(0xFF262018) : const Color(0xFFFFFBEB);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFFEF3C7);
    final textColor = isDark ? Colors.white : const Color(0xFF2D2112);
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF786242);
    const accentColor = Color(0xFFD97706);

    final tip = ref.watch(dailyTipProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFFFDE68A).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Bleeding lightbulb watermark in corner
              Positioned(
                bottom: -22,
                right: -18,
                child: IgnorePointer(
                  child: Icon(
                    Icons.lightbulb_rounded,
                    size: 94,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : accentColor.withValues(alpha: 0.09),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Micro-pill Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lightbulb_rounded,
                            size: 13,
                            color: accentColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.dailyTipSectionTitle,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.2,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tip text (Strictly normal font style, no italics)
                    Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.45,
                        fontStyle: FontStyle.normal,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Footer attribution
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.dailyTipFooter,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: secondaryColor,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

