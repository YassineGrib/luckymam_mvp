import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Clean luxury Squircle Bento matrix comparing Free, Premium, and VIP tiers.
class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({super.key});

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

    final rows = [
      _MatrixRow(
        title: l10n.subscriptionCompareFeatureCapsules,
        freeValue: l10n.subscriptionCompareValueFreeCapsules,
        premiumValue: l10n.subscriptionCompareValueUnlimited,
        vipValue: l10n.subscriptionCompareValueUnlimited,
      ),
      _MatrixRow(
        title: l10n.subscriptionCompareFeatureChildren,
        freeValue: l10n.subscriptionCompareValueOneChild,
        premiumValue: l10n.subscriptionCompareValueAllChildren,
        vipValue: l10n.subscriptionCompareValueAllChildren,
      ),
      _MatrixRow(
        title: l10n.subscriptionCompareFeatureHealth,
        freeCheck: true,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionCompareFeatureMemoryBook,
        freeCheck: false,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionCompareFeatureAdFree,
        freeCheck: false,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionCompareFeaturePrintedAlbum,
        freeCheck: false,
        premiumCheck: false,
        vipCheck: true,
        isVipExclusive: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionCompareFeatureSupport,
        freeValue: '—',
        premiumValue: l10n.subscriptionCompareSupportPremium,
        vipValue: l10n.subscriptionCompareSupportVip,
        isVipExclusive: true,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.coral,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.subscriptionCompareTitle,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        l10n.subscriptionCompareSubtitle,
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
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // Column Headers (Tiers)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    '',
                    style: AppTypography.fromContext(context, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      l10n.subscriptionPlanFreeTitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      l10n.subscriptionPlanPremiumTitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE85A71),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8F00), Color(0xFFFF6F00)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'VIP',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Rows
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            final isEven = index.isEven;
            return Container(
              color: isEven
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : const Color(0xFFF9FAFB))
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        if (row.isVipExclusive)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(end: 6),
                            child: Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFF8F00),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            row.title,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12.5,
                              fontWeight: row.isVipExclusive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: row.isVipExclusive
                                  ? (isDark
                                      ? const Color(0xFFFFB74D)
                                      : const Color(0xFFE65100))
                                  : textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _buildCell(
                        context,
                        row.freeCheck,
                        row.freeValue,
                        isDark,
                        subTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _buildCell(
                        context,
                        row.premiumCheck,
                        row.premiumValue,
                        isDark,
                        const Color(0xFFE85A71),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _buildCell(
                        context,
                        row.vipCheck,
                        row.vipValue,
                        isDark,
                        const Color(0xFFFF6F00),
                        isVip: true,
                      ),
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

  Widget _buildCell(
    BuildContext context,
    bool? check,
    String? text,
    bool isDark,
    Color activeColor, {
    bool isVip = false,
  }) {
    if (check != null) {
      if (check) {
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 14, color: activeColor),
        );
      } else {
        return Icon(
          Icons.remove_rounded,
          size: 16,
          color: isDark ? Colors.white24 : Colors.black26,
        );
      }
    }
    return Text(
      text ?? '',
      style: AppTypography.fromContext(
        context,
        fontSize: 11.5,
        fontWeight: isVip ? FontWeight.w700 : FontWeight.w600,
        color: isVip ? activeColor : (isDark ? Colors.white70 : Colors.black87),
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MatrixRow {
  final String title;
  final bool? freeCheck;
  final bool? premiumCheck;
  final bool? vipCheck;
  final String? freeValue;
  final String? premiumValue;
  final String? vipValue;
  final bool isVipExclusive;

  const _MatrixRow({
    required this.title,
    this.freeCheck,
    this.premiumCheck,
    this.vipCheck,
    this.freeValue,
    this.premiumValue,
    this.vipValue,
    this.isVipExclusive = false,
  });
}
