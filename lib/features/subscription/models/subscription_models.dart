import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool get isUnlimitedChildren => childLimit == -1;
  bool get isRecommended => tier == SubscriptionTier.premium;

  /// Formats the price with space thousand separator and DA suffix (e.g. "0 DA", "2 490 DA").
  String get formattedPrice {
    if (priceDZD == 0) return '0 DA';
    final formatted = priceDZD.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted DA';
  }

  /// Price with annual periodicity (e.g. "0 DA", "2 490 DA / an", "9 890 DA / an").
  String get formattedPriceWithCycle {
    if (priceDZD == 0) return '0 DA';
    return '$formattedPrice / an';
  }

  /// Feature flags aligned with LM-SUB-002 matrix
  bool get canShareCapsules => tier != SubscriptionTier.free;
  bool get canAccessPremiumPerks => tier != SubscriptionTier.free;
  bool get canAccessVipPerks => tier == SubscriptionTier.vip;
  bool get hasGiveaways => tier != SubscriptionTier.free;
  bool get hasPhysicalVipCard => tier == SubscriptionTier.vip;
  bool get hasFreePrintedPhotoA3 => tier == SubscriptionTier.vip;
  bool get hasPartnerPrivileges => tier == SubscriptionTier.vip;

  static const List<SubscriptionPlan> allPlans = [
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      priceDZD: 0,
      capsuleLimit: 38,
      childLimit: 1,
      accentColor: Color(0xFF78909C),
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.premium,
      priceDZD: 2490,
      capsuleLimit: -1,
      childLimit: 2,
      accentColor: Color(0xFFE85A71),
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.vip,
      priceDZD: 9890,
      capsuleLimit: -1,
      childLimit: -1,
      accentColor: Color(0xFFFF8F00),
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

  factory AlbumClaim.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AlbumClaim(
      id: doc.id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      wilaya: data['wilaya'] ?? '',
      address: data['address'] ?? '',
      childId: data['childId'] ?? '',
      childName: data['childName'] ?? '',
      dateRange: data['dateRange'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['createdAt'].toString()) ??
                  DateTime.now())
          : DateTime.now(),
    );
  }

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
