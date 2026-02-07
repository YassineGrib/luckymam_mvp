import 'package:flutter/material.dart';
import '../../shared/widgets/navigation/app_bottom_nav.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/timeline_tab.dart';
import 'tabs/capsules_tab.dart';
import 'tabs/vaccinations_tab.dart';
import 'tabs/profile_tab.dart';

/// Main home screen with bottom navigation and tab switching.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Tab screens
  final List<Widget> _tabs = const [
    DashboardTab(),
    TimelineTab(),
    CapsulesTab(),
    VaccinationsTab(),
    ProfileTab(),
  ];

  // Navigation items
  final List<NavItem> _navItems = const [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Accueil',
    ),
    NavItem(
      icon: Icons.timeline_outlined,
      activeIcon: Icons.timeline_rounded,
      label: 'Timeline',
    ),
    NavItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt_rounded,
      label: 'Capsules',
    ),
    NavItem(
      icon: Icons.vaccines_outlined,
      activeIcon: Icons.vaccines_rounded,
      label: 'Vaccins',
    ),
    NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
    );
  }
}
