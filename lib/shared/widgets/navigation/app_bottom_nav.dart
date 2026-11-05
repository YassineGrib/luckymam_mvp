import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';

/// Global provider for the active tab index in HomeScreen.
/// 0: Home (Dashboard)
/// 1: Timeline
/// 2: Capsules
/// 3: Health (Vaccinations)
/// 4: Profile
final homeNavigationIndexProvider = StateProvider<int>((ref) => 0);

/// Navigation item data model.
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Builds standardized navigation items for the bottom navigation bar.
List<NavItem> getAppNavItems(BuildContext context) {
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

/// Helper to navigate to a home tab without losing the bottom navigation bar.
/// Pops secondary routes if open, or directs GoRouter to '/home'.
void navigateToHomeTab(BuildContext context, WidgetRef ref, int index) {
  ref.read(homeNavigationIndexProvider.notifier).state = index;
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  } else {
    context.go('/home');
  }
}

/// Premium floating bottom navigation bar with pill-style active indicator.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final backgroundColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? primaryColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? primaryColor : inactiveColor,
                    size: 24,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
