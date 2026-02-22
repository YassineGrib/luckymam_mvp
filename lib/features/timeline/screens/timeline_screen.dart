import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/phase.dart';
import '../services/timeline_service.dart';
import '../widgets/timeline_rail.dart';
import '../widgets/phase_carousel.dart';
import 'milestone_detail_screen.dart';

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
                    _buildHeader(
                      context,
                      selectedChild.name,
                      children,
                      textColor,
                      primary,
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

  Widget _buildHeader(
    BuildContext context,
    String childName,
    List<Child> children,
    Color textColor,
    Color primary,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le Livre de Vie',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'de $childName',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (children.length > 1)
            PopupMenuButton<String>(
              icon: Icon(Icons.swap_horiz_rounded, color: primary),
              tooltip: 'Changer d\'enfant',
              onSelected: (childId) {
                ref.read(selectedChildIdProvider.notifier).state = childId;
              },
              itemBuilder: (context) => children.map((child) {
                return PopupMenuItem<String>(
                  value: child.id,
                  child: Row(
                    children: [
                      if (child.photoUrl != null)
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(child.photoUrl!),
                        )
                      else
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: primary.withOpacity(0.1),
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(child.name, style: GoogleFonts.outfit()),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
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
      error: (e, _) => Center(child: Text('Erreur: $e')),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedPhase.icon,
              size: 60,
              color: _selectedPhase.color.withOpacity(0.7),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucun jalon pour cette phase',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Les jalons apparaîtront au bon moment',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
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
              'Ajoutez un enfant',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pour voir sa timeline personnalisée',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.outfit(fontSize: 18, color: textColor),
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
}
