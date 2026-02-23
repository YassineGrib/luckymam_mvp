import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/children_overview.dart';
import '../widgets/health_shortcut_card.dart';
import '../widgets/personal_header.dart';
import '../widgets/recent_capsules.dart';
import '../widgets/cycle_tracking_section.dart';

/// Dashboard tab - main home content with personalized sections.
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
            // Personal greeting header (Mother focus)
            const SliverToBoxAdapter(child: PersonalHeader()),

            // Visual Cycle Tracking (Replaces the basic MotherHealthCard)
            const SliverToBoxAdapter(child: CycleTrackingSection()),

            // Children's Overview
            const SliverToBoxAdapter(child: ChildrenOverview()),

            // Health Hub shortcut — Growth & Appointments
            const SliverToBoxAdapter(child: HealthShortcutCard()),

            // Recent capsules preview
            const SliverToBoxAdapter(child: RecentCapsules()),

            // Daily tip card
            const SliverToBoxAdapter(child: DailyTipCard()),

            // Bottom padding for navigation bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
