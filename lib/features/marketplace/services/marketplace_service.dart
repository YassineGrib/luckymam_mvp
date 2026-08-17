import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/marketplace_product.dart';

/// Reads the admin-managed catalogue from Firestore (`marketplace_products`).
class MarketplaceService {
  MarketplaceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<MarketplaceProduct>> watchActiveProducts() {
    return _firestore.collection('marketplace_products').snapshots().map((
      snap,
    ) {
      final products = snap.docs
          .map(MarketplaceProduct.fromFirestoreDoc)
          .whereType<MarketplaceProduct>()
          .toList();
      products.sort((a, b) {
        if (a.featured != b.featured) return a.featured ? -1 : 1;
        return a.name.compareTo(b.name);
      });
      return products;
    });
  }
}
