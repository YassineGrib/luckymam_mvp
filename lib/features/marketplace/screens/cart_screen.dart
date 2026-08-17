import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/marketplace_order.dart';
import '../providers/order_providers.dart';
import 'checkout_screen.dart';

/// Shopping cart — review lines, adjust quantities, proceed to checkout.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'ar'
              ? 'سلتي'
              : lang == 'en'
                  ? 'My Cart'
                  : 'Mon Panier',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: Text(
                lang == 'ar'
                    ? 'تفريغ'
                    : lang == 'en'
                        ? 'Clear'
                        : 'Vider',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(textColor, secondaryText, lang)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                AppSpacing.sm,
                AppSpacing.screenPaddingH,
                140,
              ),
              itemCount: cart.length,
              separatorBuilder: (ctx, idx) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = cart[index];
                return _CartLineCard(
                  item: item,
                  isDark: isDark,
                  textColor: textColor,
                  secondaryText: secondaryText,
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == 'ar'
                              ? 'المجموع'
                              : lang == 'en'
                                  ? 'Total'
                                  : 'Total',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: secondaryText,
                          ),
                        ),
                        Text(
                          _formatDZD(total),
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.magentaPink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
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
                          ),
                          label: Text(
                            lang == 'ar'
                                ? 'إتمام الطلب'
                                : lang == 'en'
                                    ? 'Proceed to checkout'
                                    : 'Passer la commande',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildEmptyCart(Color textColor, Color secondaryText, String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            lang == 'ar'
                ? 'سلتك فارغة'
                : lang == 'en'
                    ? 'Your cart is empty'
                    : 'Votre panier est vide',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'ar'
                ? 'تصفحي المتجر لاكتشاف\nمنتجات شركائنا الموثوقين'
                : lang == 'en'
                    ? 'Browse the marketplace to discover\nproducts from our partners'
                    : 'Parcourez le marketplace pour découvrir\nles produits de nos partenaires',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 13, color: secondaryText),
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
    final categoryColor = item.product.category.color;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Row(
        children: [
          // Product visual
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                item.product.icon,
                size: 24,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Name + unit price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.formattedPrice,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
          // Quantity stepper
          Row(
            children: [
              _QtyButton(
                icon: Icons.remove_rounded,
                isDark: isDark,
                onTap: () => ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.product.id, item.quantity - 1),
              ),
              SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              _QtyButton(
                icon: Icons.add_rounded,
                isDark: isDark,
                onTap: () => ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.product.id, item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.magentaPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.magentaPink),
      ),
    );
  }
}
