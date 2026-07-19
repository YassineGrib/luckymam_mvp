import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../models/marketplace_order.dart';
import '../models/marketplace_product.dart';

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
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final newQty = state[index].quantity + quantity;
      if (newQty > CartItem.maxQuantity) return false;
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
    if (quantity > CartItem.maxQuantity) return false;
    state = [...state, CartItem(product: product, quantity: quantity)];
    return true;
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    if (quantity > CartItem.maxQuantity) return;
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

/// Cart total in DZD.
final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (acc, i) => acc + i.lineTotalDZD);
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
  OrderActionsNotifier() : super(const OrderActionsState());

  DateTime? _lastSubmission;

  /// Creates the order document. Returns the created order id, or null on
  /// failure (state.error is set).
  Future<String?> submitOrder({
    required List<CartItem> items,
    required String fullName,
    required String phone,
    required String wilaya,
    required String address,
  }) async {
    // Basic anti-fraud: block empty carts, over-cap quantities, and
    // rapid duplicate submissions (double-tap / retry spam).
    if (items.isEmpty) {
      state = const OrderActionsState(error: 'Le panier est vide');
      return null;
    }
    if (items.any((i) => i.quantity < 1 || i.quantity > CartItem.maxQuantity)) {
      state = const OrderActionsState(error: 'Quantité invalide');
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

      final total = items.fold(0, (acc, i) => acc + i.lineTotalDZD);
      final doc = await FirebaseFirestore.instance
          .collection('marketplace_orders')
          .add({
            'userId': uid,
            'lines': items.map((i) => i.toFirestore()).toList(),
            'totalDZD': total,
            'fullName': fullName,
            'phone': phone,
            'wilaya': wilaya,
            'address': address,
            'status': OrderStatus.pending.name,
            'createdAt': now.toIso8601String(),
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
}

final orderActionsProvider =
    StateNotifierProvider<OrderActionsNotifier, OrderActionsState>(
      (ref) => OrderActionsNotifier(),
    );
