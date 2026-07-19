import 'package:flutter/material.dart';

/// Where an ad slot lives in the app.
enum AdPlacement {
  /// Full-screen at app launch, after the sponsor interstitial.
  splash,

  /// Full-screen between important in-app transitions (tab changes).
  interstitial,

  /// Native item inserted inside the Reels vertical feed.
  reel;

  String get labelFr {
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

/// A first-party ("house") ad served from the app's own inventory —
/// no third-party ad SDK, no external tracking.
class HouseAd {
  final String id;
  final AdPlacement placement;
  final String sponsorName;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;

  /// Optional local asset (preferred for V1) — e.g. 'assets/ads/xxx.png'.
  final String? assetPath;

  /// Optional remote image; only rendered when https (see [safeImageUrl]).
  final String? imageUrl;

  /// Optional in-app destination route (GoRouter path), e.g. '/marketplace'.
  final String? ctaRoute;
  final String? ctaLabel;

  const HouseAd({
    required this.id,
    required this.placement,
    required this.sponsorName,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    this.assetPath,
    this.imageUrl,
    this.ctaRoute,
    this.ctaLabel,
  });

  /// https-only remote images — same validation policy as the marketplace.
  String? get safeImageUrl {
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || uri.scheme != 'https') return null;
    return url;
  }
}
