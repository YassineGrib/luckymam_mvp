import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/analytics_service.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../data/house_ads_data.dart';
import '../models/house_ad.dart';

const _kLastInterstitialKey = 'ads_last_interstitial_at';
const _kRotationPrefix = 'ads_rotation_';

/// Minimum delay between two interstitials (splash included).
const adInterstitialCooldown = Duration(minutes: 3);

/// An interstitial is considered every N tab switches (then the cooldown
/// still applies).
const adTabSwitchThreshold = 4;

/// One reel-feed ad after every N real reels.
const adReelInterval = 4;

/// Non-skippable ad duration per plan (LM2-122):
///   Gratuit → 5 s · Abonnés payants (Premium / VIP) → 0 s (aucune pub).
final adTimerSecondsProvider = Provider<int>((ref) {
  final tier = ref.watch(currentTierValueProvider);
  if (tier.isPaid) return 0;
  return 5;
});

/// Whether ads are enabled at all for the current user.
/// Any paid subscriber (Premium or VIP) never sees ads.
final adsEnabledProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierValueProvider);
  return !tier.isPaid;
});

/// Gatekeeper for every ad slot: tier gating, cooldowns, rotation.
/// House ads only — no third-party SDK is ever initialized.
class AdGate {
  AdGate(this._ref);

  final Ref _ref;

  /// Session-scoped counters (reset on app restart by design).
  int _tabSwitchCount = 0;
  bool _splashAdShownThisSession = false;

  /// Returns the splash ad to show at launch, or null (VIP, already shown
  /// this session, cooldown active, or empty inventory).
  Future<HouseAd?> requestSplashAd() async {
    if (_splashAdShownThisSession) return null;
    final ad = await _requestAd(AdPlacement.splash);
    if (ad != null) _splashAdShownThisSession = true;
    return ad;
  }

  /// Call on every tab switch; returns an ad only when the switch count
  /// threshold AND the cooldown are both satisfied.
  Future<HouseAd?> requestTabInterstitial() async {
    _tabSwitchCount++;
    if (_tabSwitchCount < adTabSwitchThreshold) return null;
    final ad = await _requestAd(AdPlacement.interstitial);
    if (ad != null) _tabSwitchCount = 0;
    return ad;
  }

  Future<HouseAd?> _requestAd(AdPlacement placement) async {
    if (!_ref.read(adsEnabledProvider)) {
      final tier = _ref.read(currentTierValueProvider);
      AnalyticsService().logEvent(
        'ad_blocked_vip',
        parameters: {
          'placement': placement.name,
          'tier': tier.name,
        },
      );
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_kLastInterstitialKey) ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastMs;
    if (elapsed < adInterstitialCooldown.inMilliseconds) return null;

    final inventory = adsForPlacement(placement);
    if (inventory.isEmpty) return null;

    // Round-robin rotation, persisted per placement.
    final rotKey = '$_kRotationPrefix${placement.name}';
    final index = (prefs.getInt(rotKey) ?? 0) % inventory.length;
    await prefs.setInt(rotKey, index + 1);
    await prefs.setInt(
      _kLastInterstitialKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    return inventory[index];
  }

  /// Reel-feed ads bypass the interstitial cooldown (they are non-blocking)
  /// but still respect VIP gating. Called from build — no side effects here;
  /// `ad_blocked_vip` is logged by the blocking request paths.
  List<HouseAd> reelAds() {
    if (!_ref.read(adsEnabledProvider)) return const [];
    return adsForPlacement(AdPlacement.reel);
  }
}

final adGateProvider = Provider<AdGate>((ref) => AdGate(ref));
