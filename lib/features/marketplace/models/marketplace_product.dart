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
  final String name;
  final String description;
  final int priceDZD;
  final String partnerId;
  final ProductCategory category;
  final IconData icon;

  /// Optional remote image. Only rendered when it passes [safeImageUrl] —
  /// https-only, so an eventual backoffice can't inject arbitrary schemes.
  final String? imageUrl;

  /// Bullet points shown on the detail page (composition, sizes, etc.).
  final List<String> highlights;

  /// Partner display name from admin backoffice (when not in static partners list).
  final String? vendorName;

  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.priceDZD,
    required this.partnerId,
    required this.category,
    required this.icon,
    this.imageUrl,
    this.highlights = const [],
    this.vendorName,
  });

  /// Returns the image URL only if it is a well-formed https URL;
  /// anything else (http, file, javascript, malformed) is rejected.
  String? get safeImageUrl {
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || uri.scheme != 'https') return null;
    return url;
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
    if (status == 'archived' || status == 'draft') return null;

    final category = _categoryFromString(data['category'] as String?);
    if (category == null) return null;

    final priceRaw = data['priceDZD'] ?? data['price'];
    final price = priceRaw is num
        ? priceRaw.toInt()
        : int.tryParse('$priceRaw') ?? 0;

    final highlightsRaw = data['highlights'];
    final highlights = highlightsRaw is List
        ? highlightsRaw.map((e) => e.toString()).toList()
        : const <String>[];

    return MarketplaceProduct(
      id: doc.id,
      name: (data['name'] ?? data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      priceDZD: price,
      partnerId: (data['partnerId'] ?? 'unknown').toString(),
      category: category,
      icon: category.icon,
      imageUrl: data['imageUrl'] as String?,
      highlights: highlights,
      vendorName: data['vendor'] as String?,
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
