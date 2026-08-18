import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/child_profile_screen.dart';
import '../../profile/profile_screen.dart';
import '../providers/home_providers.dart';
import 'child_summary_card.dart';
import '../../../core/theme/app_typography.dart';

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
            context.l10n.homeYourChildren,
            style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
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
            error: (_, _) => const SizedBox.shrink(),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChildProfileScreen(child: summary.child),
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
      margin: const EdgeInsetsDirectional.only(end: 12),
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
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsetsDirectional.only(end: 20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addChild,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: -0.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
