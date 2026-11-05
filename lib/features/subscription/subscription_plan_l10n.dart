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
          l10n.subscriptionMatrixValueFreeCapsules,
          l10n.subscriptionMatrixValueOneChild,
          l10n.subscriptionMatrixVaccines,
          l10n.subscriptionMatrixReels,
        ];
      case SubscriptionTier.premium:
        return [
          l10n.subscriptionPlanPremiumFeatureUnlimitedCapsules,
          l10n.subscriptionMatrixValueTwoChildren,
          l10n.subscriptionMatrixSharing,
          l10n.subscriptionMatrixPremiumPerks,
          '${l10n.subscriptionMatrixGiveaways}*',
        ];
      case SubscriptionTier.vip:
        return [
          l10n.subscriptionPlanVipFeatureAllPremium,
          l10n.subscriptionMatrixValueUnlimitedChildren,
          l10n.subscriptionMatrixValueOnePhotoA3,
          l10n.subscriptionPlanVipFeatureVipCard,
          '${l10n.subscriptionMatrixPartnerPrivileges}*',
        ];
    }
  }

  String localizedPriceLabel(AppLocalizations l10n) {
    if (priceDZD == 0) return '0 DA';
    final formatted = priceDZD.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted DA';
  }

  String localizedBillingCycle(AppLocalizations l10n) {
    if (priceDZD == 0) return '';
    return '/ an';
  }

  /// Dynamic action button label according to LM-SUB-001 & LM-SUB-002 rules.
  String localizedActionButton({
    required SubscriptionTier currentTier,
    required AppLocalizations l10n,
  }) {
    if (currentTier == tier) {
      return l10n.subscriptionPlanCurrentButton; // "Offre actuelle"
    }
    switch (tier) {
      case SubscriptionTier.free:
        return l10n.subscriptionPlanSelect;
      case SubscriptionTier.premium:
        if (currentTier == SubscriptionTier.vip) {
          return l10n.subscriptionPlanIncludedInVip; // "Inclus dans votre offre VIP"
        }
        return l10n.subscriptionUpgradeToPremium; // "Passer à Premium"
      case SubscriptionTier.vip:
        if (currentTier == SubscriptionTier.premium) {
          return l10n.subscriptionUpgradeToVip; // "Passer à VIP Annuel"
        }
        return l10n.subscriptionChooseVipAnnual; // "Choisir VIP Annuel"
    }
  }

  /// Whether action is disabled (current tier or Premium when already VIP).
  bool isActionDisabled({required SubscriptionTier currentTier}) {
    if (currentTier == tier) return true;
    if (currentTier == SubscriptionTier.vip && tier == SubscriptionTier.premium) {
      return true;
    }
    return false;
  }
}
