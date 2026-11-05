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

/// High-Converting Subscription Paywall Screen emphasizing Premium as 'Recommandée' (LM-SUB-001/002).
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  final SubscriptionTier initialSelectedTier;

  const SubscriptionPlansScreen({
    super.key,
    this.initialSelectedTier = SubscriptionTier.premium,
  });

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  late SubscriptionTier _selectedTier;

  @override
  void initState() {
    super.initState();
    _selectedTier = widget.initialSelectedTier;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTier = ref.watch(currentTierValueProvider);
    final plans = ref.watch(subscriptionPlansProvider);
    final actionsState = ref.watch(subscriptionActionsProvider);

    final selectedPlan = plans.firstWhere(
      (p) => p.tier == _selectedTier,
      orElse: () => plans.firstWhere(
        (p) => p.tier == SubscriptionTier.premium,
        orElse: () => plans.first,
      ),
    );

    // Order plans with Premium first (LM-SUB-001: Mise en avant de Premium), then VIP, then Free
    final orderedPlans = <SubscriptionPlan>[];
    final premiumPlan = plans.where((p) => p.tier == SubscriptionTier.premium).firstOrNull;
    final vipPlan = plans.where((p) => p.tier == SubscriptionTier.vip).firstOrNull;
    final freePlan = plans.where((p) => p.tier == SubscriptionTier.free).firstOrNull;

    if (premiumPlan != null) orderedPlans.add(premiumPlan);
    if (vipPlan != null) orderedPlans.add(vipPlan);
    if (freePlan != null) orderedPlans.add(freePlan);

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
        : const Color(0xFFFCE4EC); // Soft pink brand tone
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
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.coral,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'LuckyMam Premium',
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

                  // Headline: "Choisissez la formule qui vous accompagne" (LM-SUB-002 s.6.1)
                  Text(
                    l10n.subscriptionPlansHeaderTitle,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.subscriptionPlansHeaderSubtitle,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12.5,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3 Key Benefits
                  _buildBenefitRow(
                    context,
                    Icons.all_inclusive_rounded,
                    l10n.subscriptionPlanPremiumFeatureUnlimitedCapsules,
                    textColor,
                  ),
                  const SizedBox(height: 7),
                  _buildBenefitRow(
                    context,
                    Icons.share_rounded,
                    l10n.subscriptionMatrixSharing,
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
                color: AppColors.coral,
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
                    // Ordered Plans (Premium first, then VIP, then Free)
                    ...orderedPlans.map((plan) {
                      return _buildCollapsedPlanCard(
                        context: context,
                        plan: plan,
                        isSelected: plan.tier == _selectedTier,
                        isCurrent: plan.tier == currentTier,
                        currentTier: currentTier,
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
                          color: AppColors.coral,
                        ),
                        label: Text(
                          l10n.subscriptionCompareOffers,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.coral,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 3. Bottom Action Button ─────────────────────────────
                    _buildMainActionButton(
                      context: context,
                      selectedPlan: selectedPlan,
                      currentTier: currentTier,
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
        Icon(icon, size: 18, color: AppColors.coral),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.fromContext(
              context,
              fontSize: 13,
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
    required SubscriptionTier currentTier,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required AppLocalizations l10n,
  }) {
    final isVip = plan.tier == SubscriptionTier.vip;
    final isPremium = plan.tier == SubscriptionTier.premium;
    final String perMonthText = plan.priceDZD > 0
        ? l10n.subscriptionPlanPricePerMonth((plan.priceDZD / 12).round())
        : '';

    final cardBg = isDark
        ? (isSelected
            ? (isPremium
                ? const Color(0xFF2E1C22)
                : const Color(0xFF2A2128))
            : AppColors.surfaceDark)
        : (isSelected
            ? (isPremium
                ? const Color(0xFFFFF6F7)
                : const Color(0xFFFFFBF0))
            : Colors.white);

    final borderColor = isSelected
        ? (isPremium
            ? AppColors.coral
            : (isVip ? const Color(0xFFFF8F00) : const Color(0xFF78909C)))
        : (isDark ? AppColors.dividerDark : const Color(0xFFE5E7EB));

    String cardSubtitle;
    if (isPremium) {
      cardSubtitle = l10n.upgradePremiumSubtitle;
    } else if (isVip) {
      cardSubtitle = l10n.subscriptionVipCardSubtitle;
    } else {
      cardSubtitle = '${l10n.subscriptionMatrixValueFreeCapsules} • ${l10n.subscriptionMatrixValueOneChild}';
    }

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
                      ? (isPremium
                              ? AppColors.coral
                              : (isVip
                                  ? const Color(0xFFFF8F00)
                                  : const Color(0xFF78909C)))
                          .withValues(alpha: 0.16)
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
                              color: isPremium
                                  ? AppColors.coral
                                  : (isVip
                                      ? (isDark
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFFE65100))
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
                        cardSubtitle,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11.5,
                          fontWeight: (isPremium || isVip) ? FontWeight.w600 : FontWeight.normal,
                          color: isPremium
                              ? AppColors.coral
                              : (isVip
                                  ? (isDark
                                      ? const Color(0xFFFFB74D)
                                      : const Color(0xFFB23B00))
                                  : subTextColor),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Right details: Per-month breakdown & Radio selection indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isPremium
                                ? AppColors.coral
                                : (isDark ? Colors.white : const Color(0xFF111827)))
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isPremium
                                  ? AppColors.coral
                                  : (isDark ? Colors.white : const Color(0xFF111827)))
                              : subTextColor.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
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

          // Floating Top Badge for Premium (Recommandée) - LM-SUB-001
          if (isPremium)
            PositionedDirectional(
              top: -9,
              end: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7043), Color(0xFFE85A71)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 13, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      l10n.subscriptionPlanRecommendedBadge,
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
            )
          else if (isVip)
            PositionedDirectional(
              top: -9,
              end: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      l10n.subscriptionVipExclusiveBadge,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 10,
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
    required SubscriptionTier currentTier,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final isCurrent = selectedPlan.tier == currentTier;
    final isDisabled = selectedPlan.isActionDisabled(currentTier: currentTier);

    if (isDisabled || isCurrent) {
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
            selectedPlan.localizedActionButton(currentTier: currentTier, l10n: l10n),
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

    String buttonLabel;
    if (selectedPlan.tier == SubscriptionTier.free) {
      buttonLabel = l10n.subscriptionPlanSelect;
    } else {
      final actionText = selectedPlan.localizedActionButton(currentTier: currentTier, l10n: l10n);
      buttonLabel = '$actionText • ${selectedPlan.formattedPriceWithCycle}';
    }

    final isPremium = selectedPlan.tier == SubscriptionTier.premium;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _onContinueSelectedPlan(context, selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPremium ? AppColors.coral : (isDark ? Colors.white : const Color(0xFF111827)),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: isPremium
              ? AppColors.coral.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPremium
                  ? Icons.star_rounded
                  : (selectedPlan.tier == SubscriptionTier.vip
                      ? Icons.diamond_rounded
                      : Icons.bolt_rounded),
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                buttonLabel,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
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
          height: MediaQuery.of(context).size.height * 0.88,
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
                  children: [
                    PlanComparisonTable(highlightedTier: _selectedTier),
                    const SizedBox(height: 16),
                    const SubscriptionFaqSection(),
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
