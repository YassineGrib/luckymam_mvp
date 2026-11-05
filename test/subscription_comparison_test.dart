import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/providers/capsule_providers.dart';
import 'package:lukymam_mvp/features/subscription/models/subscription_models.dart';
import 'package:lukymam_mvp/features/subscription/subscription_plan_l10n.dart';
import 'package:lukymam_mvp/l10n/app_localizations_fr.dart';

void main() {
  group('LM-SUB-001 & LM-SUB-002: Subscription Specifications & Models', () {
    test('SubscriptionPlan.allPlans has exactly 3 tiers in valid hierarchy', () {
      expect(SubscriptionPlan.allPlans.length, equals(3));
      expect(SubscriptionPlan.allPlans[0].tier, equals(SubscriptionTier.free));
      expect(SubscriptionPlan.allPlans[1].tier, equals(SubscriptionTier.premium));
      expect(SubscriptionPlan.allPlans[2].tier, equals(SubscriptionTier.vip));
    });

    test('Free tier matches LM-SUB-002 limits (0 DA, 38 capsules, 1 child)', () {
      final free = SubscriptionPlan.allPlans[0];
      expect(free.priceDZD, equals(0));
      expect(free.formattedPrice, equals('0 DA'));
      expect(free.formattedPriceWithCycle, equals('0 DA'));
      expect(free.capsuleLimit, equals(38));
      expect(free.childLimit, equals(1));
      expect(free.isUnlimited, isFalse);
      expect(free.isUnlimitedChildren, isFalse);
      expect(free.isRecommended, isFalse);
      expect(free.canShareCapsules, isFalse);
      expect(free.canAccessPremiumPerks, isFalse);
      expect(free.canAccessVipPerks, isFalse);
      expect(free.hasGiveaways, isFalse);
      expect(free.hasPhysicalVipCard, isFalse);
      expect(free.hasFreePrintedPhotoA3, isFalse);
      expect(free.hasPartnerPrivileges, isFalse);
    });

    test('freemiumCapsuleLimit constant is updated to 38', () {
      expect(freemiumCapsuleLimit, equals(38));
    });

    test('Premium tier matches LM-SUB-001/002 specs (2 490 DA/an, Recommended, 2 children, unlimited capsules, sharing)', () {
      final premium = SubscriptionPlan.allPlans[1];
      expect(premium.priceDZD, equals(2490));
      expect(premium.formattedPrice, equals('2 490 DA'));
      expect(premium.formattedPriceWithCycle, equals('2 490 DA / an'));
      expect(premium.capsuleLimit, equals(-1));
      expect(premium.isUnlimited, isTrue);
      expect(premium.childLimit, equals(2));
      expect(premium.isUnlimitedChildren, isFalse);
      expect(premium.isRecommended, isTrue); // LM-SUB-001: Mise en avant Recommandée
      expect(premium.canShareCapsules, isTrue);
      expect(premium.canAccessPremiumPerks, isTrue);
      expect(premium.canAccessVipPerks, isFalse);
      expect(premium.hasGiveaways, isTrue);
      expect(premium.hasPhysicalVipCard, isFalse);
      expect(premium.hasFreePrintedPhotoA3, isFalse);
      expect(premium.hasPartnerPrivileges, isFalse);
    });

    test('VIP tier matches LM-SUB-002 specs (9 890 DA/an, unlimited children & capsules, photo A3, VIP card, partners)', () {
      final vip = SubscriptionPlan.allPlans[2];
      expect(vip.priceDZD, equals(9890));
      expect(vip.formattedPrice, equals('9 890 DA'));
      expect(vip.formattedPriceWithCycle, equals('9 890 DA / an'));
      expect(vip.capsuleLimit, equals(-1));
      expect(vip.isUnlimited, isTrue);
      expect(vip.childLimit, equals(-1));
      expect(vip.isUnlimitedChildren, isTrue);
      expect(vip.isRecommended, isFalse);
      expect(vip.canShareCapsules, isTrue);
      expect(vip.canAccessPremiumPerks, isTrue);
      expect(vip.canAccessVipPerks, isTrue);
      expect(vip.hasGiveaways, isTrue);
      expect(vip.hasPhysicalVipCard, isTrue);
      expect(vip.hasFreePrintedPhotoA3, isTrue);
      expect(vip.hasPartnerPrivileges, isTrue);
      expect(vip.hasAlbumPerk, isTrue);
    });

    test('Dynamic button labels conform to transition matrix (LM-SUB-001/002)', () {
      final l10n = AppLocalizationsFr();
      final free = SubscriptionPlan.allPlans[0];
      final premium = SubscriptionPlan.allPlans[1];
      final vip = SubscriptionPlan.allPlans[2];

      // When user is Free:
      expect(free.localizedActionButton(currentTier: SubscriptionTier.free, l10n: l10n), equals(l10n.subscriptionPlanCurrentButton));
      expect(free.isActionDisabled(currentTier: SubscriptionTier.free), isTrue);

      expect(premium.localizedActionButton(currentTier: SubscriptionTier.free, l10n: l10n), equals('Passer à Premium'));
      expect(premium.isActionDisabled(currentTier: SubscriptionTier.free), isFalse);

      expect(vip.localizedActionButton(currentTier: SubscriptionTier.free, l10n: l10n), equals('Choisir VIP Annuel'));
      expect(vip.isActionDisabled(currentTier: SubscriptionTier.free), isFalse);

      // When user is Premium:
      expect(premium.localizedActionButton(currentTier: SubscriptionTier.premium, l10n: l10n), equals(l10n.subscriptionPlanCurrentButton));
      expect(premium.isActionDisabled(currentTier: SubscriptionTier.premium), isTrue);

      expect(vip.localizedActionButton(currentTier: SubscriptionTier.premium, l10n: l10n), equals('Passer à VIP Annuel'));
      expect(vip.isActionDisabled(currentTier: SubscriptionTier.premium), isFalse);

      // When user is VIP:
      expect(vip.localizedActionButton(currentTier: SubscriptionTier.vip, l10n: l10n), equals(l10n.subscriptionPlanCurrentButton));
      expect(vip.isActionDisabled(currentTier: SubscriptionTier.vip), isTrue);

      expect(premium.localizedActionButton(currentTier: SubscriptionTier.vip, l10n: l10n), equals('Inclus dans votre offre VIP'));
      expect(premium.isActionDisabled(currentTier: SubscriptionTier.vip), isTrue);
    });

    test('All ARB localization files contain required subscription keys', () {
      final requiredKeys = [
        'subscriptionPlansHeaderTitle',
        'subscriptionPlansHeaderSubtitle',
        'subscriptionPlanRecommendedBadge',
        'subscriptionVipExclusiveBadge',
        'subscriptionUpgradeToPremium',
        'subscriptionUpgradeToVip',
        'subscriptionChooseVipAnnual',
        'subscriptionPlanIncludedInVip',
        'subscriptionDisclaimerAvailableOffers',
        'subscriptionCompareOffers',
        'subscriptionActionLater',
        'subscriptionCapsuleLimitReachedTitle',
        'subscriptionCapsuleLimitReachedMessage',
        'subscriptionChildLimitReachedTitle',
        'subscriptionChildLimitReachedMessageFree',
        'subscriptionChildLimitReachedMessagePremium',
        'subscriptionMatrixPrice',
        'subscriptionMatrixCapsules',
        'subscriptionMatrixChildren',
        'subscriptionMatrixVaccines',
        'subscriptionMatrixReels',
        'subscriptionMatrixRecording',
        'subscriptionMatrixSharing',
        'subscriptionMatrixPremiumPerks',
        'subscriptionMatrixVipPerks',
        'subscriptionMatrixGiveaways',
        'subscriptionMatrixPrintedPhoto',
        'subscriptionMatrixVipCard',
        'subscriptionMatrixPartnerPrivileges',
        'subscriptionMatrixValueFreeCapsules',
        'subscriptionMatrixValueOneChild',
        'subscriptionMatrixValueTwoChildren',
        'subscriptionMatrixValueUnlimitedChildren',
        'subscriptionMatrixValueIncluded',
        'subscriptionMatrixValueNotIncluded',
        'subscriptionMatrixValueAvailableOffers',
        'subscriptionMatrixValueOnePhotoA3',
      ];

      for (final lang in ['fr', 'en', 'ar']) {
        final file = File('lib/l10n/app_$lang.arb');
        expect(file.existsSync(), isTrue, reason: 'app_$lang.arb must exist');
        final Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());

        for (final k in requiredKeys) {
          expect(jsonMap.containsKey(k), isTrue, reason: '$k missing in app_$lang.arb');
          expect((jsonMap[k] as String).isNotEmpty, isTrue, reason: '$k empty in app_$lang.arb');
        }

        // Verify capsule limit in strings
        expect(jsonMap['subscriptionPlanFreeFeatureCapsules'], contains('38'));
        expect(jsonMap['subscriptionCompareValueFreeCapsules'], contains('38'));
      }
    });
  });
}

