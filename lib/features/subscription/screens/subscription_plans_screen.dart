import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../subscription_plan_l10n.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_providers.dart';
import '../widgets/plan_card.dart';
import 'payment_screen.dart';

/// Plan comparison screen showing all subscription tiers.
class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final subTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final currentTier = ref.watch(currentTierValueProvider);
    final plans = ref.watch(subscriptionPlansProvider);
    final actionsState = ref.watch(subscriptionActionsProvider);

    // Snackbar on success/error
    ref.listen<SubscriptionActionsState>(subscriptionActionsProvider, (
      _,
      next,
    ) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(subscriptionActionsProvider.notifier).clearMessages();
      }
      if (next.errorDetails != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionSnackError(next.errorDetails!)),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(subscriptionActionsProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.subscriptionPlansTitle,
                          style: AppTypography.fromContext(context, 
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          l10n.subscriptionPlansSubtitle,
                          style: AppTypography.fromContext(context, 
                            fontSize: 13,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator
            if (actionsState.isLoading) const LinearProgressIndicator(),

            // Plans list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return PlanCard(
                    plan: plan,
                    isCurrent: plan.tier == currentTier,
                    onSelect: plan.tier == currentTier
                        ? null
                        : () => _onPlanSelected(context, ref, plan),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlanSelected(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) {
    if (plan.tier == SubscriptionTier.free) {
      final l10n = context.l10n;
      ref.read(subscriptionActionsProvider.notifier).upgradeTo(
            SubscriptionTier.free,
            successMessage: l10n.subscriptionSnackUpgradeSuccess(
              SubscriptionTier.free.localizedLabel(l10n),
            ),
          );
    } else {
      // Navigate to payment screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaymentScreen(selectedPlan: plan)),
      );
    }
  }
}
