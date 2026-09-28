import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/child_profile_screen.dart';
import '../../profile/profile_screen.dart';
import '../providers/home_providers.dart';
import 'child_summary_card.dart';

/// Redesigned horizontal list of children summaries.
/// Features boutique squircle cards, soft pastel surfaces, and smooth scrolling.
class ChildrenOverview extends ConsumerWidget {
  const ChildrenOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(childrenSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 168,
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
      width: 152,
      margin: const EdgeInsetsDirectional.only(end: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final l10n = context.l10n;

    final bg = isDark ? const Color(0xFF241C20) : const Color(0xFFFFF4EE);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFFFDFD0);

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      },
      child: Container(
        width: 152,
        margin: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFFF7DCD0).withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Bleeding baby icon watermark in the corner
              Positioned(
                bottom: -22,
                right: -18,
                child: IgnorePointer(
                  child: Icon(
                    Icons.child_care_rounded,
                    size: 92,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFE87A5D).withValues(alpha: 0.09),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: primaryColor,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        l10n.addChild,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF241C1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
