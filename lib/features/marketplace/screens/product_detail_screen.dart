import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
  late final ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    AnalyticsService().logEvent(
      'product_viewed',
      parameters: {
        'product_id': widget.product.id,
        'partner_id': widget.product.partnerId,
        'category': widget.product.category.name,
      },
    );
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 170;
    if (show != _showTitle) {
      setState(() => _showTitle = show);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final product = widget.product;
    final categoryColor = product.category.color;
    final partner = ref.watch(partnerByIdProvider(product.partnerId));
    final vendorLabel = ref.watch(productVendorLabelProvider(product));
    final cartCount = ref.watch(cartItemCountProvider);
    final imageUrl = product.safeImageUrl;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header with Glassmorphic Floating Buttons ─────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _showTitle
                ? (isDark ? const Color(0xFF1E2128) : Colors.white)
                : (isDark ? const Color(0xFF1E1A24) : categoryColor),
            elevation: _showTitle ? 2 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            centerTitle: true,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showTitle ? 1.0 : 0.0,
              child: Text(
                product.displayName(lang),
                style: AppTypography.fromContext(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _showTitle
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04))
                          : Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showTitle
                            ? (isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.06))
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _showTitle ? textColor : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _showTitle
                            ? (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04))
                            : Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showTitle
                              ? (isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.06))
                              : Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: _showTitle ? textColor : Colors.white,
                            size: 19,
                          ),
                          if (cartCount > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  '$cartCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _heroPlaceholder(categoryColor, product.icon),
                        )
                      : _heroPlaceholder(categoryColor, product.icon),
                  // Bottom gradient overlay for smooth transition
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge + In-stock indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.25),
                            width: 1,
                          ),
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
                              product.category.getLabel(lang),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stock status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.isInStock
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: product.isInStock
                                    ? const Color(0xFF10B981)
                                    : AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              product.isInStock
                                  ? (lang == 'ar' ? 'متوفر بالمخزون' : 'En stock')
                                  : l10n.productOutOfStock,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: product.isInStock
                                    ? const Color(0xFF059669)
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Title
                  Text(
                    product.displayName(lang),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price Tag
                  Text(
                    product.formattedPrice,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFFFB7185) : AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Delivery, COD & Trust Bento Card ───────────────────
                  _buildTrustCard(context, isDark, lang),
                  const SizedBox(height: 18),

                  // Description
                  Text(
                    lang == 'ar' ? 'الوصف' : 'Description',
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.displayDescription(lang),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 14,
                      color: secondaryText,
                      height: 1.55,
                    ),
                  ),

                  // Highlights / Key Features
                  if (product.displayHighlights(lang).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.productHighlights,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...product.displayHighlights(lang).map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF221F28)
                                : const Color(0xFFF7F5FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFEBE6F2),
                            ),
                          ),
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
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 13,
                                    color: textColor,
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Partner / Vendor Card
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF221F28) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.25),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              partner?.icon ?? product.category.icon,
                              size: 24,
                              color: partner?.color ?? categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    vendorLabel,
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                partner?.tagline ?? l10n.productPartnerDefault,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.productPartnerBadge,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── CTA « Commander » Floating Bottom Bar ───────────────────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1A24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Price display
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'السعر الإجمالي' : 'Prix total',
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    product.formattedPrice,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Action button
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: product.isInStock ? AppColors.primaryGradient : null,
                    color: product.isInStock ? null : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: product.isInStock
                        ? [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: product.isInStock ? () => _onCommander(context) : null,
                    icon: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      product.isInStock
                          ? l10n.productOrder
                          : l10n.productOutOfStock,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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

  Widget _buildTrustCard(BuildContext context, bool isDark, String lang) {
    final isAr = lang == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221F28) : const Color(0xFFFAF8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFEDE8F2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _trustItem(
            icon: Icons.local_shipping_outlined,
            title: isAr ? '58 ولاية' : '58 Wilayas',
            subtitle: isAr ? 'توصيل سريع' : 'Livraison express',
            color: const Color(0xFFE11D48),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 28,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          _trustItem(
            icon: Icons.payments_outlined,
            title: isAr ? 'دفع بالاستلام' : 'Cash on delivery',
            subtitle: isAr ? 'يداً بيد' : 'Paiement sécurisé',
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 28,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          _trustItem(
            icon: Icons.verified_user_outlined,
            title: isAr ? 'معتمد 100%' : '100% Certifié',
            subtitle: isAr ? 'جودة أصلية' : 'Authentique',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _trustItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9.5,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _heroPlaceholder(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 72,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  /// Opens the add-to-cart sheet: quantity picker + running total, then
  /// adds the line to the session cart.
  void _onCommander(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final product = widget.product;
    if (!product.isInStock) return;

    final categoryColor = product.category.color;
    var quantity = 1;
    final maxQty = product.maxOrderQuantity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF221F28) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFECE7F2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product recap
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        product.icon,
                        size: 26,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.displayName(lang),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.formattedPrice,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Quantity picker & subtotal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F5FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.productQuantity,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                    Row(
                      children: [
                        _SheetQtyButton(
                          icon: Icons.remove_rounded,
                          enabled: quantity > 1,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() => quantity--);
                          },
                        ),
                        SizedBox(
                          width: 44,
                          child: Center(
                            child: Text(
                              '$quantity',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        _SheetQtyButton(
                          icon: Icons.add_rounded,
                          enabled: quantity < maxQty,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() => quantity++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Add to cart CTA
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final added = ref
                          .read(cartProvider.notifier)
                          .add(product, quantity: quantity);
                      Navigator.pop(ctx);
                      HapticFeedback.mediumImpact();
                      if (!added) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.productMaxQtyReached),
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
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.productAddedToCart(
                                    product.displayName(lang),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          action: SnackBarAction(
                            label: l10n.productViewCart,
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
                      size: 20,
                    ),
                    label: Text(
                      l10n.productAddToCart,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(
            alpha: enabled ? 0.12 : 0.05,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.primaryLight
              : AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

