import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TIER STATE
// ═══════════════════════════════════════════════════════════════════════════

/// Current user's subscription tier, read from Firestore.
final currentTierProvider = StreamProvider<SubscriptionTier>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(SubscriptionTier.free);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
        final data = doc.data();
        if (data == null) return SubscriptionTier.free;
        final tierStr = data['subscriptionTier'] as String?;
        if (tierStr == null) return SubscriptionTier.free;
        return SubscriptionTier.values.firstWhere(
          (t) => t.name == tierStr,
          orElse: () => SubscriptionTier.free,
        );
      });
});

/// Convenience: current tier as a sync value (defaults to free).
final currentTierValueProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(currentTierProvider).valueOrNull ?? SubscriptionTier.free;
});

// ═══════════════════════════════════════════════════════════════════════════
// PLANS
// ═══════════════════════════════════════════════════════════════════════════

/// All available subscription plans.
final subscriptionPlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  return SubscriptionPlan.allPlans;
});

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE GATING
// ═══════════════════════════════════════════════════════════════════════════

/// Capsule limit based on current tier.
final tierCapsuleLimitProvider = Provider<int>((ref) {
  final tier = ref.watch(currentTierValueProvider);
  final plan = SubscriptionPlan.allPlans.firstWhere((p) => p.tier == tier);
  return plan.capsuleLimit;
});

/// Whether the user has an active paid subscription.
final isPremiumProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierValueProvider);
  return tier.isPaid;
});

/// Whether the user has VIP tier.
final isVipProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierValueProvider);
  return tier == SubscriptionTier.vip;
});

/// Whether the VIP album perk has been claimed.
final albumClaimedProvider = StreamProvider<bool>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('album_claims')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs.isNotEmpty);
});

// ═══════════════════════════════════════════════════════════════════════════
// ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Subscription actions state.
class SubscriptionActionsState {
  final bool isLoading;
  final String? successMessage;
  final String? error;

  const SubscriptionActionsState({
    this.isLoading = false,
    this.successMessage,
    this.error,
  });

  SubscriptionActionsState copyWith({
    bool? isLoading,
    String? successMessage,
    String? error,
  }) => SubscriptionActionsState(
    isLoading: isLoading ?? this.isLoading,
    successMessage: successMessage,
    error: error,
  );
}

/// Notifier for subscription actions (upgrade, claim album).
class SubscriptionActionsNotifier
    extends StateNotifier<SubscriptionActionsState> {
  SubscriptionActionsNotifier() : super(const SubscriptionActionsState());

  /// Simulate upgrading to a paid tier (stores in Firestore).
  Future<void> upgradeTo(SubscriptionTier tier) async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Non connecté');

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'subscriptionTier': tier.name,
        'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      state = SubscriptionActionsState(
        successMessage: 'Abonnement ${tier.labelFr} activé !',
      );
    } catch (e) {
      state = SubscriptionActionsState(error: 'Erreur: $e');
    }
  }

  /// Submit a VIP album claim.
  Future<void> submitAlbumClaim(AlbumClaim claim) async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseFirestore.instance
          .collection('album_claims')
          .add(claim.toFirestore());
      state = const SubscriptionActionsState(
        successMessage:
            'Demande d\'album envoyée ! Nous vous contacterons bientôt.',
      );
    } catch (e) {
      state = SubscriptionActionsState(error: 'Erreur: $e');
    }
  }

  void clearMessages() {
    state = const SubscriptionActionsState();
  }
}

final subscriptionActionsProvider =
    StateNotifierProvider<
      SubscriptionActionsNotifier,
      SubscriptionActionsState
    >((ref) => SubscriptionActionsNotifier());
