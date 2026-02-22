import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/phase.dart';
import '../services/timeline_service.dart';
import '../widgets/milestone_card.dart';
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

                // Set initial phase to current if not set
                if (_selectedPhase != currentPhase && mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedPhase = currentPhase);
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
    final todayAsync = ref.watch(todayMilestonesProvider(childId));
    final upcomingAsync = ref.watch(upcomingMilestonesProvider(childId));

    return todayAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (todayMilestones) {
        return upcomingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
          data: (upcomingMilestones) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
              ),
              children: [
                // Today section
                if (todayMilestones.isNotEmpty) ...[
                  _buildSectionHeader(
                    icon: Icons.push_pin_rounded,
                    title: 'Aujourd\'hui',
                    textColor,
                    badgeCount: todayMilestones.length,
                    badgeColor: primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...todayMilestones.asMap().entries.map(
                    (entry) => _buildAnimatedItem(
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MilestoneCard(
                          milestone: entry.value,
                          isToday: true,
                          onTap: () =>
                              _openMilestoneDetail(context, entry.value),
                        ),
                      ),
                      entry.key,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Upcoming section
                if (upcomingMilestones.isNotEmpty) ...[
                  _buildSectionHeader(
                    icon: Icons.event_rounded,
                    title: 'À venir',
                    textColor,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...upcomingMilestones
                      .take(10)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildAnimatedItem(
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: MilestoneCard(
                              milestone: entry.value,
                              isToday: false,
                              compact: true,
                              onTap: () =>
                                  _openMilestoneDetail(context, entry.value),
                            ),
                          ),
                          todayMilestones.length + entry.key,
                        ),
                      ),
                ],

                // Empty state
                if (todayMilestones.isEmpty && upcomingMilestones.isEmpty)
                  _buildEmptyPhase(context, textColor, secondaryText),

                const SizedBox(height: 100), // Bottom padding
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(
    Color textColor, {
    required IconData icon,
    required String title,
    int? badgeCount,
    Color? badgeColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textColor.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (badgeCount != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor ?? textColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$badgeCount',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
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

  Widget _buildAnimatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      // Delay based on index (clamped to avoid long delays)
      builder: (context, value, child) {
        // Calculate effective opacity based on delayed start simulation
        // Since TweenAnimationBuilder starts immediately, we can't easily delay content without a Timer.
        // Instead, we use a simple slide/fade for now for all items,
        // relying on ListView's build timing for some natural stagger or just uniform animation.
        // To do real stagger, we'd need a StaggeredList package or stateful widget.
        // Let's stick to a simple entry animation.
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
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
