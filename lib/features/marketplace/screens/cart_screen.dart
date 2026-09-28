import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../models/marketplace_order.dart';
import '../providers/order_providers.dart';
import 'checkout_screen.dart';

/// Shopping cart — review lines, adjust quantities, proceed to checkout.
/// Redesigned with the modern Luxury Squircle Bento design system.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final totalItems = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            child: Column(
              children: [
                // ── Integrated Luxury Header ────────────────────────
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.screenPaddingH,
                    12,
                    AppSpacing.screenPaddingH,
                    8,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Cart Icon Squircle
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Item Count Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cartTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              cart.isEmpty
                                  ? (lang == 'ar' ? 'سلة التسوق فارغة' : 'Panier vide')
                                  : (lang == 'ar'
                                      ? '$totalItems منتج في السلة'
                                      : '$totalItems article${totalItems > 1 ? 's' : ''} au panier'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Clear Cart Action
                      if (cart.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _showClearConfirmation(context, ref, l10n, isDark);
                          },
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.cartClear,
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Body / Content ──────────────────────────────────
                Expanded(
                  child: cart.isEmpty
                      ? _buildEmptyCart(context, textColor, secondaryText, isDark)
                      : ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.screenPaddingH,
                            8,
                            AppSpacing.screenPaddingH,
                            140,
                          ),
                          children: [
                            // Algerian Delivery Trust Banner
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2128)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.03,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '🇩🇿',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      lang == 'ar'
                                          ? 'توصيل سريع لكل الولايات • الدفع كاش عند الاستلام'
                                          : 'Livraison 58 Wilayas • Paiement à la réception',
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppColors.onSurfaceLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Items List
                            ...cart.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CartLineCard(
                                    item: item,
                                    isDark: isDark,
                                    textColor: textColor,
                                    secondaryText: secondaryText,
                                  ),
                                )),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2128) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : AppColors.onSurfaceLight.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total Summary Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.labelTotal,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == 'ar'
                                  ? 'شامل الضرائب (بدون التوصيل)'
                                  : 'Hors frais de livraison',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: secondaryText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatDZD(total),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.coral,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Checkout CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            AnalyticsService().logEvent(
                              'checkout_started',
                              parameters: {
                                'item_count': ref.read(cartItemCountProvider),
                                'total_dzd': total,
                              },
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          label: Text(
                            l10n.cartProceedCheckout,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.cartClear,
          style: AppTypography.fromContext(
            dialogCtx,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.onSurfaceLight,
          ),
        ),
        content: Text(
          l10n.cartEmptySubtitle,
          style: AppTypography.fromContext(
            dialogCtx,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.profileCancel,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.onSurfaceLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.cartClear),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(
    BuildContext context,
    Color textColor,
    Color secondaryText,
    bool isDark,
  ) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Luxury Empty Bag Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : AppColors.onSurfaceLight)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: (isDark ? Colors.white : AppColors.onSurfaceLight)
                      .withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 46,
                  color: secondaryText.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.cartEmptyTitle,
              style: AppTypography.fromContext(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.fromContext(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: Text(
                lang == 'ar' ? 'تصفح منتجات المتجر' : 'Explorer la boutique',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDZD(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer DZD';
  }
}

/// Luxury Bento Line Card for an item in the cart.
class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({
    required this.item,
    required this.isDark,
    required this.textColor,
    required this.secondaryText,
  });

  final CartItem item;
  final bool isDark;
  final Color textColor;
  final Color secondaryText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final categoryColor = item.product.category.color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2128) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : AppColors.onSurfaceLight.withValues(alpha: 0.07),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: item.product.safeImageUrl != null &&
                      item.product.safeImageUrl!.isNotEmpty
                  ? Image.network(
                      item.product.safeImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          item.product.icon,
                          size: 26,
                          color: categoryColor,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        item.product.icon,
                        size: 26,
                        color: categoryColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Details: Name, Unit Price, Line Total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.product.category.getLabel(lang),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Product Title
                Text(
                  item.product.displayName(lang),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Line Total
                Text(
                  _formatDZD(item.lineTotalDZD),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Stepper: [-] [qty] [+]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : AppColors.onSurfaceLight.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                _StepperButton(
                  icon: Icons.add_rounded,
                  isDark: isDark,
                  isEnabled: item.quantity < CartItem.maxQuantity,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id,
                          item.quantity + 1,
                        );
                  },
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: item.quantity == 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  isDark: isDark,
                  isDestructive: item.quantity == 1,
                  isEnabled: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDZD(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer DZD';
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.isDark,
    required this.isEnabled,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final bool isDark;
  final bool isEnabled;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDestructive
        ? AppColors.error
        : (isDark ? Colors.white : AppColors.onSurfaceLight);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.02)
                  : Colors.white),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDark || isDestructive
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled
              ? activeColor
              : (isDark ? Colors.white24 : Colors.black26),
        ),
      ),
    );
  }
}
