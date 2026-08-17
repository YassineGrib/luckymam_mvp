import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'marketplace_product.dart';

/// Lifecycle of a marketplace order. The client only ever creates orders
/// in [pending]; later transitions are made by the fulfillment back-office.
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String getLabel(String locale) {
    switch (this) {
      case OrderStatus.pending:
        return locale == 'ar'
            ? 'قيد الانتظار'
            : locale == 'en'
                ? 'Pending'
                : 'En attente';
      case OrderStatus.confirmed:
        return locale == 'ar'
            ? 'مؤكدة'
            : locale == 'en'
                ? 'Confirmed'
                : 'Confirmée';
      case OrderStatus.shipped:
        return locale == 'ar'
            ? 'تم الشحن'
            : locale == 'en'
                ? 'Shipped'
                : 'Expédiée';
      case OrderStatus.delivered:
        return locale == 'ar'
            ? 'تم التسليم'
            : locale == 'en'
                ? 'Delivered'
                : 'Livrée';
      case OrderStatus.cancelled:
        return locale == 'ar'
            ? 'ملغاة'
            : locale == 'en'
                ? 'Cancelled'
                : 'Annulée';
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

  Map<String, dynamic> toFirestore() => {
    'productId': product.id,
    'productName': product.name,
    'partnerId': product.partnerId,
    'unitPriceDZD': product.priceDZD,
    'quantity': quantity,
    'lineTotalDZD': lineTotalDZD,
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
    return MarketplaceOrder(
      id: id,
      userId: data['userId'] ?? '',
      lines: (data['lines'] as List<dynamic>? ?? [])
          .map((l) => OrderLine.fromMap(l as Map<String, dynamic>))
          .toList(),
      totalDZD: data['totalDZD'] ?? 0,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      wilaya: data['wilaya'] ?? '',
      address: data['address'] ?? '',
      status: OrderStatus.fromString(data['status'] as String?),
      createdAt:
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
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
  final String productName;
  final String partnerId;
  final int unitPriceDZD;
  final int quantity;
  final int lineTotalDZD;

  const OrderLine({
    required this.productId,
    required this.productName,
    required this.partnerId,
    required this.unitPriceDZD,
    required this.quantity,
    required this.lineTotalDZD,
  });

  factory OrderLine.fromMap(Map<String, dynamic> map) => OrderLine(
    productId: map['productId'] ?? '',
    productName: map['productName'] ?? '',
    partnerId: map['partnerId'] ?? '',
    unitPriceDZD: map['unitPriceDZD'] ?? 0,
    quantity: map['quantity'] ?? 0,
    lineTotalDZD: map['lineTotalDZD'] ?? 0,
  );
}
