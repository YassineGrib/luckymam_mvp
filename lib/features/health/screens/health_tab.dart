import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../home/tabs/vaccinations_tab.dart';
import '../screens/appointments_screen.dart';
import '../screens/growth_screen.dart';

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

    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: childrenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildError(textColor),
          data: (children) {
            if (children.isEmpty) {
              return _buildNoChildren(primary, textColor, secondaryText);
            }

            _selectedChild ??= children.first;
            if (!children.any((c) => c.id == _selectedChild?.id)) {
              _selectedChild = children.first;
            }

            return Column(
              children: [
                _buildHeader(primary, textColor, secondaryText),

                // Child selector (only when 2+ children)
                if (children.length > 1)
                  _buildChildSelector(
                    children,
                    primary,
                    textColor,
                    secondaryText,
                  ),

                // Sub-tab bar
                _buildTabBar(primary, textColor, isDark),

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
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(Color primary, Color textColor, Color secondaryText) =>
      Padding(
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
                    'Santé',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Vaccins · Croissance · Rendez-vous',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: secondaryText,
                    ),
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
      separatorBuilder: (_, __) => const SizedBox(width: 8),
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
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : primary,
              ),
            ),
          ),
        );
      },
    ),
  );

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar(Color primary, Color textColor, bool isDark) => Padding(
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
          Tab(text: '💉 Vaccins'),
          Tab(text: '📈 Croissance'),
          Tab(text: '🗓 RDV'),
        ],
      ),
    ),
  );

  // ─── Error / empty states ─────────────────────────────────────────────────

  Widget _buildError(Color textColor) => Center(
    child: Text(
      'Erreur de chargement',
      style: GoogleFonts.outfit(color: AppColors.error),
    ),
  );

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
