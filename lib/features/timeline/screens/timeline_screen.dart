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
import '../../../shared/widgets/top_ambient_gradient.dart';

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
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
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

                final allMilestonesAsync =
                    ref.watch(childMilestonesProvider(selectedChild.id));
                final viewMode = ref.watch(timelineViewModeProvider);

                return allMilestonesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(context.l10n.errorWithMessage('$e')),
                  ),
                  data: (allMilestones) {
                    final phaseMilestones = allMilestones
                        .where((m) => m.milestone.phase == _selectedPhase)
                        .toList();
                    final completedCount =
                        phaseMilestones.where((m) => m.isCompleted).length;
                    final totalCount = phaseMilestones.length;

                    // Calculate live statistics for all phases
                    final phaseStats = <Phase, PhaseStats>{};
                    for (final phase in Phase.values) {
                      final pMilestones = allMilestones
                          .where((m) => m.milestone.phase == phase)
                          .toList();
                      final pCompleted =
                          pMilestones.where((m) => m.isCompleted).length;
                      phaseStats[phase] = PhaseStats(
                        completed: pCompleted,
                        total: pMilestones.length,
                      );
                    }

                    return Column(
                      children: [
                        // Header with child selector
                        PageHeaderWithFilter(
                          title: context.l10n.timelineLifeBook,
                          subtitle: context.l10n
                              .timelineLifeBookOf(selectedChild.name),
                          icon: Icons.auto_stories_rounded,
                          iconColor: primary,
                          iconGradient: null,
                          showBackButton: false,
                          childrenList: children,
                          selectedChildId: selectedChild.id,
                          allowAll: false,
                          onChildSelected: (id) {
                            if (id != null) {
                              ref.read(selectedChildIdProvider.notifier).state =
                                  id;
                            }
                          },
                          trailing: _buildQuickAddButton(
                            context,
                            primary,
                            selectedChild,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Phase carousel with live stats & progress
                        PhaseCarousel(
                          currentPhase: currentPhase,
                          selectedPhase: _selectedPhase,
                          phaseStats: phaseStats,
                          onPhaseSelected: (phase) {
                            setState(() => _selectedPhase = phase);
                          },
                        ),

                        const SizedBox(height: 14),

                        // Section header with live counter and view toggle
                        _buildSectionHeader(
                          context,
                          completedCount,
                          totalCount,
                          viewMode,
                          textColor,
                          secondaryText,
                          _selectedPhase,
                        ),

                        const SizedBox(height: 8),

                        // Milestones content
                        Expanded(
                          child: _buildMilestonesContent(
                            context,
                            selectedChild,
                            phaseMilestones,
                            viewMode,
                            textColor,
                            secondaryText,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    ],
  ),
);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    int completedCount,
    int totalCount,
    TimelineViewMode viewMode,
    Color textColor,
    Color secondaryText,
    Phase phase,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = lang == 'ar'
        ? 'المعالم والذكريات'
        : (lang == 'en' ? 'Milestones & Memories' : 'Jalons & Souvenirs');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.fromContext(
              context,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: phase.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$completedCount / $totalCount',
              style: AppTypography.fromContext(
                context,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: phase.color,
              ),
            ),
          ),
          const Spacer(),
          _TimelineViewModeToggle(
            mode: viewMode,
            onChanged: (newMode) {
              ref.read(timelineViewModeProvider.notifier).setMode(newMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesContent(
    BuildContext context,
    Child selectedChild,
    List<MilestoneWithDueDate> phaseMilestones,
    TimelineViewMode viewMode,
    Color textColor,
    Color secondaryText,
  ) {
    // Side-effect: schedule milestone reminders whenever milestones are loaded.
    ref.watch(milestoneRemindersProvider(selectedChild.id));

    if (phaseMilestones.isEmpty) {
      return _buildEmptyPhase(context, textColor, secondaryText);
    }

    return TimelineRail(
      milestones: phaseMilestones,
      phase: _selectedPhase,
      viewMode: viewMode,
      onMilestoneTap: (m) => _openMilestoneDetail(context, m),
    );
  }

  Widget _buildEmptyPhase(
    BuildContext context,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E26) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : const Color(0xFFECECF0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _selectedPhase.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(
                    _selectedPhase.icon,
                    size: 30,
                    color: _selectedPhase.color,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.timelineNoMilestonesPhase,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.timelineMilestonesAppear,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 12.5,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  /// Gradient « + » quick-add button — boutique squircle design
  Widget _buildQuickAddButton(
    BuildContext context,
    Color primary,
    Child? child,
  ) {
    return _BouncingQuickAddButton(
      child: child,
      onTap: child != null ? () => _openQuickAdd(context, child) : null,
    );
  }
}

class _BouncingQuickAddButton extends StatefulWidget {
  final Child? child;
  final VoidCallback? onTap;

  const _BouncingQuickAddButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_BouncingQuickAddButton> createState() =>
      _BouncingQuickAddButtonState();
}

class _BouncingQuickAddButtonState extends State<_BouncingQuickAddButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasChild = widget.child != null;

    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
          decoration: BoxDecoration(
            gradient: hasChild ? AppColors.primaryGradient : null,
            color: hasChild ? null : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(14),
            boxShadow: hasChild
                ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 17),
              const SizedBox(width: 4),
              Text(
                context.l10n.timeline_add,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Timeline View Mode Toggle ────────────────────────────────────────────────

class _TimelineViewModeToggle extends StatelessWidget {
  final TimelineViewMode mode;
  final ValueChanged<TimelineViewMode> onChanged;

  const _TimelineViewModeToggle({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVertical = mode == TimelineViewMode.vertical;

    return Container(
      height: 32,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : const Color(0xFFEEEEF3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            icon: Icons.timeline_rounded,
            isSelected: isVertical,
            isDark: isDark,
            onTap: () => onChanged(TimelineViewMode.vertical),
          ),
          const SizedBox(width: 2),
          _buildSegment(
            icon: Icons.view_carousel_rounded,
            isSelected: !isVertical,
            isDark: isDark,
            onTap: () => onChanged(TimelineViewMode.horizontal),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 32,
        height: 27,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2E2E3A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 15,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primaryLight)
                : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

// ─── Quick Add tile ───────────────────────────────────────────────────────────

class _QuickAddTile extends StatefulWidget {
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
  State<_QuickAddTile> createState() => _QuickAddTileState();
}

class _QuickAddTileState extends State<_QuickAddTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surface =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 130),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.25),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
