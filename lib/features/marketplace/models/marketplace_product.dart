import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Product category in the partner marketplace.
enum ProductCategory {
  puericulture,
  alimentation,
  hygiene,
  eveil,
  maman;

  String get labelFr {
    switch (this) {
      case ProductCategory.puericulture:
        return 'Puériculture';
      case ProductCategory.alimentation:
        return 'Alimentation';
      case ProductCategory.hygiene:
        return 'Hygiène';
      case ProductCategory.eveil:
        return 'Éveil & Jouets';
      case ProductCategory.maman:
        return 'Espace Maman';
    }
  }

  String get emoji {
    switch (this) {
      case ProductCategory.puericulture:
        return '🍼';
      case ProductCategory.alimentation:
        return '🥣';
      case ProductCategory.hygiene:
        return '🧴';
      case ProductCategory.eveil:
        return '🧸';
      case ProductCategory.maman:
        return '🌸';
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
  final String emoji;
  final Color color;

  const MarketplacePartner({
    required this.id,
    required this.name,
    required this.tagline,
    required this.phone,
    required this.emoji,
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
  final String emoji;

  /// Optional remote image. Only rendered when it passes [safeImageUrl] —
  /// https-only, so an eventual backoffice can't inject arbitrary schemes.
  final String? imageUrl;

  /// Bullet points shown on the detail page (composition, sizes, etc.).
  final List<String> highlights;

  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.priceDZD,
    required this.partnerId,
    required this.category,
    required this.emoji,
    this.imageUrl,
    this.highlights = const [],
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
}
