import 'package:flutter/material.dart';

import '../models/house_ad.dart';

/// V1 inventory — self-promotion ("house ads") demonstrating each slot
/// until partner campaigns are signed. Replace/extend freely; asset
/// dimensions and formats are specified in
/// docs/specs/spec_technique_espaces_publicitaires.md.
const List<HouseAd> houseAds = [
  // ── Splash (app open) ────────────────────────────────────────────────────
  HouseAd(
    id: 'house_splash_ad_space',
    placement: AdPlacement.splash,
    sponsorNameFr: 'Espace Publicitaire',
    sponsorNameAr: 'مساحة إعلانية',
    sponsorNameEn: 'Ad Space',
    titleFr: 'Espace Publicitaire Disponible',
    titleAr: 'مساحة إعلانية متاحة',
    titleEn: 'Ad Space Available',
    subtitleFr:
        'Votre marque auprès des mamans — Réservez cet emplacement exclusif.',
    subtitleAr:
        'علامتك التجارية لدى آلاف الأمهات — احجز هذه المساحة الحصرية.',
    subtitleEn:
        'Your brand with mothers — Book this exclusive placement.',
    emoji: '✨',
    gradientColors: [Color(0xFFF7EFF2), Color(0xFFFCEBEF)],
    assetPath: 'assets/images/ad_space_minimal.jpg',
    ctaRoute: '/diamond-sponsors',
    ctaLabelFr: 'Réserver cet espace',
    ctaLabelAr: 'احجز هذه المساحة',
    ctaLabelEn: 'Book this space',
  ),
  HouseAd(
    id: 'house_splash_premium',
    placement: AdPlacement.splash,
    sponsorNameFr: 'Luckymam',
    sponsorNameAr: 'Luckymam',
    sponsorNameEn: 'Luckymam',
    titleFr: 'Passez à Premium',
    titleAr: 'انتقلي إلى Premium',
    titleEn: 'Upgrade to Premium',
    subtitleFr:
        'Capsules illimitées, enfants illimités — 2 490 DZD/an seulement.',
    subtitleAr:
        'كبسولات غير محدودة، أطفال غير محدودين — 2 490 دج/سنة فقط.',
    subtitleEn:
        'Unlimited capsules, unlimited children — only 2,490 DZD/year.',
    emoji: '👑',
    gradientColors: [Color(0xFFA7316E), Color(0xFFE85A71)],
    assetPath: 'assets/images/premium_ad_minimal.jpg',
    ctaRoute: '/subscription',
    ctaLabelFr: 'Découvrir',
    ctaLabelAr: 'اكتشفي',
    ctaLabelEn: 'Discover',
  ),

  // ── Interstitials (transitions) ──────────────────────────────────────────
  HouseAd(
    id: 'house_inter_marketplace',
    placement: AdPlacement.interstitial,
    sponsorNameFr: 'Luckymam Marketplace',
    sponsorNameAr: 'Luckymam Marketplace',
    sponsorNameEn: 'Luckymam Marketplace',
    titleFr: 'Découvrez notre Marketplace',
    titleAr: 'اكتشفي متجرنا',
    titleEn: 'Discover our Marketplace',
    subtitleFr: 'Produits bébé & maman sélectionnés par nos partenaires.',
    subtitleAr: 'منتجات للأم والطفل مختارة من شركائنا.',
    subtitleEn: 'Baby & mom products selected by our partners.',
    emoji: '🛍️',
    gradientColors: [Color(0xFFF9AD4A), Color(0xFFE8833A)],
    assetPath: 'assets/images/ad_space_minimal.jpg',
    ctaRoute: '/marketplace',
    ctaLabelFr: 'Voir les produits',
    ctaLabelAr: 'عرض المنتجات',
    ctaLabelEn: 'View products',
  ),
  HouseAd(
    id: 'house_inter_vip',
    placement: AdPlacement.interstitial,
    sponsorNameFr: 'Luckymam VIP',
    sponsorNameAr: 'Luckymam VIP',
    sponsorNameEn: 'Luckymam VIP',
    titleFr: 'Album imprimé OFFERT',
    titleAr: 'ألبوم مطبوع مجاناً',
    titleEn: 'FREE printed album',
    subtitleFr: 'Avec l\'abonnement VIP — vos souvenirs entre vos mains.',
    subtitleAr: 'مع اشتراك VIP — ذكرياتك بين يديك.',
    subtitleEn: 'With VIP subscription — your memories in your hands.',
    emoji: '📖',
    gradientColors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    assetPath: 'assets/images/premium_ad_minimal.jpg',
    ctaRoute: '/subscription',
    ctaLabelFr: 'En savoir plus',
    ctaLabelAr: 'اعرفي المزيد',
    ctaLabelEn: 'Learn more',
  ),

  // ── Reels feed ───────────────────────────────────────────────────────────
  HouseAd(
    id: 'house_reel_sponsors',
    placement: AdPlacement.reel,
    sponsorNameFr: 'Sponsors Diamant',
    sponsorNameAr: 'الرعاة الماسيون',
    sponsorNameEn: 'Diamond Sponsors',
    titleFr: 'Ils soutiennent Luckymam',
    titleAr: 'يدعمون Luckymam',
    titleEn: 'They support Luckymam',
    subtitleFr: 'Découvrez les partenaires qui rendent l\'app possible.',
    subtitleAr: 'اكتشفي الشركاء الذين يجعلون التطبيق ممكناً.',
    subtitleEn: 'Meet the partners who make the app possible.',
    emoji: '💎',
    gradientColors: [Color(0xFF4F8289), Color(0xFF3A6B72)],
    ctaRoute: '/sponsors-diamant',
    ctaLabelFr: 'Voir les sponsors',
    ctaLabelAr: 'عرض الرعاة',
    ctaLabelEn: 'View sponsors',
  ),
  HouseAd(
    id: 'house_reel_marketplace',
    placement: AdPlacement.reel,
    sponsorNameFr: 'Luckymam Marketplace',
    sponsorNameAr: 'Luckymam Marketplace',
    sponsorNameEn: 'Luckymam Marketplace',
    titleFr: 'Le meilleur pour bébé',
    titleAr: 'الأفضل للطفل',
    titleEn: 'The best for baby',
    subtitleFr: 'Puériculture, éveil, nutrition — livré chez vous.',
    subtitleAr: 'مستلزمات، تنمية، تغذية — تُسلَّم إلى منزلك.',
    subtitleEn: 'Baby care, development, nutrition — delivered to you.',
    emoji: '🧸',
    gradientColors: [Color(0xFFE85A71), Color(0xFFA7316E)],
    ctaRoute: '/marketplace',
    ctaLabelFr: 'Explorer',
    ctaLabelAr: 'استكشفي',
    ctaLabelEn: 'Explore',
  ),
];

/// Ads available for a given placement.
List<HouseAd> adsForPlacement(AdPlacement placement) =>
    houseAds.where((a) => a.placement == placement).toList();
