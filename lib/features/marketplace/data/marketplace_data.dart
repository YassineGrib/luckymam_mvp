import 'package:flutter/material.dart';

import '../models/marketplace_product.dart';

/// Static V1 catalogue — placeholder partners and products.
/// Will be replaced by a Firestore-backed backoffice feed later; the
/// providers already isolate the UI from this data source.
const List<MarketplacePartner> marketplacePartners = [
  MarketplacePartner(
    id: 'partner_bebeconfort_dz',
    name: 'BébéConfort DZ',
    tagline: 'Puériculture & équipement bébé',
    phone: '0550 12 34 56',
    emoji: '🍼',
    color: Color(0xFF4F8289),
  ),
  MarketplacePartner(
    id: 'partner_naturalait',
    name: 'NaturaLait',
    tagline: 'Nutrition infantile & bio',
    phone: '0551 22 33 44',
    emoji: '🥣',
    color: Color(0xFFF9AD4A),
  ),
  MarketplacePartner(
    id: 'partner_douceur_maman',
    name: 'Douceur Maman',
    tagline: 'Soins & bien-être pour maman',
    phone: '0552 55 66 77',
    emoji: '🌸',
    color: Color(0xFFA7316E),
  ),
  MarketplacePartner(
    id: 'partner_eveil_jeux',
    name: 'Éveil & Jeux',
    tagline: 'Jouets éducatifs 0-6 ans',
    phone: '0553 88 99 00',
    emoji: '🧸',
    color: Color(0xFFE85A71),
  ),
];

const List<MarketplaceProduct> marketplaceProducts = [
  // ── Puériculture ─────────────────────────────────────────────────────────
  MarketplaceProduct(
    id: 'prod_biberon_anticolique',
    name: 'Biberon anti-colique 260 ml',
    description:
        'Biberon avec valve anti-colique intégrée pour réduire l\'ingestion '
        'd\'air pendant la tétée. Tétine débit lent, idéal dès la naissance.',
    priceDZD: 1850,
    partnerId: 'partner_bebeconfort_dz',
    category: ProductCategory.puericulture,
    emoji: '🍼',
    highlights: [
      'Sans BPA, stérilisable',
      'Valve anti-colique brevetée',
      'Dès la naissance (0 m+)',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_couffin_bebe',
    name: 'Couffin traditionnel garni',
    description:
        'Couffin artisanal en osier avec matelas, drap et coussin assortis. '
        'Léger et transportable, parfait pour les premiers mois.',
    priceDZD: 8900,
    partnerId: 'partner_bebeconfort_dz',
    category: ProductCategory.puericulture,
    emoji: '🧺',
    highlights: [
      'Osier naturel tressé main',
      'Matelas + parure inclus',
      'Poignées renforcées',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_chauffe_biberon',
    name: 'Chauffe-biberon rapide',
    description:
        'Chauffe le biberon en 3 minutes à température homogène. '
        'Fonction maintien au chaud et décongélation douce.',
    priceDZD: 6500,
    partnerId: 'partner_bebeconfort_dz',
    category: ProductCategory.puericulture,
    emoji: '♨️',
    highlights: [
      'Chauffe en 3 minutes',
      'Arrêt automatique',
      'Compatible tous biberons',
    ],
  ),

  // ── Alimentation ─────────────────────────────────────────────────────────
  MarketplaceProduct(
    id: 'prod_cereales_bio',
    name: 'Céréales infantiles bio 6 m+',
    description:
        'Céréales à base de blé et miel, enrichies en fer et vitamines. '
        'Sans sucre ajouté ni conservateurs, dès 6 mois.',
    priceDZD: 950,
    partnerId: 'partner_naturalait',
    category: ProductCategory.alimentation,
    emoji: '🥣',
    highlights: [
      'Certifié bio',
      'Enrichi en fer + vitamine D',
      'Dès 6 mois',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_petits_pots',
    name: 'Petits pots légumes ×6',
    description:
        'Assortiment de 6 petits pots de légumes cuisinés vapeur : carotte, '
        'courgette, potiron. Texture lisse pour la diversification.',
    priceDZD: 1400,
    partnerId: 'partner_naturalait',
    category: ProductCategory.alimentation,
    emoji: '🥕',
    highlights: [
      'Cuisson vapeur douce',
      'Sans sel ni sucre ajouté',
      'Dès 4-6 mois',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_gourde_compote',
    name: 'Gourdes compote réutilisables ×4',
    description:
        'Gourdes souples réutilisables à remplir de compotes maison. '
        'Fermeture zip étanche, lavables au lave-vaisselle.',
    priceDZD: 1200,
    partnerId: 'partner_naturalait',
    category: ProductCategory.alimentation,
    emoji: '🍎',
    highlights: [
      'Réutilisables et économiques',
      'Zip anti-fuite',
      'Sans BPA',
    ],
  ),

  // ── Hygiène ──────────────────────────────────────────────────────────────
  MarketplaceProduct(
    id: 'prod_liniment',
    name: 'Liniment oléo-calcaire 500 ml',
    description:
        'Nettoie et protège le siège de bébé à chaque change. Formule '
        'naturelle à l\'huile d\'olive, laisse un film protecteur apaisant.',
    priceDZD: 1100,
    partnerId: 'partner_douceur_maman',
    category: ProductCategory.hygiene,
    emoji: '🧴',
    highlights: [
      'Huile d\'olive naturelle',
      'Sans parfum ni paraben',
      'Peaux sensibles',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_coffret_bain',
    name: 'Coffret bain bébé complet',
    description:
        'Coffret cadeau : gel lavant doux, eau nettoyante, crème hydratante '
        'et brosse souple. L\'essentiel du bain dans un joli coffret.',
    priceDZD: 3400,
    partnerId: 'partner_douceur_maman',
    category: ProductCategory.hygiene,
    emoji: '🛁',
    highlights: [
      '4 produits testés dermatologiquement',
      'pH neutre',
      'Idée cadeau naissance',
    ],
  ),

  // ── Éveil & Jouets ───────────────────────────────────────────────────────
  MarketplaceProduct(
    id: 'prod_tapis_eveil',
    name: 'Tapis d\'éveil arches musicales',
    description:
        'Tapis molletonné avec arches, jouets suspendus, miroir et module '
        'musical. Stimule la motricité et les sens dès la naissance.',
    priceDZD: 7200,
    partnerId: 'partner_eveil_jeux',
    category: ProductCategory.eveil,
    emoji: '🎪',
    highlights: [
      '5 jouets d\'activité amovibles',
      'Module musical 15 mélodies',
      'Lavable en machine',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_cubes_bois',
    name: 'Cubes en bois alphabet arabe-français',
    description:
        'Coffret de 24 cubes en bois gravés : lettres arabes d\'un côté, '
        'françaises de l\'autre. Apprentissage bilingue en s\'amusant.',
    priceDZD: 2800,
    partnerId: 'partner_eveil_jeux',
    category: ProductCategory.eveil,
    emoji: '🔤',
    highlights: [
      'Bois massif, peintures non toxiques',
      'Bilingue arabe / français',
      'Dès 18 mois',
    ],
  ),

  // ── Espace Maman ─────────────────────────────────────────────────────────
  MarketplaceProduct(
    id: 'prod_coussin_allaitement',
    name: 'Coussin d\'allaitement ergonomique',
    description:
        'Coussin en croissant garni de microbilles, soutient bébé pendant '
        'l\'allaitement et soulage le dos de maman. Housse amovible en coton.',
    priceDZD: 4500,
    partnerId: 'partner_douceur_maman',
    category: ProductCategory.maman,
    emoji: '🌙',
    highlights: [
      'Microbilles thermorégulantes',
      'Housse coton lavable',
      'Utilisable pendant la grossesse',
    ],
  ),
  MarketplaceProduct(
    id: 'prod_huile_vergetures',
    name: 'Huile anti-vergetures grossesse',
    description:
        'Huile de soin à l\'amande douce et argan d\'Algérie. Prévient et '
        'atténue les vergetures, dès le premier trimestre.',
    priceDZD: 2200,
    partnerId: 'partner_douceur_maman',
    category: ProductCategory.maman,
    emoji: '✨',
    highlights: [
      'Argan et amande douce naturels',
      '100 % d\'origine végétale',
      'Testé sous contrôle dermatologique',
    ],
  ),
];

/// Lookup a partner by id.
MarketplacePartner? findPartner(String partnerId) {
  for (final p in marketplacePartners) {
    if (p.id == partnerId) return p;
  }
  return null;
}
