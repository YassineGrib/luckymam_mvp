import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/subscription_models.dart';
import '../subscription_plan_l10n.dart';

/// Reusable Luxury Squircle Bento Plan Card with VIP prominence and haptics.
class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrent;
  final VoidCallback? onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    this.isCurrent = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVip = plan.tier == SubscriptionTier.vip;
    final isPremium = plan.tier == SubscriptionTier.premium;

    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isVip
        ? const Color(0xFFFF8F00)
        : (isCurrent
            ? plan.accentColor
            : (isDark ? AppColors.dividerDark : AppColors.dividerLight));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor.withValues(alpha: isVip ? 0.8 : (isCurrent ? 1.0 : 0.8)),
          width: isVip ? 2.0 : (isCurrent ? 2.0 : 1.0),
        ),
        boxShadow: [
          if (isVip)
            BoxShadow(
              color: const Color(0xFFFF8F00).withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 22,
              offset: const Offset(0, 8),
            )
          else if (isCurrent)
            BoxShadow(
              color: plan.accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge for VIP (Most Popular)
            if (isVip)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF8F00),
                      Color(0xFFFF6F00),
                      Color(0xFFE91E63),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.diamond_rounded, size: 15, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      l10n.subscriptionVipBadge,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // Card Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isVip
                          ? const LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                            )
                          : (isPremium
                              ? AppColors.primaryGradient
                              : LinearGradient(
                                  colors: [
                                    plan.accentColor,
                                    plan.accentColor.withValues(alpha: 0.7),
                                  ],
                                )),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isVip
                                  ? const Color(0xFFFF8F00)
                                  : plan.accentColor)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(plan.tier.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.localizedTitle(l10n),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: plan.accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: plan.accentColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  l10n.subscriptionPlanCurrentBadge,
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: plan.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          plan.localizedSubtitle(l10n),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 12.5,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Price Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    plan.localizedPriceLabel(l10n),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: isVip
                          ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                          : (isPremium ? AppColors.coral : plan.accentColor),
                    ),
                  ),
                  if (plan.localizedBillingCycle(l10n).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        plan.localizedBillingCycle(l10n),
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 13.5,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // VIP Physical Printed Album Highlight Banner
            if (isVip)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8F00).withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFFFF8F00),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.subscriptionVipAlbumHighlight,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFB23B00),
                          ).copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Features List
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Column(
                children: plan.localizedFeatures(l10n).map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: isVip
                                ? const Color(0xFFFF8F00)
                                : (isPremium ? AppColors.coral : plan.accentColor),
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 13.5,
                              color: textColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: isCurrent
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark ? Colors.white24 : AppColors.dividerLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.subscriptionPlanCurrentButton,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: subTextColor,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onSelect?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isVip
                              ? const Color(0xFFFF6F00)
                              : (isPremium ? AppColors.coral : plan.accentColor),
                          foregroundColor: Colors.white,
                          elevation: isVip ? 4 : 0,
                          shadowColor: isVip
                              ? const Color(0xFFFF6F00).withValues(alpha: 0.5)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          plan.priceDZD == 0
                              ? l10n.subscriptionPlanSelect
                              : l10n.subscriptionPlanChoose,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
