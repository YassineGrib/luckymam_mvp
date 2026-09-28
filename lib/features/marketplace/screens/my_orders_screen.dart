import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../models/marketplace_order.dart';
import '../providers/marketplace_providers.dart';
import '../providers/order_providers.dart';

/// Order history — every marketplace order with its live status and item details.
/// Redesigned with the modern Luxury Squircle Bento design system.
class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

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

    final ordersAsync = ref.watch(myOrdersProvider);

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

                      // Orders Icon Squircle
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
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.myOrdersTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              lang == 'ar'
                                  ? 'تتبع حالة طلباتك ومواعيد التوصيل'
                                  : 'Suivi et historique de vos commandes',
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
                    ],
                  ),
                ),

                // ── Orders Content ──────────────────────────────────
                Expanded(
                  child: ordersAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.coral),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.myOrdersLoadError,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (orders) {
                      if (orders.isEmpty) {
                        return _buildEmptyOrders(
                          context,
                          textColor,
                          secondaryText,
                          isDark,
                          lang,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.screenPaddingH,
                          10,
                          AppSpacing.screenPaddingH,
                          40,
                        ),
                        itemCount: orders.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) => _OrderCard(
                          order: orders[index],
                          isDark: isDark,
                          textColor: textColor,
                          secondaryText: secondaryText,
                          lang: lang,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders(
    BuildContext context,
    Color textColor,
    Color secondaryText,
    bool isDark,
    String lang,
  ) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  Icons.receipt_long_outlined,
                  size: 46,
                  color: secondaryText.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.myOrdersEmptyTitle,
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
              l10n.myOrdersEmptySubtitle,
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
                lang == 'ar' ? 'تصفح المتجر الآن' : 'Explorer le magasin',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
}

/// Luxury Squircle Bento Card displaying an individual order in history.
class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.textColor,
    required this.secondaryText,
    required this.lang,
  });

  final MarketplaceOrder order;
  final bool isDark;
  final Color textColor;
  final Color secondaryText;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(marketplaceProductsProvider);
    final status = order.status;
    final dateLabel = DateFormat(
      'd MMM yyyy · HH:mm',
      lang == 'ar' ? 'ar' : (lang == 'en' ? 'en' : 'fr'),
    ).format(order.createdAt);

    final shortId = order.id.length > 8
        ? order.id.substring(order.id.length - 8).toUpperCase()
        : order.id.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2128) : Colors.white,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row: Order ID + Status Chip ──────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Number Chip
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : AppColors.onSurfaceLight)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$shortId',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateLabel,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: status.color.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, size: 13, color: status.color),
                    const SizedBox(width: 4),
                    Text(
                      status.label(l10n),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Items Preview ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : AppColors.onSurfaceLight.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                ...order.lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${line.displayName(lang, catalog)} ×${line.quantity}',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDZD(line.lineTotalDZD),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Delivery Wilaya & Address Snippet
          if (order.wilaya.isNotEmpty || order.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      if (order.wilaya.isNotEmpty) order.wilaya,
                      if (order.address.isNotEmpty) order.address,
                    ].join(' · '),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 20),

          // ── Footer: Total & Item Count ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lang == 'ar' ? 'الدفع عند الاستلام' : 'Paiement COD',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.orderItemCount(order.itemCount),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
              Text(
                order.formattedTotal,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.coral,
                ),
              ),
            ],
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
