import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../models/marketplace_order.dart';
import '../models/marketplace_product.dart';
import 'marketplace_providers.dart';

/// Flat shipping fee for marketplace orders (DZD), aligned with admin seed data.
const int marketplaceShippingDZD = 500;

// ═══════════════════════════════════════════════════════════════════════════
// CART
// ═══════════════════════════════════════════════════════════════════════════

/// Session cart. In-memory in V1 — cleared on app restart by design
/// (no half-forgotten stale carts, no local storage of pricing data).
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  /// Basic anti-abuse cap on distinct products per order.
  static const int maxDistinctItems = 20;

  /// Adds [quantity] of [product], merging with an existing line.
  /// Returns false when a cap prevents the add.
  bool add(MarketplaceProduct product, {int quantity = 1}) {
    if (!product.isInStock) return false;
    final maxQty = product.maxOrderQuantity;
    if (maxQty <= 0) return false;

    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final newQty = state[index].quantity + quantity;
      if (newQty > maxQty) return false;
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            item.copyWith(quantity: newQty)
          else
            item,
      ];
      return true;
    }
    if (state.length >= maxDistinctItems) return false;
    if (quantity > maxQty) return false;
    state = [...state, CartItem(product: product, quantity: quantity)];
    return true;
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    final item = state.where((i) => i.product.id == productId).firstOrNull;
    if (item == null) return;
    final maxQty = item.product.maxOrderQuantity;
    if (quantity > maxQty) return;
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = const [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

/// Total item count in the cart (for the badge).
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (acc, i) => acc + i.quantity);
});

/// Cart total in DZD (items only).
final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (acc, i) => acc + i.lineTotalDZD);
});

/// Cart total including flat shipping fee.
final cartGrandTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  if (cart.isEmpty) return 0;
  return ref.watch(cartTotalProvider) + marketplaceShippingDZD;
});

// ═══════════════════════════════════════════════════════════════════════════
// ORDERS
// ═══════════════════════════════════════════════════════════════════════════

/// The user's order history, newest first.
final myOrdersProvider = StreamProvider<List<MarketplaceOrder>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('marketplace_orders')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map(
        (snap) =>
            snap.docs
                .map((d) => MarketplaceOrder.fromFirestore(d.data(), d.id))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
});

class OrderActionsState {
  final bool isLoading;
  final String? error;

  const OrderActionsState({this.isLoading = false, this.error});
}

class OrderActionsNotifier extends StateNotifier<OrderActionsState> {
  OrderActionsNotifier(this._ref) : super(const OrderActionsState());

  final Ref _ref;
  DateTime? _lastSubmission;

  /// Creates the order document. Returns the created order id, or null on
  /// failure (state.error is set).
  Future<String?> submitOrder({
    required List<CartItem> items,
    required String fullName,
    required String phone,
    required String wilaya,
    required String address,
    required String locale,
  }) async {
    // Basic anti-fraud: block empty carts, over-cap quantities, and
    // rapid duplicate submissions (double-tap / retry spam).
    if (items.isEmpty) {
      state = const OrderActionsState(error: 'Le panier est vide');
      return null;
    }
    if (items.any((i) => i.quantity < 1 || i.quantity > i.product.maxOrderQuantity)) {
      state = const OrderActionsState(error: 'Quantité invalide');
      return null;
    }
    if (items.any((i) => !i.product.isInStock)) {
      state = const OrderActionsState(error: 'Produit indisponible');
      return null;
    }
    final now = DateTime.now();
    if (_lastSubmission != null &&
        now.difference(_lastSubmission!) < const Duration(seconds: 10)) {
      state = const OrderActionsState(
        error: 'Veuillez patienter avant de renvoyer une commande',
      );
      return null;
    }

    state = const OrderActionsState(isLoading: true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Non connectée');

      final subtotal = items.fold(0, (acc, i) => acc + i.lineTotalDZD);
      final total = subtotal + marketplaceShippingDZD;
      final createdAt = now.toIso8601String();
      final historyAt = createdAt.substring(0, 16).replaceFirst('T', ' ');

      final adminItems = items
          .map(
            (i) => i.toAdminItem(
              vendorLabel: _ref.read(
                productVendorLabelProvider(i.product),
              ),
              locale: locale,
            ),
          )
          .toList();

      final doc = await FirebaseFirestore.instance
          .collection('marketplace_orders')
          .add({
            'userId': uid,
            'customer': {
              'name': fullName,
              'initials': _initialsFromName(fullName),
              'phone': phone,
              'wilaya': wilaya,
              'address': address,
            },
            'items': adminItems,
            'lines': items.map((i) => i.toFirestore(locale: locale)).toList(),
            'subtotal': subtotal,
            'shipping': marketplaceShippingDZD,
            'total': total,
            'totalDZD': total,
            'fullName': fullName,
            'phone': phone,
            'wilaya': wilaya,
            'address': address,
            'payment': {'method': 'cod', 'status': 'pending'},
            'status': OrderStatus.pending.name,
            'createdAt': createdAt,
            'history': [
              {'status': 'pending', 'at': historyAt, 'by': 'التطبيق'},
            ],
          });

      _lastSubmission = now;

      AnalyticsService().logEvent(
        'purchase_completed',
        parameters: {
          'order_id': doc.id,
          'total_dzd': total,
          'item_count': items.fold(0, (acc, i) => acc + i.quantity),
        },
      );

      state = const OrderActionsState();
      return doc.id;
    } catch (e) {
      state = OrderActionsState(error: 'Erreur : $e');
      return null;
    }
  }

  static String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2 ? word.substring(0, 2) : word;
    }
    return '${parts.first[0]}${parts[1][0]}';
  }
}

final orderActionsProvider =
    StateNotifierProvider<OrderActionsNotifier, OrderActionsState>(
      (ref) => OrderActionsNotifier(ref),
    );
