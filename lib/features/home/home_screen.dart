import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/l10n_extension.dart';
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
  int _currentIndex = 0;

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

  List<NavItem> _navItems(BuildContext context) {
    final l10n = context.l10n;
    return [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.navHome,
      ),
      NavItem(
        icon: Icons.timeline_outlined,
        activeIcon: Icons.timeline_rounded,
        label: l10n.navTimeline,
      ),
      NavItem(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt_rounded,
        label: l10n.navCapsules,
      ),
      NavItem(
        icon: Icons.vaccines_outlined,
        activeIcon: Icons.vaccines_rounded,
        label: l10n.navHealth,
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.navProfile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) _maybeShowInterstitial();
          setState(() => _currentIndex = index);
        },
        items: _navItems(context),
      ),
    );
  }
}
