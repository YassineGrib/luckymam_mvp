import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/marketplace_product.dart';
import '../providers/marketplace_providers.dart';
import '../providers/order_providers.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'product_detail_screen.dart';

/// Partner marketplace — browsable catalogue of partner products.
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().logEvent('marketplace_opened');
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

    final products = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(selectedProductCategoryProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketplace',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Produits de nos partenaires',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mes commandes',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyOrdersScreen(),
                      ),
                    ),
                    icon: Icon(
                      Icons.receipt_long_rounded,
                      color: secondaryText,
                    ),
                  ),
                  _CartButton(textColor: textColor),
                ],
              ),
            ),

            // ── Category chips ────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                ),
                children: [
                  _CategoryChip(
                    label: 'Tous',
                    emoji: '✨',
                    color: AppColors.magentaPink,
                    isSelected: selectedCategory == null,
                    isDark: isDark,
                    onTap: () => ref
                        .read(selectedProductCategoryProvider.notifier)
                        .state = null,
                  ),
                  ...ProductCategory.values.map(
                    (cat) => _CategoryChip(
                      label: cat.labelFr,
                      emoji: cat.emoji,
                      color: cat.color,
                      isSelected: selectedCategory == cat,
                      isDark: isDark,
                      onTap: () => ref
                          .read(selectedProductCategoryProvider.notifier)
                          .state = cat,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Product grid ──────────────────────────────────────────
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyState(textColor, secondaryText)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPaddingH,
                        AppSpacing.xs,
                        AppSpacing.screenPaddingH,
                        32,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductCard(
                          product: product,
                          isDark: isDark,
                          textColor: textColor,
                          secondaryText: secondaryText,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 60,
            color: secondaryText.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun produit dans cette catégorie',
            style: GoogleFonts.outfit(fontSize: 15, color: secondaryText),
          ),
        ],
      ),
    );
  }
}

/// Cart icon with a live item-count badge.
class _CartButton extends ConsumerWidget {
  const _CartButton({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Mon panier',
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CartScreen())),
          icon: Icon(Icons.shopping_cart_rounded, color: textColor),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.magentaPink,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.onSurfaceLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.textColor,
    required this.secondaryText,
    required this.onTap,
  });

  final MarketplaceProduct product;
  final bool isDark;
  final Color textColor;
  final Color secondaryText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerByIdProvider(product.partnerId));
    final categoryColor = product.category.color;
    final imageUrl = product.safeImageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual — https image when provided, gradient placeholder otherwise
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(categoryColor),
                        )
                      : _placeholder(categoryColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (partner != null)
                    Text(
                      partner.name,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.formattedPrice,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(product.emoji, style: const TextStyle(fontSize: 44)),
      ),
    );
  }
}
