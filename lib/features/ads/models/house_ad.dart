import 'package:flutter/material.dart';

/// Where an ad slot lives in the app.
enum AdPlacement {
  /// Full-screen at app launch, after the sponsor interstitial.
  splash,

  /// Full-screen between important in-app transitions (tab changes).
  interstitial,

  /// Native item inserted inside the Reels vertical feed.
  reel;

  String getLabel(String locale) {
    switch (locale) {
      case 'ar':
        switch (this) {
          case AdPlacement.splash:
            return 'فتح التطبيق';
          case AdPlacement.interstitial:
            return 'انتقال (ملء الشاشة)';
          case AdPlacement.reel:
            return 'تدفق Reels';
        }
      case 'en':
        switch (this) {
          case AdPlacement.splash:
            return 'App open';
          case AdPlacement.interstitial:
            return 'Transition (interstitial)';
          case AdPlacement.reel:
            return 'Reels feed';
        }
      default:
        switch (this) {
          case AdPlacement.splash:
            return 'Ouverture de l\'app';
          case AdPlacement.interstitial:
            return 'Transition (interstitiel)';
          case AdPlacement.reel:
            return 'Flux Reels';
        }
    }
  }
}

/// A first-party ("house") ad served from the app's own inventory —
/// no third-party ad SDK, no external tracking.
class HouseAd {
  final String id;
  final AdPlacement placement;
  final String sponsorNameFr;
  final String sponsorNameAr;
  final String sponsorNameEn;
  final String titleFr;
  final String titleAr;
  final String titleEn;
  final String subtitleFr;
  final String subtitleAr;
  final String subtitleEn;
  final String emoji;
  final List<Color> gradientColors;

  IconData get icon {
    switch (id) {
      case 'vip_pass':
        return Icons.workspace_premium_rounded;
      case 'marketplace_promo':
        return Icons.shopping_bag_rounded;
      case 'predefined_album':
        return Icons.menu_book_rounded;
      case 'diamond_sponsor':
        return Icons.diamond_rounded;
      default:
        return Icons.smart_toy_rounded;
    }
  }

  /// Optional local asset (preferred for V1) — e.g. 'assets/ads/xxx.png'.
  final String? assetPath;

  /// Optional remote image; only rendered when https (see [safeImageUrl]).
  final String? imageUrl;

  /// Optional in-app destination route (GoRouter path), e.g. '/marketplace'.
  final String? ctaRoute;
  final String? ctaLabelFr;
  final String? ctaLabelAr;
  final String? ctaLabelEn;

  const HouseAd({
    required this.id,
    required this.placement,
    required this.sponsorNameFr,
    required this.sponsorNameAr,
    required this.sponsorNameEn,
    required this.titleFr,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleFr,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.emoji,
    required this.gradientColors,
    this.assetPath,
    this.imageUrl,
    this.ctaRoute,
    this.ctaLabelFr,
    this.ctaLabelAr,
    this.ctaLabelEn,
  });

  String getTitle(String locale) => _pick(locale, titleFr, titleAr, titleEn);

  String getSubtitle(String locale) =>
      _pick(locale, subtitleFr, subtitleAr, subtitleEn);

  String getSponsorName(String locale) =>
      _pick(locale, sponsorNameFr, sponsorNameAr, sponsorNameEn);

  String? getCtaLabel(String locale) {
    final fr = ctaLabelFr;
    if (fr == null) return null;
    return _pick(locale, fr, ctaLabelAr ?? fr, ctaLabelEn ?? fr);
  }

  /// https-only remote images — same validation policy as the marketplace.
  String? get safeImageUrl {
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || uri.scheme != 'https') return null;
    return url;
  }

  static String _pick(
    String locale,
    String fr,
    String ar,
    String en,
  ) {
    switch (locale) {
      case 'ar':
        return ar;
      case 'en':
        return en;
      default:
        return fr;
    }
  }
}
