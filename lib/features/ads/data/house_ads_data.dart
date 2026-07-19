import 'package:flutter/material.dart';

import '../models/house_ad.dart';

/// V1 inventory — self-promotion ("house ads") demonstrating each slot
/// until partner campaigns are signed. Replace/extend freely; asset
/// dimensions and formats are specified in
/// docs/specs/spec_technique_espaces_publicitaires.md.
const List<HouseAd> houseAds = [
  // ── Splash (app open) ────────────────────────────────────────────────────
  HouseAd(
    id: 'house_splash_premium',
    placement: AdPlacement.splash,
    sponsorName: 'Luckymam',
    title: 'Passez à Premium',
    subtitle:
        'Capsules illimitées, enfants illimités — 2 490 DZD/an seulement.',
    emoji: '👑',
    gradientColors: [Color(0xFFA7316E), Color(0xFFE85A71)],
    ctaRoute: '/home',
    ctaLabel: 'Découvrir',
  ),

  // ── Interstitials (transitions) ──────────────────────────────────────────
  HouseAd(
    id: 'house_inter_marketplace',
    placement: AdPlacement.interstitial,
    sponsorName: 'Luckymam Marketplace',
    title: 'Découvrez notre Marketplace',
    subtitle: 'Produits bébé & maman sélectionnés par nos partenaires.',
    emoji: '🛍️',
    gradientColors: [Color(0xFFF9AD4A), Color(0xFFE8833A)],
    ctaRoute: '/marketplace',
    ctaLabel: 'Voir les produits',
  ),
  HouseAd(
    id: 'house_inter_vip',
    placement: AdPlacement.interstitial,
    sponsorName: 'Luckymam',
    title: 'Album imprimé OFFERT',
    subtitle: 'Avec l\'abonnement VIP — vos souvenirs entre vos mains.',
    emoji: '📖',
    gradientColors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    ctaRoute: '/home',
    ctaLabel: 'En savoir plus',
  ),

  // ── Reels feed ───────────────────────────────────────────────────────────
  HouseAd(
    id: 'house_reel_sponsors',
    placement: AdPlacement.reel,
    sponsorName: 'Sponsors Diamant',
    title: 'Ils soutiennent Luckymam',
    subtitle: 'Découvrez les partenaires qui rendent l\'app possible.',
    emoji: '💎',
    gradientColors: [Color(0xFF4F8289), Color(0xFF3A6B72)],
    ctaRoute: '/sponsors-diamant',
    ctaLabel: 'Voir les sponsors',
  ),
  HouseAd(
    id: 'house_reel_marketplace',
    placement: AdPlacement.reel,
    sponsorName: 'Luckymam Marketplace',
    title: 'Le meilleur pour bébé',
    subtitle: 'Puériculture, éveil, nutrition — livré chez vous.',
    emoji: '🧸',
    gradientColors: [Color(0xFFE85A71), Color(0xFFA7316E)],
    ctaRoute: '/marketplace',
    ctaLabel: 'Explorer',
  ),
];

/// Ads available for a given placement.
List<HouseAd> adsForPlacement(AdPlacement placement) =>
    houseAds.where((a) => a.placement == placement).toList();
