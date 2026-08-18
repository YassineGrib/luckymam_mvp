// Unit tests over the app's pure logic.
//
// Note: a full-app smoke test (pumping LuckymamApp) requires Firebase to be
// initialized, which is not possible in the plain test environment without
// platform mocks — the splash screen touches Firestore/Auth on first frame.
// These tests cover session-critical pure logic instead.
import 'package:flutter_test/flutter_test.dart';

import 'package:lukymam_mvp/features/marketplace/models/marketplace_order.dart';
import 'package:lukymam_mvp/features/marketplace/models/marketplace_product.dart';
import 'package:lukymam_mvp/features/marketplace/providers/order_providers.dart';

MarketplaceProduct _product(String id, {int price = 1000, String? imageUrl}) {
  return MarketplaceProduct(
    id: id,
    name: 'Produit $id',
    description: 'desc',
    priceDZD: price,
    partnerId: 'partner_test',
    category: ProductCategory.puericulture,
    icon: ProductCategory.puericulture.icon,
    emoji: '🍼',
    imageUrl: imageUrl,
  );
}

void main() {
  group('MarketplaceProduct', () {
    test('formattedPrice groups thousands with spaces', () {
      expect(_product('a', price: 950).formattedPrice, '950 DZD');
      expect(_product('b', price: 2490).formattedPrice, '2 490 DZD');
      expect(_product('c', price: 1234567).formattedPrice, '1 234 567 DZD');
    });

    test('safeImageUrl accepts only well-formed https URLs', () {
      expect(
        _product('a', imageUrl: 'https://cdn.example.com/p.png').safeImageUrl,
        'https://cdn.example.com/p.png',
      );
      expect(
        _product('b', imageUrl: 'http://example.com/p.png').safeImageUrl,
        isNull,
      );
      expect(
        _product('c', imageUrl: 'javascript:alert(1)').safeImageUrl,
        isNull,
      );
      expect(
        _product('d', imageUrl: 'file:///etc/passwd').safeImageUrl,
        isNull,
      );
      expect(_product('e', imageUrl: '').safeImageUrl, isNull);
      expect(_product('f').safeImageUrl, isNull);
    });
  });

  group('CartNotifier', () {
    test('merges quantities for the same product', () {
      final cart = CartNotifier();
      expect(cart.add(_product('a'), quantity: 2), isTrue);
      expect(cart.add(_product('a'), quantity: 3), isTrue);
      expect(cart.state.single.quantity, 5);
    });

    test('caps a single line at CartItem.maxQuantity', () {
      final cart = CartNotifier();
      expect(cart.add(_product('a'), quantity: CartItem.maxQuantity), isTrue);
      expect(cart.add(_product('a'), quantity: 1), isFalse);
      expect(cart.state.single.quantity, CartItem.maxQuantity);
    });

    test('updateQuantity to zero removes the line', () {
      final cart = CartNotifier();
      cart.add(_product('a'));
      cart.updateQuantity('a', 0);
      expect(cart.state, isEmpty);
    });

    test('caps distinct products at maxDistinctItems', () {
      final cart = CartNotifier();
      for (var i = 0; i < CartNotifier.maxDistinctItems; i++) {
        expect(cart.add(_product('p$i')), isTrue);
      }
      expect(cart.add(_product('overflow')), isFalse);
      expect(cart.state.length, CartNotifier.maxDistinctItems);
    });

    test('line total multiplies unit price by quantity', () {
      final cart = CartNotifier();
      cart.add(_product('a', price: 1850), quantity: 3);
      expect(cart.state.single.lineTotalDZD, 5550);
    });
  });

  group('OrderStatus', () {
    test('fromString maps known values and falls back to pending', () {
      expect(OrderStatus.fromString('shipped'), OrderStatus.shipped);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('garbage'), OrderStatus.pending);
      expect(OrderStatus.fromString(null), OrderStatus.pending);
    });
  });
}
