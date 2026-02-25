import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/children_overview.dart';
import '../widgets/cycle_tracking_section.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/health_shortcut_card.dart';
import '../widgets/personal_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_capsules.dart';
import '../widgets/section_header.dart';
import '../widgets/upgrade_prompt_banner.dart';

/// Dashboard tab — main home content organized into clear sections.
class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ─── Welcome ─────────────────────────────────────────────
            const SliverToBoxAdapter(child: PersonalHeader()),

            // Upgrade prompt for free-tier users
            const SliverToBoxAdapter(child: UpgradePromptBanner()),

            // ─── Quick Actions ───────────────────────────────────────
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Accès Rapide',
                icon: Icons.bolt_rounded,
              ),
            ),
            const SliverToBoxAdapter(child: QuickActionsGrid()),

            // ─── Ma Santé ────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Ma Santé',
                icon: Icons.monitor_heart_rounded,
              ),
            ),
            const SliverToBoxAdapter(child: CycleTrackingSection()),
            const SliverToBoxAdapter(child: HealthShortcutCard()),

            // ─── Mes Enfants ─────────────────────────────────────────
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Mes Enfants',
                icon: Icons.child_friendly_rounded,
              ),
            ),
            const SliverToBoxAdapter(child: ChildrenOverview()),

            // ─── Mes Souvenirs ───────────────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Mes Souvenirs',
                icon: Icons.photo_library_rounded,
                trailing: 'Voir tout',
                onTrailingTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voir toutes les capsules'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: RecentCapsules()),

            // ─── Daily Tip ───────────────────────────────────────────
            const SliverToBoxAdapter(child: DailyTipCard()),

            // Bottom padding for navigation bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
