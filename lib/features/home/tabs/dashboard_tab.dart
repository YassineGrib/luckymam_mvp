import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/health_quick_access.dart';
import '../widgets/personal_header.dart';
import '../widgets/recent_capsules.dart';
import '../widgets/today_milestone_card.dart';
import '../widgets/week_milestones.dart';

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
            // Personal greeting header
            const SliverToBoxAdapter(child: PersonalHeader()),
            // Today's milestone hero card
            const SliverToBoxAdapter(child: TodayMilestoneCard()),
            // Health quick access (vaccines, appointments)
            const SliverToBoxAdapter(child: HealthQuickAccess()),
            // Recent capsules preview
            const SliverToBoxAdapter(child: RecentCapsules()),
            // This week's milestones
            const SliverToBoxAdapter(child: WeekMilestones()),
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
