import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../capsules/providers/capsule_providers.dart';
import '../profile/providers/profile_providers.dart';
import '../../shared/widgets/navigation/app_bottom_nav.dart';
import '../ads/providers/ads_providers.dart';
import '../ads/screens/interstitial_ad_screen.dart';
import 'tabs/capsules_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/timeline_tab.dart';
import 'tabs/vaccinations_tab.dart';

/// Main home screen with bottom navigation and tab switching.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;
      try {
        final profileService = ref.read(profileServiceProvider);
        final capsuleService = ref.read(capsuleServiceProvider);
        await profileService.ensureMamProfileCreated(
          defaultName: l10n.defaultMotherName,
        );
        await profileService.runProfileMigrationIfNeeded(
          placeholderName: l10n.childExpectedDefaultName,
        );
        await capsuleService.migrateCapsuleSubjects();
      } catch (e) {
        try {
          FirebaseCrashlytics.instance.recordError(
            Exception(e.runtimeType.toString()),
            StackTrace.empty,
            reason: 'home_profile_migration',
          );
        } catch (_) {}
      }
    });
  }

  /// Interstitial ad slot on tab transitions — every Nth switch, with a
  /// global cooldown, plan-gated (VIP: never). Fire-and-forget so the tab
  /// switch itself is never delayed.
  Future<void> _maybeShowInterstitial() async {
    final ad = await ref.read(adGateProvider).requestTabInterstitial();
    if (ad == null || !mounted) return;
    InterstitialAdScreen.show(context, ad);
  }

  // Tab screens
  final List<Widget> _tabs = const [
    DashboardTab(),
    TimelineTab(),
    CapsulesTab(),
    VaccinationsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeNavigationIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _tabs),
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) _maybeShowInterstitial();
          ref.read(homeNavigationIndexProvider.notifier).state = index;
        },
        items: getAppNavItems(context),
      ),
    );
  }
}
