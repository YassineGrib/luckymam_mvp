import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Product category in the partner marketplace.
enum ProductCategory {
  puericulture,
  alimentation,
  hygiene,
  eveil,
  maman;

  String getLabel(String locale) {
    switch (this) {
      case ProductCategory.puericulture:
        return locale == 'ar'
            ? 'رعاية الأطفال'
            : locale == 'en'
                ? 'Baby Care'
                : 'Puériculture';
      case ProductCategory.alimentation:
        return locale == 'ar'
            ? 'التغذية'
            : locale == 'en'
                ? 'Nutrition'
                : 'Alimentation';
      case ProductCategory.hygiene:
        return locale == 'ar'
            ? 'النظافة والجمال'
            : locale == 'en'
                ? 'Hygiene'
                : 'Hygiène';
      case ProductCategory.eveil:
        return locale == 'ar'
            ? 'الألعاب والتعليم'
            : locale == 'en'
                ? 'Learning & Toys'
                : 'Éveil & Jouets';
      case ProductCategory.maman:
        return locale == 'ar'
            ? 'مساحة الأم'
            : locale == 'en'
                ? 'Mother Care'
                : 'Espace Maman';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.puericulture:
        return Icons.baby_changing_station_rounded;
      case ProductCategory.alimentation:
        return Icons.restaurant_rounded;
      case ProductCategory.hygiene:
        return Icons.sanitizer_rounded;
      case ProductCategory.eveil:
        return Icons.toys_rounded;
      case ProductCategory.maman:
        return Icons.spa_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProductCategory.puericulture:
        return AppColors.smaltBlue;
      case ProductCategory.alimentation:
        return AppColors.casablanca;
      case ProductCategory.hygiene:
        return AppColors.success;
      case ProductCategory.eveil:
        return AppColors.coral;
      case ProductCategory.maman:
        return AppColors.magentaPink;
    }
  }
}

/// A partner brand selling through the marketplace.
class MarketplacePartner {
  final String id;
  final String name;
  final String tagline;
  final String phone;
  final IconData icon;
  final Color color;

  const MarketplacePartner({
    required this.id,
    required this.name,
    required this.tagline,
    required this.phone,
    required this.icon,
    required this.color,
  });
}

/// A product listed in the partner marketplace.
class MarketplaceProduct {
  final String id;
  final String sku;
  /// Arabic (default) display name from backoffice.
  final String name;
  final String description;
  final String? nameFr;
  final String? nameEn;
  final String? descriptionFr;
  final String? descriptionEn;
  final List<String> highlightsFr;
  final List<String> highlightsEn;
  final int priceDZD;
  final int? compareAtDZD;
  final int stock;
  final String partnerId;
  final ProductCategory category;
  final IconData icon;
  final String? emoji;

  /// Optional remote image. Only rendered when it passes [safeImageUrl] —
  /// https-only, so an eventual backoffice can't inject arbitrary schemes.
  final String? imageUrl;

  /// Bullet points shown on the detail page (composition, sizes, etc.).
  final List<String> highlights;

  /// Partner display name from admin backoffice (when not in static partners list).
  final String? vendorName;

  final bool featured;

  const MarketplaceProduct({
    required this.id,
    this.sku = '',
    required this.name,
    required this.description,
    this.nameFr,
    this.nameEn,
    this.descriptionFr,
    this.descriptionEn,
    this.highlightsFr = const [],
    this.highlightsEn = const [],
    required this.priceDZD,
    required this.partnerId,
    required this.category,
    required this.icon,
    this.compareAtDZD,
    this.stock = 50,
    this.emoji,
    this.imageUrl,
    this.highlights = const [],
    this.vendorName,
    this.featured = false,
  });

  bool get isInStock => stock > 0;

  String get effectiveSku => sku.isNotEmpty ? sku : id;

  int get maxOrderQuantity {
    if (stock <= 0) return 0;
    const cap = 10;
    return stock < cap ? stock : cap;
  }

  /// Returns the image URL only if it is a well-formed https URL;
  /// anything else (http, file, javascript, malformed) is rejected.
  String? get safeImageUrl {
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || uri.scheme != 'https') return null;
    return url;
  }

  /// Localized product name for the active app locale (`ar`, `fr`, `en`).
  String displayName(String locale) =>
      _localizedText(locale, name, nameFr, nameEn);

  String displayDescription(String locale) =>
      _localizedText(locale, description, descriptionFr, descriptionEn);

  List<String> displayHighlights(String locale) => _localizedList(
        locale,
        highlights,
        highlightsFr,
        highlightsEn,
      );

  static String _localizedText(
    String locale,
    String ar,
    String? fr,
    String? en,
  ) {
    switch (locale) {
      case 'fr':
        if (fr != null && fr.isNotEmpty) return fr;
        break;
      case 'en':
        if (en != null && en.isNotEmpty) return en;
        break;
      default:
        if (ar.isNotEmpty) return ar;
    }
    if (ar.isNotEmpty) return ar;
    if (fr != null && fr.isNotEmpty) return fr;
    if (en != null && en.isNotEmpty) return en;
    return '';
  }

  static List<String> _localizedList(
    String locale,
    List<String> ar,
    List<String> fr,
    List<String> en,
  ) {
    switch (locale) {
      case 'fr':
        if (fr.isNotEmpty) return fr;
        break;
      case 'en':
        if (en.isNotEmpty) return en;
        break;
      default:
        if (ar.isNotEmpty) return ar;
    }
    if (ar.isNotEmpty) return ar;
    if (fr.isNotEmpty) return fr;
    if (en.isNotEmpty) return en;
    return const [];
  }

  /// Price formatted with thin grouping, e.g. "2 490 DZD".
  String get formattedPrice {
    final digits = priceDZD.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer DZD';
  }

  /// Maps a Firestore `marketplace_products` document to a product, or null if hidden.
  static MarketplaceProduct? fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) return null;

    final status = data['status'] as String? ?? 'active';
    if (status == 'archived' || status == 'draft' || status == 'out_of_stock') {
      return null;
    }

    final category = _categoryFromString(data['category'] as String?);
    if (category == null) return null;

    final priceRaw = data['priceDZD'] ?? data['price'];
    final price = priceRaw is num
        ? priceRaw.toInt()
        : int.tryParse('$priceRaw') ?? 0;

    final compareRaw = data['compareAt'];
    final compareAt = compareRaw is num ? compareRaw.toInt() : int.tryParse('$compareRaw');

    final stockRaw = data['stock'];
    final stock = stockRaw is num
        ? stockRaw.toInt()
        : int.tryParse('$stockRaw') ?? 0;

    final highlightsRaw = data['highlights'];
    final highlights = highlightsRaw is List
        ? highlightsRaw.map((e) => e.toString()).toList()
        : const <String>[];

    final highlightsFrRaw = data['highlightsFr'];
    final highlightsFr = highlightsFrRaw is List
        ? highlightsFrRaw.map((e) => e.toString()).toList()
        : const <String>[];

    final highlightsEnRaw = data['highlightsEn'];
    final highlightsEn = highlightsEnRaw is List
        ? highlightsEnRaw.map((e) => e.toString()).toList()
        : const <String>[];

    return MarketplaceProduct(
      id: doc.id,
      sku: (data['sku'] ?? doc.id).toString(),
      name: (data['name'] ?? data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      nameFr: data['nameFr'] as String?,
      nameEn: data['nameEn'] as String?,
      descriptionFr: data['descriptionFr'] as String?,
      descriptionEn: data['descriptionEn'] as String?,
      priceDZD: price,
      compareAtDZD: compareAt,
      stock: stock,
      partnerId: (data['partnerId'] ?? 'unknown').toString(),
      category: category,
      icon: category.icon,
      emoji: data['emoji'] as String?,
      imageUrl: data['imageUrl'] as String?,
      highlights: highlights,
      highlightsFr: highlightsFr,
      highlightsEn: highlightsEn,
      vendorName: data['vendor'] as String?,
      featured: data['featured'] == true,
    );
  }

  static ProductCategory? _categoryFromString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final c in ProductCategory.values) {
      if (c.name == raw) return c;
    }
    return null;
  }
}
