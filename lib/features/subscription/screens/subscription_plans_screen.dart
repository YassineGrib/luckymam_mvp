import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_providers.dart';
import '../subscription_plan_l10n.dart';
import '../widgets/plan_comparison_table.dart';
import '../widgets/subscription_faq_section.dart';
import 'payment_screen.dart';

/// High-Converting Collapsed Subscription Paywall Screen (Reference UX).
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  // Default to VIP plan as recommended in modern mobile paywalls
  SubscriptionTier _selectedTier = SubscriptionTier.vip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTier = ref.watch(currentTierValueProvider);
    final plans = ref.watch(subscriptionPlansProvider);
    final actionsState = ref.watch(subscriptionActionsProvider);

    final selectedPlan = plans.firstWhere(
      (p) => p.tier == _selectedTier,
      orElse: () => plans.last,
    );

    // Snackbar on success/error
    ref.listen<SubscriptionActionsState>(subscriptionActionsProvider, (
      _,
      next,
    ) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(next.successMessage!)),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        ref.read(subscriptionActionsProvider.notifier).clearMessages();
      }
      if (next.errorDetails != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.subscriptionSnackError(next.errorDetails!)),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        ref.read(subscriptionActionsProvider.notifier).clearMessages();
      }
    });

    final heroBg = isDark
        ? const Color(0xFF2C1924)
        : const Color(0xFFFCE4EC); // Soft pink tone from reference
    final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: heroBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 1. Top Hero Section with Benefits (Pink background) ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white12 : Colors.white)
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.diamond_rounded,
                              size: 14,
                              color: Color(0xFFFF6F00),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.subscriptionHeroBadgeTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Headline
                  Text(
                    l10n.subscriptionHeroHeadline,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3 Key Benefits
                  _buildBenefitRow(
                    context,
                    Icons.bolt_rounded,
                    l10n.subscriptionHeroBenefit1,
                    textColor,
                  ),
                  const SizedBox(height: 7),
                  _buildBenefitRow(
                    context,
                    Icons.diamond_rounded,
                    l10n.subscriptionHeroBenefit2,
                    textColor,
                  ),
                  const SizedBox(height: 7),
                  _buildBenefitRow(
                    context,
                    Icons.shield_rounded,
                    l10n.subscriptionHeroBenefit3,
                    textColor,
                  ),
                ],
              ),
            ),

            if (actionsState.isLoading)
              const LinearProgressIndicator(
                color: Color(0xFFFF6F00),
                minHeight: 2.5,
              ),

            // ── 2. Collapsed Selectable Cards Sheet (White/Dark rounded) ────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.06,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
                  children: [
                    // Plans (VIP, Premium, Free)
                    ...plans.reversed.map((plan) {
                      return _buildCollapsedPlanCard(
                        context: context,
                        plan: plan,
                        isSelected: plan.tier == _selectedTier,
                        isCurrent: plan.tier == currentTier,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        l10n: l10n,
                      );
                    }),

                    const SizedBox(height: 10),

                    // Feature comparison link
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showComparisonModal(context, l10n),
                        icon: const Icon(
                          Icons.compare_arrows_rounded,
                          size: 18,
                          color: Color(0xFFFF6F00),
                        ),
                        label: Text(
                          l10n.subscriptionViewDetails,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFFB74D)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 3. Bottom Action Button (Like 'Book with Apple Pay') ─
                    _buildMainActionButton(
                      context: context,
                      selectedPlan: selectedPlan,
                      isCurrent: selectedPlan.tier == currentTier,
                      isDark: isDark,
                      l10n: l10n,
                    ),

                    const SizedBox(height: 12),

                    // Legal Footnote
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        l10n.subscriptionLegalNotice,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          color: subTextColor,
                        ).copyWith(height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(
    BuildContext context,
    IconData icon,
    String text,
    Color textColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFF6F00)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.fromContext(
              context,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedPlanCard({
    required BuildContext context,
    required SubscriptionPlan plan,
    required bool isSelected,
    required bool isCurrent,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required dynamic l10n,
  }) {
    final isVip = plan.tier == SubscriptionTier.vip;
    final isPremium = plan.tier == SubscriptionTier.premium;
    final String perMonthText = plan.priceDZD > 0
        ? l10n.subscriptionPlanPricePerMonth((plan.priceDZD / 12).round())
        : '';

    final cardBg = isDark
        ? (isSelected ? const Color(0xFF2A2128) : AppColors.surfaceDark)
        : (isSelected ? const Color(0xFFFFF9FA) : Colors.white);

    final borderColor = isSelected
        ? (isVip ? const Color(0xFFFF8F00) : const Color(0xFFE85A71))
        : (isDark ? AppColors.dividerDark : const Color(0xFFE5E7EB));

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTier = plan.tier);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.2 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? (isVip
                              ? const Color(0xFFFF8F00)
                              : const Color(0xFFE85A71))
                          .withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left details: Title, Price, Subtitle
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
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? Colors.white
                                        : Colors.black)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.subscriptionPlanCurrentBadge,
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: subTextColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            plan.localizedPriceLabel(l10n),
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: isVip
                                  ? (isDark
                                      ? const Color(0xFFFFB74D)
                                      : const Color(0xFFE65100))
                                  : (isPremium
                                      ? AppColors.coral
                                      : textColor),
                            ),
                          ),
                          if (plan.localizedBillingCycle(l10n).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              child: Text(
                                plan.localizedBillingCycle(l10n),
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isVip
                            ? l10n.subscriptionVipCardSubtitle
                            : plan.localizedSubtitle(l10n),
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11.5,
                          fontWeight: isVip ? FontWeight.w600 : FontWeight.normal,
                          color: isVip
                              ? (isDark
                                  ? const Color(0xFFFFB74D)
                                  : const Color(0xFFB23B00))
                              : subTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Right details: Per-month breakdown & Checkbox indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Radio Selection Indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF111827))
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF111827))
                              : subTextColor.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: isDark ? Colors.black : Colors.white,
                            )
                          : null,
                    ),
                    if (perMonthText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        perMonthText,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Floating Top Badge for VIP (supports RTL/LTR with PositionedDirectional)
          if (isVip)
            PositionedDirectional(
              top: -9,
              end: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6F00).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      l10n.subscriptionVipBadge,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton({
    required BuildContext context,
    required SubscriptionPlan selectedPlan,
    required bool isCurrent,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    if (isCurrent) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? Colors.white24 : AppColors.dividerLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            l10n.subscriptionPlanCurrentButton,
            style: AppTypography.fromContext(
              context,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
      );
    }

    final buttonLabel = selectedPlan.priceDZD == 0
        ? l10n.subscriptionPlanSelect
        : l10n.subscriptionContinueButton(selectedPlan.priceDZD);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _onContinueSelectedPlan(context, selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : const Color(0xFF111827),
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedPlan.tier == SubscriptionTier.vip
                  ? Icons.diamond_rounded
                  : Icons.bolt_rounded,
              size: 20,
              color: const Color(0xFFFF6F00),
            ),
            const SizedBox(width: 8),
            Text(
              buttonLabel,
              style: AppTypography.fromContext(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinueSelectedPlan(
    BuildContext context,
    SubscriptionPlan plan,
  ) {
    HapticFeedback.selectionClick();
    if (plan.tier == SubscriptionTier.free) {
      final l10n = context.l10n;
      ref.read(subscriptionActionsProvider.notifier).upgradeTo(
            SubscriptionTier.free,
            successMessage: l10n.subscriptionSnackUpgradeSuccess(
              SubscriptionTier.free.localizedLabel(l10n),
            ),
          );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaymentScreen(selectedPlan: plan)),
      );
    }
  }

  void _showComparisonModal(BuildContext context, dynamic l10n) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                  children: const [
                    PlanComparisonTable(),
                    SizedBox(height: 16),
                    SubscriptionFaqSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

