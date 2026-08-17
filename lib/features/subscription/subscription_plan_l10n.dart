import '../../l10n/app_localizations.dart';
import 'models/subscription_models.dart';

extension SubscriptionTierL10n on SubscriptionTier {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SubscriptionTier.free:
        return l10n.subscriptionPlanFreeTitle;
      case SubscriptionTier.premium:
        return l10n.subscriptionPlanPremiumTitle;
      case SubscriptionTier.vip:
        return l10n.subscriptionPlanVipTitle;
    }
  }
}

extension SubscriptionPlanL10n on SubscriptionPlan {
  String localizedTitle(AppLocalizations l10n) => tier.localizedLabel(l10n);

  String localizedSubtitle(AppLocalizations l10n) {
    switch (tier) {
      case SubscriptionTier.free:
        return l10n.subscriptionPlanFreeSubtitle;
      case SubscriptionTier.premium:
        return l10n.subscriptionPlanPremiumSubtitle;
      case SubscriptionTier.vip:
        return l10n.subscriptionPlanVipSubtitle;
    }
  }

  List<String> localizedFeatures(AppLocalizations l10n) {
    switch (tier) {
      case SubscriptionTier.free:
        return [
          l10n.subscriptionPlanFreeFeatureCapsules,
          l10n.subscriptionPlanFreeFeatureChild,
          l10n.subscriptionPlanFreeFeatureMilestones,
          l10n.subscriptionPlanFreeFeatureVaccines,
        ];
      case SubscriptionTier.premium:
        return [
          l10n.subscriptionPlanPremiumFeatureUnlimitedCapsules,
          l10n.subscriptionPlanPremiumFeatureAllChildren,
          l10n.subscriptionPlanPremiumFeatureMemoryBook,
          l10n.subscriptionPlanPremiumFeatureFullHealth,
          l10n.subscriptionPlanPremiumFeatureNoAds,
        ];
      case SubscriptionTier.vip:
        return [
          l10n.subscriptionPlanVipFeatureAllPremium,
          l10n.subscriptionPlanVipFeatureFreeAlbum,
          l10n.subscriptionPlanVipFeaturePrioritySupport,
          l10n.subscriptionPlanVipFeatureVipCard,
          l10n.subscriptionPlanVipFeaturePartnerCard,
        ];
    }
  }

  String localizedPriceLabel(AppLocalizations l10n) {
    if (priceDZD == 0) return l10n.subscriptionPlanFreePrice;
    return l10n.subscriptionPlanPriceDzd(priceDZD);
  }

  String localizedBillingCycle(AppLocalizations l10n) {
    if (priceDZD == 0) return '';
    return l10n.subscriptionPlanBillingPerYear;
  }
}
