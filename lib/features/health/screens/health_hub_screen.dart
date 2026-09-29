import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../screens/growth_screen.dart';
import '../screens/appointments_screen.dart';
import '../../../shared/widgets/page_header_with_filter.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../../shared/widgets/medical_disclaimer_banner.dart';

/// Standalone "Santé enfant" screen — Growth + Appointments with child selector.
/// Accessed via a shortcut card on the Dashboard, not the bottom nav.
class HealthHubScreen extends ConsumerStatefulWidget {
  const HealthHubScreen({super.key});

  @override
  ConsumerState<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends ConsumerState<HealthHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Child? _selectedChild;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            child: childrenAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(
                  l10n.healthLoadingError,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
              data: (children) {
                if (children.isEmpty) {
                  return _buildNoChildren(
                    primary,
                    textColor,
                    secondaryText,
                    l10n,
                  );
                }

                // Auto-select first child
                _selectedChild ??= children.first;
                if (!children.any((c) => c.id == _selectedChild?.id)) {
                  _selectedChild = children.first;
                }

                return Column(
                  children: [
                    // ── Header & Child Selector ─────────────────────────────
                    PageHeaderWithFilter(
                      title: l10n.navHealth,
                      subtitle: l10n.healthHubSubtitle,
                      icon: Icons.monitor_heart_rounded,
                      showBackButton: true,
                      childrenList: children,
                      selectedChildId: _selectedChild?.id,
                      allowAll: false,
                      onChildSelected: (id) {
                        if (id != null) {
                          setState(() {
                            _selectedChild = children.firstWhere(
                              (c) => c.id == id,
                              orElse: () => children.first,
                            );
                          });
                        }
                      },
                    ),

                    // ── Medical Disclaimer (Google Play Health Policy) ───────
                    const MedicalDisclaimerBanner(compact: true),

                    // ── Tab bar ─────────────────────────────────────────────
                    _buildTabBar(primary, textColor, isDark, surfaceColor, l10n),

                    // ── Tab views ───────────────────────────────────────────
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          GrowthScreen(child: _selectedChild!),
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

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar(
    Color primary,
    Color textColor,
    bool isDark,
    Color surfaceColor,
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
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.fromContext(
          context,
          fontSize: 13,
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
                const Icon(Icons.show_chart_rounded, size: 19),
                const SizedBox(width: 8),
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
                const Icon(Icons.calendar_month_rounded, size: 19),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.healthTabAppointments,
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

  // ─── Empty state ──────────────────────────────────────────────────────────

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
