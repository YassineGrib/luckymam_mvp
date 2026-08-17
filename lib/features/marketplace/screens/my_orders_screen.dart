import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/marketplace_order.dart';
import '../providers/order_providers.dart';

/// Order history — every marketplace order with its live status.
class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

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

    final ordersAsync = ref.watch(myOrdersProvider);

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
              ? 'طلباتي'
              : lang == 'en'
                  ? 'My Orders'
                  : 'Mes Commandes',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            lang == 'ar'
                ? 'خطأ في التحميل'
                : lang == 'en'
                    ? 'Failed to load'
                    : 'Erreur de chargement',
            style: GoogleFonts.outfit(color: secondaryText),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: secondaryText.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    lang == 'ar'
                        ? 'لا توجد طلبات حالياً'
                        : lang == 'en'
                            ? 'No orders yet'
                            : 'Aucune commande pour le moment',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang == 'ar'
                        ? 'ستظهر طلبات المتجر الخاصة بك هنا'
                        : lang == 'en'
                            ? 'Your marketplace orders will appear here'
                            : 'Vos commandes marketplace apparaîtront ici',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingH,
              AppSpacing.sm,
              AppSpacing.screenPaddingH,
              32,
            ),
            itemCount: orders.length,
            separatorBuilder: (ctx, idx) =>
                const SizedBox(height: AppSpacing.sm),
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
    );
  }
}

class _OrderCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final status = order.status;
    final dateLabel = DateFormat(
      'd MMM yyyy · HH:mm',
      lang == 'ar' ? 'ar' : lang == 'en' ? 'en' : 'fr',
    ).format(order.createdAt);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: date + status chip
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, size: 13, color: status.color),
                    const SizedBox(width: 4),
                    Text(
                      status.getLabel(lang),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Lines
          ...order.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${line.productName} ×${line.quantity}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDZD(line.lineTotalDZD),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang == 'ar'
                    ? '${order.itemCount} منتج'
                    : lang == 'en'
                        ? '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}'
                        : '${order.itemCount} article${order.itemCount > 1 ? 's' : ''}',
                style: GoogleFonts.outfit(fontSize: 12, color: secondaryText),
              ),
              Text(
                order.formattedTotal,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.magentaPink,
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
