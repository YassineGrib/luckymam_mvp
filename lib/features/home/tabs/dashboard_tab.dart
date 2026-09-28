import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../widgets/children_overview.dart';
import '../widgets/home_bento_grid.dart';
import '../widgets/home_bottom_bento.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/personal_header.dart';
import '../widgets/recent_capsules.dart';
import '../widgets/section_header.dart';
import '../widgets/upgrade_prompt_banner.dart';
import '../widgets/weekly_day_strip.dart';

/// Redesigned Home Dashboard Tab inspired by flagship international mobile apps.
/// Features an airy floating header, flagship companion hero card,
/// interactive 7-day capsule strip, and an asymmetric bento grid.
class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final profileAsync = ref.watch(profileProvider);
    final status = profileAsync.valueOrNull?.status;

    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          // ─── Atmospheric Ambient Glow ─────────────────────────────
          const TopAmbientGradient(height: 400),

          // ─── Scrollable Content ───────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. Airy Modern Top Header Bar (Avatar + Greeting + Date + Bell)
                const SliverToBoxAdapter(child: PersonalHeader()),

                // 2. Flagship Hero Companion Card (Lavender/Rose Squircle Card)
                const SliverToBoxAdapter(child: HomeHeroCompanionCard()),

                const SliverToBoxAdapter(child: SizedBox(height: 6)),

                // 3. 7-Day Interactive Capsule Day Strip
                const SliverToBoxAdapter(child: WeeklyDayStrip()),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // 4. Section: Your Programme / Bento Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Text(
                      l10n.dashboardQuickAccess,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF161618),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                // 5. Asymmetric Bento Grid (Tall health tracking + 2 stacked cards)
                const SliverToBoxAdapter(child: HomeBentoGrid()),

                // 6. Mes Enfants (For Mothers)
                if (status == UserStatus.mom) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: l10n.dashboardMyChildren,
                      icon: Icons.child_friendly_rounded,
                    ),
                  ),
                  const SliverToBoxAdapter(child: ChildrenOverview()),
                ],

                // 7. Recent Memories Carousel
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.dashboardMyMemories,
                    icon: Icons.photo_library_rounded,
                    trailing: l10n.dashboardSeeAll,
                    onTrailingTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.dashboardSeeAllCapsules),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: RecentCapsules()),

                // 8. Boutique Partenaires & Livre de Vie (Bento Row)
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.dashboardPartnerShop,
                    icon: Icons.storefront_rounded,
                  ),
                ),
                const SliverToBoxAdapter(child: HomeBottomBento()),

                // 9. Upgrade Prompt for free-tier users
                const SliverToBoxAdapter(child: UpgradePromptBanner()),

                // Bottom padding for floating navigation bar
                const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
