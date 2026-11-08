import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/subscription_models.dart';

/// Clean luxury Squircle Bento matrix comparing Free, Premium, and VIP tiers.
/// Aligned with LM-SUB-002 exact 13-feature matrix and highlighting Premium as 'Recommandée'.
class PlanComparisonTable extends StatelessWidget {
  final SubscriptionTier highlightedTier;

  const PlanComparisonTable({
    super.key,
    this.highlightedTier = SubscriptionTier.premium,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final subTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    // 13 Rows conforming strictly to LM-SUB-002 section 3
    final rows = [
      _MatrixRow(
        title: l10n.subscriptionMatrixPrice,
        freeValue: '0 DA',
        premiumValue: '2 490 DA / an',
        vipValue: '9 890 DA / an',
        isHighlightRow: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixCapsules,
        freeValue: l10n.subscriptionMatrixValueFreeCapsules,
        premiumValue: l10n.subscriptionCompareValueUnlimited,
        vipValue: l10n.subscriptionCompareValueUnlimited,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixChildren,
        freeValue: l10n.subscriptionMatrixValueOneChild,
        premiumValue: l10n.subscriptionMatrixValueTwoChildren,
        vipValue: l10n.subscriptionMatrixValueUnlimitedChildren,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixVaccines,
        freeCheck: true,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixReels,
        freeCheck: true,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixRecording,
        freeCheck: true,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixSharing,
        freeCheck: false,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixPremiumPerks,
        freeCheck: false,
        premiumCheck: true,
        vipCheck: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixVipPerks,
        freeCheck: false,
        premiumCheck: false,
        vipCheck: true,
        isVipExclusive: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixGiveaways,
        freeCheck: false,
        premiumValue: l10n.subscriptionMatrixValueAvailableOffers,
        vipValue: l10n.subscriptionMatrixValueAvailableOffers,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixPrintedPhoto,
        freeCheck: false,
        premiumCheck: false,
        vipValue: l10n.subscriptionMatrixValueOnePhotoA3,
        isVipExclusive: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixVipCard,
        freeCheck: false,
        premiumCheck: false,
        vipCheck: true,
        isVipExclusive: true,
      ),
      _MatrixRow(
        title: l10n.subscriptionMatrixPartnerPrivileges,
        freeCheck: false,
        premiumCheck: false,
        vipValue: l10n.subscriptionMatrixValueAvailableOffers,
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

          // Column Headers (Tiers) with Premium Highlight
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    '',
                    style: AppTypography.fromContext(context, fontSize: 12),
                  ),
                ),
                // Gratuit Header
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.subscriptionPlanFreeTitle,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '0 DA',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Premium Header (Highlighted with Recommandée Badge)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(
                        alpha: isDark ? 0.18 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.coral.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.subscriptionPlanPremiumTitle,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coral,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '2 490 DA/an',
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // VIP Annuel Header (Exclusive Luxury Tier)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFF8F00,
                      ).withValues(alpha: isDark ? 0.14 : 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.diamond_rounded,
                              size: 11,
                              color: Color(0xFFFF8F00),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'VIP',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF8F00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '9 890 DA/an',
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFFB74D)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 13 Matrix Rows
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
                vertical: 9,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        if (row.isVipExclusive)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(end: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFFF8F00),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            row.title,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              fontWeight: row.isHighlightRow
                                  ? FontWeight.w700
                                  : (row.isVipExclusive
                                        ? FontWeight.w600
                                        : FontWeight.w500),
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
                  // Free cell
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
                  // Premium cell (Highlighted with brand tint)
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(
                          alpha: isDark ? 0.08 : 0.04,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: _buildCell(
                          context,
                          row.premiumCheck,
                          row.premiumValue,
                          isDark,
                          AppColors.coral,
                          isPremium: true,
                        ),
                      ),
                    ),
                  ),
                  // VIP cell
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

          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),

          // Mandatory disclaimer notice as per LM-SUB-002 section 3 & 4
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              10,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: subTextColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.subscriptionDisclaimerAvailableOffers,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: subTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    bool isPremium = false,
    bool isVip = false,
  }) {
    if (check != null) {
      if (check) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 13, color: activeColor),
        );
      } else {
        return Icon(
          Icons.remove_rounded,
          size: 15,
          color: isDark ? Colors.white24 : Colors.black26,
        );
      }
    }
    return Text(
      text ?? '',
      style: AppTypography.fromContext(
        context,
        fontSize: 11,
        fontWeight: (isPremium || isVip) ? FontWeight.w700 : FontWeight.w600,
        color: isPremium
            ? AppColors.coral
            : (isVip
                  ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                  : (isDark ? Colors.white70 : Colors.black87)),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
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
  final bool isHighlightRow;

  const _MatrixRow({
    required this.title,
    this.freeCheck,
    this.premiumCheck,
    this.vipCheck,
    this.freeValue,
    this.premiumValue,
    this.vipValue,
    this.isVipExclusive = false,
    this.isHighlightRow = false,
  });
}
