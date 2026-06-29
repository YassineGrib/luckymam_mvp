import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../widgets/children_overview.dart';
import '../widgets/cycle_tracking_section.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/health_shortcut_card.dart';
import '../widgets/personal_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_capsules.dart';
import '../widgets/section_header.dart';
import '../widgets/upgrade_prompt_banner.dart';

/// Dashboard tab — sections adapt to the user's status (HOPE / ENCEINTE / MAMAN).
class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final profileAsync = ref.watch(profileProvider);
    // Only resolve status once data is available — never default to mom during loading.
    final status = profileAsync.valueOrNull?.status;

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
            SliverToBoxAdapter(
              child: SectionHeader(
                title: _healthSectionTitle(status),
                icon: Icons.monitor_heart_rounded,
              ),
            ),
            const SliverToBoxAdapter(child: CycleTrackingSection()),
            const SliverToBoxAdapter(child: HealthShortcutCard()),

            // ─── Mes Enfants (MAMAN uniquement) ──────────────────────
            if (status == UserStatus.mom) ...[
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Mes Enfants',
                  icon: Icons.child_friendly_rounded,
                ),
              ),
              const SliverToBoxAdapter(child: ChildrenOverview()),
            ],

            // ─── Bannière contextuelle HOPE / ENCEINTE ────────────────
            if (status == UserStatus.hope || status == UserStatus.pregnant)
              SliverToBoxAdapter(child: _StatusContextBanner(status: status!)),

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

  String _healthSectionTitle(UserStatus? status) {
    switch (status) {
      case UserStatus.hope:
        return 'Mon Bien-être';
      case UserStatus.pregnant:
        return 'Ma Grossesse';
      default:
        return 'Ma Santé';
    }
  }
}

/// Contextual banner shown for HOPE and ENCEINTE instead of "Mes Enfants".
class _StatusContextBanner extends StatelessWidget {
  const _StatusContextBanner({required this.status});
  final UserStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isHope = status == UserStatus.hope;
    final color = isHope ? Colors.purple : Colors.pink;
    final icon = isHope ? Icons.favorite_border_rounded : Icons.pregnant_woman_rounded;
    final title = isHope
        ? 'Votre parcours commence ici 💜'
        : 'Votre bébé grandit 🩷';
    final subtitle = isHope
        ? 'Suivez votre cycle et prenez soin de vous.\nVos enfants apparaîtront ici dès l\'arrivée de bébé.'
        : 'La section Mes Enfants sera disponible\naprès la naissance de votre bébé.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
