import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

import '../../capsules/screens/create_capsule_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/phase.dart';
import '../services/timeline_service.dart';
import '../widgets/timeline_rail.dart';
import '../widgets/phase_carousel.dart';
import 'milestone_detail_screen.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/providers/display_provider.dart';
import '../../../shared/widgets/page_header_with_filter.dart';

/// Main Timeline screen - "Le Livre de Vie"
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  Phase _selectedPhase = Phase.postPartum;
  String? _lastChildId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.onBackgroundDark
        : AppColors.onBackgroundLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final childrenAsync = ref.watch(childrenProvider);
    final selectedChildAsync = ref.watch(selectedChildProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: childrenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(context, textColor, secondaryText),
          data: (children) {
            if (children.isEmpty) {
              return _buildNoChild(context, textColor, secondaryText, primary);
            }

            return selectedChildAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildError(context, textColor, secondaryText),
              data: (selectedChild) {
                if (selectedChild == null) {
                  return _buildNoChild(
                    context,
                    textColor,
                    secondaryText,
                    primary,
                  );
                }

                // Determine current phase based on child
                final currentPhase = ref.watch(
                  currentPhaseProvider(selectedChild),
                );

                // Only sync phase when child changes
                if (_lastChildId != selectedChild.id) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedPhase = currentPhase;
                        _lastChildId = selectedChild.id;
                      });
                    }
                  });
                }

                return Column(
                  children: [
                    // Header with child selector
                    PageHeaderWithFilter(
                      title: context.l10n.timelineLifeBook,
                      subtitle: context.l10n.timelineLifeBookOf(selectedChild.name),
                      icon: Icons.auto_stories_rounded,
                      iconColor: primary,
                      iconGradient: null,
                      showBackButton: false,
                      childrenList: children,
                      selectedChildId: selectedChild.id,
                      allowAll: false,
                      onChildSelected: (id) {
                        if (id != null) {
                          ref.read(selectedChildIdProvider.notifier).state = id;
                        }
                      },
                      trailing: _buildQuickAddButton(
                        context,
                        primary,
                        selectedChild,
                      ),
                    ),

                    // Phase carousel
                    PhaseCarousel(
                      currentPhase: currentPhase,
                      selectedPhase: _selectedPhase,
                      onPhaseSelected: (phase) {
                        setState(() => _selectedPhase = phase);
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Milestones content
                    Expanded(
                      child: _buildMilestonesContent(
                        context,
                        selectedChild.id,
                        textColor,
                        secondaryText,
                        primary,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMilestonesContent(
    BuildContext context,
    String childId,
    Color textColor,
    Color secondaryText,
    Color primary,
  ) {
    // Side-effect: schedule milestone reminders whenever milestones are loaded.
    ref.watch(milestoneRemindersProvider(childId));

    final allMilestonesAsync = ref.watch(childMilestonesProvider(childId));

    return allMilestonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorWithMessage('$e'))),
      data: (allMilestones) {
        // Filter by selected phase
        final phaseMilestones = allMilestones
            .where((m) => m.milestone.phase == _selectedPhase)
            .toList();

        if (phaseMilestones.isEmpty) {
          return _buildEmptyPhase(context, textColor, secondaryText);
        }

        return TimelineRail(
          milestones: phaseMilestones,
          phase: _selectedPhase,
          viewMode: ref.watch(timelineViewModeProvider),
          onMilestoneTap: (m) => _openMilestoneDetail(context, m),
        );
      },
    );
  }

  Widget _buildEmptyPhase(
    BuildContext context,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedPhase.icon,
              size: 60,
              color: _selectedPhase.color.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.timelineNoMilestonesPhase,
              style: AppTypography.fromContext(context, 
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.timelineMilestonesAppear,
              style: AppTypography.fromContext(context, fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChild(
    BuildContext context,
    Color textColor,
    Color secondaryText,
    Color primary,
  ) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 60,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDark
                  : AppColors.primaryLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.timelineAddChildTitle,
              style: AppTypography.fromContext(context, 
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.timelineAddChildHint,
              style: AppTypography.fromContext(context, fontSize: 14, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.healthLoadingError,
            style: AppTypography.fromContext(context, fontSize: 18, color: textColor),
          ),
        ],
      ),
    );
  }

  void _openMilestoneDetail(
    BuildContext context,
    MilestoneWithDueDate milestone,
  ) {
    final selectedChild = ref.read(selectedChildProvider).value;
    if (selectedChild == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(
          milestone: milestone,
          childId: selectedChild.id,
        ),
      ),
    );
  }

  void _openQuickAdd(BuildContext context, Child child) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    AnalyticsService().logEvent('timeline_quickadd_opened');

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.timeline_quick_add,
              style: AppTypography.fromContext(context, 
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.timeline_quick_add_prompt,
              style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
            ),
            const SizedBox(height: 20),

            // Option 1 — Créer capsule
            _QuickAddTile(
              icon: Icons.camera_alt_rounded,
              color: primary,
              title: l10n.timeline_create_capsule,
              subtitle: l10n.timeline_create_capsule_subtitle,
              onTap: () {
                Navigator.pop(context);
                AnalyticsService().logEvent('timeline_quickadd_selected',
                    parameters: {'action': 'create_capsule'});
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateCapsuleScreen(
                      preselectedChildId: child.id,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Option 2 — Marquer un jalon
            _QuickAddTile(
              icon: Icons.star_rounded,
              color: Colors.orange,
              title: l10n.timeline_mark_milestone,
              subtitle: l10n.timeline_mark_milestone_subtitle,
              onTap: () {
                Navigator.pop(context);
                AnalyticsService().logEvent('timeline_quickadd_selected',
                    parameters: {'action': 'mark_milestone'});
                _openMilestonePickerSheet(context, child.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openMilestonePickerSheet(BuildContext context, String childId) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Get current phase milestones already loaded in state
    final allMilestones = ref.read(childMilestonesProvider(childId)).valueOrNull ?? [];
    final phaseMilestones = allMilestones
        .where((m) => m.milestone.phase == _selectedPhase && m.capsuleId == null)
        .take(6)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.timeline_upcoming_milestones,
                style: AppTypography.fromContext(context, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                _selectedPhase.getLabel(lang),
                style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
              ),
              const SizedBox(height: 16),
              if (phaseMilestones.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n.timeline_all_milestones_have_memory,
                      style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    itemCount: phaseMilestones.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final m = phaseMilestones[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: m.milestone.category.color.withValues(alpha: 0.3),
                          ),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: m.milestone.category.lightBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            m.milestone.category.icon,
                            color: m.milestone.category.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          m.milestone.getTitle(lang),
                          style: AppTypography.fromContext(context, 
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          m.milestone.ageRange,
                          style: AppTypography.fromContext(context, 
                            fontSize: 12,
                            color: secondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: secondary,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _openMilestoneDetail(context, m);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gradient « + » quick-add button — mirrors the Mes Capsules "Capturer" button
  Widget _buildQuickAddButton(BuildContext context, Color primary, Child? child) {
    return GestureDetector(
      onTap: child != null ? () => _openQuickAdd(context, child) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: child != null ? AppColors.primaryGradient : null,
          color: child != null ? null : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              context.l10n.timeline_add,
              style: AppTypography.fromContext(context, 
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Add tile ───────────────────────────────────────────────────────────

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surface = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.fromContext(context, 
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.fromContext(context, fontSize: 12, color: secondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
