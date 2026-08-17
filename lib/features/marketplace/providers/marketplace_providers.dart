import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/marketplace_data.dart';
import '../models/marketplace_product.dart';
import '../services/marketplace_service.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService();
});

/// Live catalogue from Firestore; falls back to static V1 data when empty or offline.
final marketplaceProductsStreamProvider =
    StreamProvider<List<MarketplaceProduct>>((ref) {
  return ref.watch(marketplaceServiceProvider).watchActiveProducts();
});

final marketplaceProductsProvider = Provider<List<MarketplaceProduct>>((ref) {
  final remote = ref.watch(marketplaceProductsStreamProvider);
  return remote.when(
    data: (list) => list,
    loading: () => const [],
    error: (error, stackTrace) => marketplaceProducts,
  );
});

/// Whether the catalogue stream is still loading (before first Firestore snapshot).
final marketplaceCatalogLoadingProvider = Provider<bool>((ref) {
  return ref.watch(marketplaceProductsStreamProvider).isLoading;
});

/// All marketplace partners. Static in V1 — unknown Firestore partnerIds use [MarketplaceProduct.vendorName].
final marketplacePartnersProvider = Provider<List<MarketplacePartner>>((ref) {
  return marketplacePartners;
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

/// Vendor label for a product — static partner, Firestore vendor, or partnerId.
final productVendorLabelProvider = Provider.family<String, MarketplaceProduct>((
  ref,
  product,
) {
  final partner = ref.watch(partnerByIdProvider(product.partnerId));
  if (partner != null) return partner.name;
  final vendor = product.vendorName;
  if (vendor != null && vendor.isNotEmpty) return vendor;
  return product.partnerId;
});
