import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/profile_screen.dart';
import '../providers/home_providers.dart';
import 'child_summary_card.dart';

/// Horizontal list of children summaries.
class ChildrenOverview extends ConsumerWidget {
  const ChildrenOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(childrenSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Vos Enfants',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        SizedBox(
          height: 180, // Height for the cards
          child: summariesAsync.when(
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (context, index) => _buildSkeleton(context),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (summaries) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: summaries.length + 1, // +1 for Add button
                itemBuilder: (context, index) {
                  if (index == summaries.length) {
                    return _buildAddButton(context);
                  }

                  final summary = summaries[index];
                  return ChildSummaryCard(
                    child: summary.child,
                    nextVaccine: summary.nextVaccine,
                    nextMilestone: summary.nextMilestone,
                    onTap: () {
                      // Navigate to child details (e.g. Profile for now, or Timeline)
                      // TODO: Maybe navigate to Timeline with this child selected?
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return GestureDetector(
      onTap: () {
        // Navigate to Add Child screen
        // For now, go to Profile
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      },
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 20), // Extra padding at end
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(Icons.add_rounded, color: primaryColor, size: 32),
        ),
      ),
    );
  }
}
