import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/marketplace_data.dart';
import '../models/marketplace_product.dart';

/// All marketplace partners. Static in V1 — swap this provider's body for a
/// Firestore stream when the backoffice lands; consumers won't change.
final marketplacePartnersProvider = Provider<List<MarketplacePartner>>((ref) {
  return marketplacePartners;
});

/// Full product catalogue. Static in V1 (see note above).
final marketplaceProductsProvider = Provider<List<MarketplaceProduct>>((ref) {
  return marketplaceProducts;
});

/// Currently selected category filter (null = all products).
final selectedProductCategoryProvider = StateProvider<ProductCategory?>(
  (ref) => null,
);

/// Products filtered by the selected category.
final filteredProductsProvider = Provider<List<MarketplaceProduct>>((ref) {
  final all = ref.watch(marketplaceProductsProvider);
  final category = ref.watch(selectedProductCategoryProvider);
  if (category == null) return all;
  return all.where((p) => p.category == category).toList();
});

/// Partner lookup by id (null if unknown).
final partnerByIdProvider = Provider.family<MarketplacePartner?, String>((
  ref,
  partnerId,
) {
  final partners = ref.watch(marketplacePartnersProvider);
  return partners.where((p) => p.id == partnerId).firstOrNull;
});
