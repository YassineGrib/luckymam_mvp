import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../home/tabs/vaccinations_tab.dart';
import '../screens/appointments_screen.dart';
import '../screens/growth_screen.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';

/// Main "Santé" tab — health hub with Vaccines, Growth & Appointments sub-tabs.
class HealthTab extends ConsumerStatefulWidget {
  const HealthTab({super.key});

  @override
  ConsumerState<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends ConsumerState<HealthTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Child? _selectedChild;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            child: childrenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildError(l10n),
          data: (children) {
            if (children.isEmpty) {
              return _buildNoChildren(
                primary,
                textColor,
                secondaryText,
                l10n,
              );
            }

            _selectedChild ??= children.first;
            if (!children.any((c) => c.id == _selectedChild?.id)) {
              _selectedChild = children.first;
            }

            return Column(
              children: [
                _buildHeader(primary, textColor, secondaryText, l10n),

                // Child selector (only when 2+ children)
                if (children.length > 1)
                  _buildChildSelector(
                    children,
                    primary,
                    textColor,
                    secondaryText,
                  ),

                // Sub-tab bar
                _buildTabBar(primary, textColor, isDark, l10n),

                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    // Disable slide if child is null (safety)
                    physics: _selectedChild == null
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    children: [
                      // Tab 0 — Vaccines (re-use existing widget body)
                      const VaccinationsTab(),
                      // Tab 1 — Growth chart
                      GrowthScreen(child: _selectedChild!),
                      // Tab 2 — Appointments
                      AppointmentsScreen(child: _selectedChild!),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  ),
);
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
    Color primary,
    Color textColor,
    Color secondaryText,
    AppLocalizations l10n,
  ) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screenPaddingH,
      AppSpacing.md,
      AppSpacing.screenPaddingH,
      AppSpacing.sm,
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navHealth,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                l10n.healthTabSubtitle,
                style: AppTypography.fromContext(context, fontSize: 13, color: secondaryText),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Child selector ───────────────────────────────────────────────────────

  Widget _buildChildSelector(
    List<Child> children,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
      ),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final child = children[i];
        final selected = child.id == _selectedChild?.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedChild = child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? primary : primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              child.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: selected ? Colors.white : primary),
            ),
          ),
        );
      },
    ),
  );

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar(
    Color primary,
    Color textColor,
    bool isDark,
    AppLocalizations l10n,
  ) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screenPaddingH,
      AppSpacing.sm,
      AppSpacing.screenPaddingH,
      AppSpacing.xs,
    ),
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.dividerLight,
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => HapticFeedback.selectionClick(),
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.fromContext(
          context,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.fromContext(
          context,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: textColor.withValues(alpha: 0.6),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.vaccines_rounded, size: 17),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    l10n.healthTabVaccines,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.show_chart_rounded, size: 17),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    l10n.healthTabGrowth,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_rounded, size: 17),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    l10n.healthTabRdv,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  // ─── Error / empty states ─────────────────────────────────────────────────

  Widget _buildError(AppLocalizations l10n) => Center(
    child: Text(
      l10n.healthLoadingError,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
    ),
  );

  Widget _buildNoChildren(
    Color primary,
    Color textColor,
    Color secondaryText,
    AppLocalizations l10n,
  ) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.child_care_rounded,
          size: 56,
          color: primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.healthNoChildTitle,
          style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.healthNoChildHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    ),
  );
}
