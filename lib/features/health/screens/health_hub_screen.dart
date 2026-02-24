import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../screens/growth_screen.dart';
import '../screens/appointments_screen.dart';
import '../../../shared/widgets/page_header_with_filter.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: childrenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              'Erreur de chargement',
              style: GoogleFonts.outfit(color: AppColors.error),
            ),
          ),
          data: (children) {
            if (children.isEmpty)
              return _buildNoChildren(primary, textColor, secondaryText);

            // Auto-select first child
            _selectedChild ??= children.first;
            if (!children.any((c) => c.id == _selectedChild?.id)) {
              _selectedChild = children.first;
            }

            return Column(
              children: [
                // ── Header & Child Selector ─────────────────────────────
                PageHeaderWithFilter(
                  title: 'Santé',
                  subtitle: 'Croissance & Rendez-vous',
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

                // ── Tab bar ─────────────────────────────────────────────
                _buildTabBar(primary, textColor, isDark, surfaceColor),

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
    );
  }

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar(
    Color primary,
    Color textColor,
    bool isDark,
    Color surfaceColor,
  ) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screenPaddingH,
      AppSpacing.sm,
      AppSpacing.screenPaddingH,
      0,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
        labelColor: Colors.white,
        unselectedLabelColor: textColor.withValues(alpha: 0.6),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: '📈 Croissance'),
          Tab(text: '🗓 Rendez-vous'),
        ],
      ),
    ),
  );

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildNoChildren(
    Color primary,
    Color textColor,
    Color secondaryText,
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
          'Aucun enfant enregistré',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ajoutez un enfant dans votre profil.',
          style: GoogleFonts.outfit(color: secondaryText),
        ),
      ],
    ),
  );
}
