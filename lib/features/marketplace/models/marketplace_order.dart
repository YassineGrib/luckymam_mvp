import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'marketplace_product.dart';

/// Lifecycle of a marketplace order. The client only ever creates orders
/// in [pending]; later transitions are made by the fulfillment back-office.
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String label(AppLocalizations l10n) {
    switch (this) {
      case OrderStatus.pending:
        return l10n.orderStatusPending;
      case OrderStatus.confirmed:
        return l10n.orderStatusConfirmed;
      case OrderStatus.shipped:
        return l10n.orderStatusShipped;
      case OrderStatus.delivered:
        return l10n.orderStatusDelivered;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.thumb_up_alt_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.casablanca;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.shipped:
        return AppColors.smaltBlue;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  static OrderStatus fromString(String? value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// A product line in the cart / an order.
class CartItem {
  final MarketplaceProduct product;
  final int quantity;

  /// Basic anti-abuse cap on a single line's quantity.
  static const int maxQuantity = 10;

  const CartItem({required this.product, this.quantity = 1});

  int get lineTotalDZD => product.priceDZD * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toFirestore({required String locale}) => {
    'productId': product.id,
    'productName': product.displayName(locale),
    'partnerId': product.partnerId,
    'unitPriceDZD': product.priceDZD,
    'quantity': quantity,
    'lineTotalDZD': lineTotalDZD,
  };

  /// Admin back-office order line shape (`marketplace_orders.items`).
  Map<String, dynamic> toAdminItem({
    required String vendorLabel,
    required String locale,
  }) => {
    'sku': product.effectiveSku,
    'title': product.displayName(locale),
    'qty': quantity,
    'unitPrice': product.priceDZD,
    'imageUrl': product.safeImageUrl ?? '',
    'image': product.emoji ?? '📦',
    'vendor': vendorLabel,
  };
}

/// A placed marketplace order — immutable client-side once created
/// (audit trail); the back-office drives status changes.
class MarketplaceOrder {
  final String id;
  final String userId;
  final List<OrderLine> lines;
  final int totalDZD;
  final String fullName;
  final String phone;
  final String wilaya;
  final String address;
  final OrderStatus status;
  final DateTime createdAt;

  const MarketplaceOrder({
    required this.id,
    required this.userId,
    required this.lines,
    required this.totalDZD,
    required this.fullName,
    required this.phone,
    required this.wilaya,
    required this.address,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  factory MarketplaceOrder.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final customer = data['customer'] as Map<String, dynamic>?;
    final itemsRaw = data['items'] as List<dynamic>?;
    final linesRaw = data['lines'] as List<dynamic>?;

    List<OrderLine> lines;
    if (itemsRaw != null && itemsRaw.isNotEmpty) {
      lines = itemsRaw
          .map((item) => OrderLine.fromAdminItem(item as Map<String, dynamic>))
          .toList();
    } else {
      lines = (linesRaw ?? [])
          .map((l) => OrderLine.fromMap(l as Map<String, dynamic>))
          .toList();
    }

    final subtotal = _readInt(data['subtotal']);
    final shipping = _readInt(data['shipping']);
    final totalFromFields = subtotal + shipping;
    final totalDZD = _readInt(data['totalDZD'] ?? data['total']) != 0
        ? _readInt(data['totalDZD'] ?? data['total'])
        : (totalFromFields != 0 ? totalFromFields : lines.fold(0, (a, l) => a + l.lineTotalDZD));

    return MarketplaceOrder(
      id: id,
      userId: data['userId'] ?? '',
      lines: lines,
      totalDZD: totalDZD,
      fullName: customer?['name'] ?? data['fullName'] ?? '',
      phone: customer?['phone'] ?? data['phone'] ?? '',
      wilaya: customer?['wilaya'] ?? data['wilaya'] ?? '',
      address: customer?['address'] ?? data['address'] ?? '',
      status: OrderStatus.fromString(data['status'] as String?),
      createdAt:
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static int _readInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  /// Formatted total, e.g. "12 550 DZD".
  String get formattedTotal {
    final digits = totalDZD.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer DZD';
  }
}

/// A denormalized order line as stored in Firestore — keeps the order
/// readable in history even if the catalogue changes later.
class OrderLine {
  final String productId;
  final String sku;
  final String productName;
  final String partnerId;
  final int unitPriceDZD;
  final int quantity;
  final int lineTotalDZD;

  const OrderLine({
    required this.productId,
    this.sku = '',
    required this.productName,
    required this.partnerId,
    required this.unitPriceDZD,
    required this.quantity,
    required this.lineTotalDZD,
  });

  /// Resolves the line title for the active locale — re-localizes from the
  /// live catalogue when possible (orders may store Arabic titles from admin).
  String displayName(String locale, List<MarketplaceProduct> catalog) {
    for (final product in catalog) {
      final matchesSku =
          sku.isNotEmpty && product.effectiveSku == sku;
      final matchesId = productId.isNotEmpty && product.id == productId;
      if (matchesSku || matchesId) {
        return product.displayName(locale);
      }
    }
    return productName;
  }

  factory OrderLine.fromMap(Map<String, dynamic> map) => OrderLine(
    productId: map['productId'] ?? '',
    sku: map['sku']?.toString() ?? '',
    productName: map['productName'] ?? '',
    partnerId: map['partnerId'] ?? '',
    unitPriceDZD: map['unitPriceDZD'] ?? 0,
    quantity: map['quantity'] ?? 0,
    lineTotalDZD: map['lineTotalDZD'] ?? 0,
  );

  factory OrderLine.fromAdminItem(Map<String, dynamic> map) {
    final qty = map['qty'] ?? map['quantity'] ?? 0;
    final unit = map['unitPrice'] ?? map['unitPriceDZD'] ?? 0;
    final quantity = qty is num ? qty.toInt() : int.tryParse('$qty') ?? 0;
    final unitPrice = unit is num ? unit.toInt() : int.tryParse('$unit') ?? 0;
    final sku = map['sku']?.toString() ?? '';
    return OrderLine(
      productId: map['productId']?.toString() ?? sku,
      sku: sku,
      productName: map['title'] ?? map['productName'] ?? '',
      partnerId: map['partnerId']?.toString() ?? '',
      unitPriceDZD: unitPrice,
      quantity: quantity,
      lineTotalDZD: unitPrice * quantity,
    );
  }
}
