import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/chargily_payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_providers.dart';
import '../subscription_plan_l10n.dart';
import 'album_claim_screen.dart';
import 'chargily_checkout_screen.dart';

/// Streamlined Algerian Checkout Screen for Edahabia / CIB via Chargily Pay.
class PaymentScreen extends ConsumerStatefulWidget {
  final SubscriptionPlan selectedPlan;

  const PaymentScreen({super.key, required this.selectedPlan});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.edahabia;
  bool _isProcessing = false;
  String? _cancellationNotice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final plan = widget.selectedPlan;
    final isVip = plan.tier == SubscriptionTier.vip;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            child: Column(
              children: [
                // ── Top Navigation Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    AppSpacing.sm,
                    AppSpacing.screenPaddingH,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.paymentTitle,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      // Security indicator badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00897B).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: Color(0xFF00897B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '3D Secure',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00897B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isProcessing)
                  const LinearProgressIndicator(
                    color: Color(0xFFFF8F00),
                    minHeight: 2.5,
                  ),

                // ── Main Scrollable Content ─────────────────────────────────────
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPaddingH,
                      AppSpacing.sm,
                      AppSpacing.screenPaddingH,
                      AppSpacing.xxl,
                    ),
                    children: [
                      // Order Summary Bento Card
                      _buildOrderSummaryCard(
                        context,
                        plan,
                        isVip,
                        isDark,
                        textColor,
                        l10n,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Cancellation / Retry Notification (if previously cancelled)
                      if (_cancellationNotice != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFB74D)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFE65100),
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _cancellationNotice!,
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 12.5,
                                    color: const Color(0xFFBF360C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Payment Method Selector
                      Text(
                        l10n.subscriptionPaymentMethodSelect,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMethodCard(
                              method: PaymentMethod.edahabia,
                              title: l10n.paymentMethodEdahabia,
                              subtitle: l10n.subscriptionPaymentEdahabiaDesc,
                              icon: Icons.credit_card_rounded,
                              activeColor: const Color(0xFFD4AF37),
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _buildMethodCard(
                              method: PaymentMethod.cib,
                              title: l10n.paymentMethodCib,
                              subtitle: l10n.subscriptionPaymentCibDesc,
                              icon: Icons.account_balance_rounded,
                              activeColor: const Color(0xFF1E88E5),
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Reassuring Trust & Official Gateway Notice
                      _buildSecurityNotice(
                        context,
                        isDark,
                        surfaceColor,
                        borderColor,
                        textColor,
                        l10n,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Primary CTA: Proceed to Chargily Pay
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _handlePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isVip
                                ? const Color(0xFFFF6F00)
                                : AppColors.coral,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: (isVip
                                    ? const Color(0xFFFF6F00)
                                    : AppColors.coral)
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_outline_rounded, size: 19),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          l10n.subscriptionPaymentPayButton,
                                          style: AppTypography.fromContext(
                                            context,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    BuildContext context,
    SubscriptionPlan plan,
    bool isVip,
    bool isDark,
    Color textColor,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isVip
              ? const Color(0xFFFF8F00).withValues(alpha: 0.6)
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          width: isVip ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isVip ? const Color(0xFFFF8F00) : Colors.black).withValues(
              alpha: isDark ? 0.25 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient Top Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isVip
                  ? const LinearGradient(
                      colors: [Color(0xFFFF8F00), Color(0xFFFF6F00)],
                    )
                  : AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(plan.tier.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.localizedTitle(l10n),
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        plan.localizedSubtitle(l10n),
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.paymentPriceDzd(plan.priceDZD),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Price Details & VIP Perk
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                if (isVip) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00).withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFF8F00).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFFFF8F00),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.subscriptionVipAlbumHighlight,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFFB23B00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.subscriptionPlanBillingPerYear,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      l10n.paymentDurationFullYear,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.paymentShippingAndDelivery,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      l10n.paymentFreeShipping,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
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

  Widget _buildMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedMethod = method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: activeColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.fromContext(
                context,
                fontSize: 11,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNotice(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Color(0xFF00897B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionTrustSecureTitle,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.subscriptionTrustSecureSubtitle,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.7),
                  ).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    final l10n = context.l10n;
    final plan = widget.selectedPlan;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _cancellationNotice = null;
    });

    final result = await ChargilyPaymentService.createCheckout(
      amount: plan.priceDZD,
      userId: uid,
      type: 'subscription',
      planTier: plan.tier.name,
      customerName: FirebaseAuth.instance.currentUser?.displayName,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.success && result.checkoutUrl != null) {
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ChargilyCheckoutScreen(
            checkoutUrl: result.checkoutUrl!,
            checkoutId: result.checkoutId,
            onSuccess: () {
              ref.read(subscriptionActionsProvider.notifier).upgradeTo(
                    plan.tier,
                    successMessage: l10n.subscriptionSnackUpgradeSuccess(
                      plan.localizedTitle(l10n),
                    ),
                  );
            },
          ),
        ),
      );

      if (paid == true) {
        if (!mounted) return;
        _showSuccessCelebration(context, plan, l10n);
      } else {
        setState(() {
          _cancellationNotice = l10n.subscriptionPaymentCancelled;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? l10n.checkoutErrorGeneric),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  void _showSuccessCelebration(
    BuildContext context,
    SubscriptionPlan plan,
    AppLocalizations l10n,
  ) {
    HapticFeedback.heavyImpact();
    final isVip = plan.tier == SubscriptionTier.vip;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: isVip
                      ? const LinearGradient(
                          colors: [Color(0xFFFF8F00), Color(0xFFFF6F00)],
                        )
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isVip ? const Color(0xFFFF8F00) : AppColors.coral)
                          .withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isVip ? Icons.diamond_rounded : Icons.check_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.subscriptionPaymentSuccessModalTitle,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.subscriptionPaymentSuccessModalDesc,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 13.5,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ).copyWith(height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isVip) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext); // Close sheet
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlbumClaimScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.subscriptionPaymentClaimAlbumNow,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext); // Close sheet
                    Navigator.pop(context); // Return to parent screen
                  },
                  child: Text(
                    l10n.subscriptionPaymentLater,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
