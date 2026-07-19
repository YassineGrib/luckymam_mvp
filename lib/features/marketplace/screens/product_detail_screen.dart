import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/marketplace_order.dart';
import '../models/marketplace_product.dart';
import '../providers/marketplace_providers.dart';
import '../providers/order_providers.dart';
import 'cart_screen.dart';

/// Product detail page with partner info and the « Commander » CTA.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final MarketplaceProduct product;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().logEvent(
      'product_viewed',
      parameters: {
        'product_id': widget.product.id,
        'partner_id': widget.product.partnerId,
        'category': widget.product.category.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final product = widget.product;
    final categoryColor = product.category.color;
    final partner = ref.watch(partnerByIdProvider(product.partnerId));
    final imageUrl = product.safeImageUrl;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: categoryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _heroPlaceholder(categoryColor, product.emoji),
                    )
                  : _heroPlaceholder(categoryColor, product.emoji),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge + price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.category.icon,
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              product.category.labelFr,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        product.formattedPrice,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Name
                  Text(
                    product.name,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    product.description,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: secondaryText,
                      height: 1.55,
                    ),
                  ),

                  // Highlights
                  if (product.highlights.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Points clés',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...product.highlights.map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                point,
                                style: GoogleFonts.outfit(
                                  fontSize: 13.5,
                                  color: textColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Partner card
                  if (partner != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: partner.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: partner.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                partner.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  partner.tagline,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: partner.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Partenaire',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: partner.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── CTA « Commander » ─────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.magentaPink.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _onCommander(context, partner),
              icon: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
              ),
              label: Text(
                'Commander',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroPlaceholder(Color color, String emoji) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 72)),
      ),
    );
  }

  /// Opens the add-to-cart sheet: quantity picker + running total, then
  /// adds the line to the session cart (LM2-139 order flow).
  void _onCommander(BuildContext context, MarketplacePartner? partner) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final product = widget.product;
    final categoryColor = product.category.color;
    var quantity = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product recap
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.formattedPrice,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Quantity picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantité',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),
                  Row(
                    children: [
                      _SheetQtyButton(
                        icon: Icons.remove_rounded,
                        enabled: quantity > 1,
                        onTap: () => setSheetState(() => quantity--),
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      _SheetQtyButton(
                        icon: Icons.add_rounded,
                        enabled: quantity < CartItem.maxQuantity,
                        onTap: () => setSheetState(() => quantity++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Add to cart
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final added = ref
                          .read(cartProvider.notifier)
                          .add(product, quantity: quantity);
                      Navigator.pop(ctx);
                      if (!added) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Quantité maximale atteinte pour ce produit',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.warning,
                          ),
                        );
                        return;
                      }
                      AnalyticsService().logEvent(
                        'product_added_to_cart',
                        parameters: {
                          'product_id': product.id,
                          'quantity': quantity,
                        },
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ajouté au panier ✓'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.success,
                          action: SnackBarAction(
                            label: 'Voir le panier',
                            textColor: Colors.white,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Ajouter au panier',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}

class _SheetQtyButton extends StatelessWidget {
  const _SheetQtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.magentaPink.withValues(
            alpha: enabled ? 0.12 : 0.05,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.magentaPink
              : AppColors.magentaPink.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
