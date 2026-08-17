import 'package:flutter/material.dart';

/// Subscription tier levels.
enum SubscriptionTier {
  free,
  premium,
  vip;

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
  final int priceDZD;
  final int capsuleLimit;
  final int childLimit;
  final Color accentColor;
  final bool hasAlbumPerk;

  const SubscriptionPlan({
    required this.tier,
    required this.priceDZD,
    required this.capsuleLimit,
    required this.childLimit,
    required this.accentColor,
    this.hasAlbumPerk = false,
  });

  bool get isUnlimited => capsuleLimit == -1;

  static const List<SubscriptionPlan> allPlans = [
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      priceDZD: 0,
      capsuleLimit: 25,
      childLimit: 1,
      accentColor: Color(0xFF78909C),
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.premium,
      priceDZD: 2490,
      capsuleLimit: -1,
      childLimit: -1,
      accentColor: Color(0xFFE85A71),
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.vip,
      priceDZD: 9890,
      capsuleLimit: -1,
      childLimit: -1,
      accentColor: Color(0xFFFF6F00),
      hasAlbumPerk: true,
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
