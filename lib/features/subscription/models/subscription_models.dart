import 'package:flutter/material.dart';

/// Subscription tier levels.
enum SubscriptionTier {
  free,
  premium,
  vip;

  String get labelFr {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gratuit';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.vip:
        return 'VIP Annuel';
    }
  }

  IconData get icon {
    switch (this) {
      case SubscriptionTier.free:
        return Icons.star_border_rounded;
      case SubscriptionTier.premium:
        return Icons.workspace_premium_rounded;
      case SubscriptionTier.vip:
        return Icons.diamond_rounded;
    }
  }

  bool get isPaid => this != SubscriptionTier.free;
}

/// Payment method options.
enum PaymentMethod {
  cib,
  edahabia;

  String get labelFr {
    switch (this) {
      case PaymentMethod.cib:
        return 'CIB';
      case PaymentMethod.edahabia:
        return 'Edahabia';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.cib:
        return 'Carte Interbancaire';
      case PaymentMethod.edahabia:
        return 'Algérie Poste';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cib:
        return Icons.credit_card_rounded;
      case PaymentMethod.edahabia:
        return Icons.account_balance_rounded;
    }
  }
}

/// Subscription plan definition.
class SubscriptionPlan {
  final SubscriptionTier tier;
  final String title;
  final String subtitle;
  final int priceDZD;
  final String billingCycle;
  final List<String> features;
  final int capsuleLimit;
  final int childLimit;
  final Color accentColor;
  final bool hasAlbumPerk;

  const SubscriptionPlan({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.priceDZD,
    required this.billingCycle,
    required this.features,
    required this.capsuleLimit,
    required this.childLimit,
    required this.accentColor,
    this.hasAlbumPerk = false,
  });

  bool get isUnlimited => capsuleLimit == -1;
  String get priceLabel => priceDZD == 0 ? 'Gratuit' : '$priceDZD DZD';

  static const List<SubscriptionPlan> allPlans = [
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      title: 'Gratuit',
      subtitle: 'Pour commencer',
      priceDZD: 0,
      billingCycle: '',
      capsuleLimit: 25,
      childLimit: 1,
      accentColor: Color(0xFF78909C),
      features: [
        '25 capsules maximum',
        '1 enfant',
        'Jalons de développement',
        'Vaccinations',
      ],
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.premium,
      title: 'Prémium',
      subtitle: 'Pour les mamans actives',
      priceDZD: 2490,
      billingCycle: '/an',
      capsuleLimit: -1,
      childLimit: -1,
      accentColor: Color(0xFFE85A71),
      features: [
        'Capsules illimitées',
        'Tous les enfants',
        'Livre de Mémoires',
        'Suivi de santé complet',
        'Sans publicités',
      ],
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.vip,
      title: 'VIP Annuel',
      subtitle: 'L\'expérience complète',
      priceDZD: 9890,
      billingCycle: '/an',
      capsuleLimit: -1,
      childLimit: -1,
      accentColor: Color(0xFFFF6F00),
      hasAlbumPerk: true,
      features: [
        'Tout Prémium inclus',
        'Album imprimé OFFERT 🎁',
        'Support prioritaire',
        'Carte VIP personnalisée',
        'Utilisation de la carte VIP avec nos partenaires*',
      ],
    ),
  ];
}

/// Album claim request for VIP perk.
class AlbumClaim {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String wilaya;
  final String address;
  final String childId;
  final String childName;
  final String dateRange;
  final String status; // pending, processing, shipped, delivered
  final DateTime createdAt;

  const AlbumClaim({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.wilaya,
    required this.address,
    required this.childId,
    required this.childName,
    required this.dateRange,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'fullName': fullName,
    'phone': phone,
    'wilaya': wilaya,
    'address': address,
    'childId': childId,
    'childName': childName,
    'dateRange': dateRange,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
