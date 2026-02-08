import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../timeline/models/phase.dart';
import '../../timeline/services/timeline_service.dart';
import '../providers/home_providers.dart';

/// Personal greeting header with user context.
class PersonalHeader extends ConsumerWidget {
  const PersonalHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final childrenAsync = ref.watch(childrenProvider);
    final selectedChildAsync = ref.watch(selectedChildProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: childrenAsync.when(
        loading: () => _buildSkeleton(textColor),
        error: (_, __) =>
            _buildGreeting(context, textColor, secondaryColor, null, null),
        data: (children) {
          if (children.isEmpty) {
            return _buildGreeting(
              context,
              textColor,
              secondaryColor,
              null,
              null,
            );
          }

          return selectedChildAsync.when(
            loading: () => _buildSkeleton(textColor),
            error: (_, __) =>
                _buildGreeting(context, textColor, secondaryColor, null, null),
            data: (child) => _buildGreeting(
              context,
              textColor,
              secondaryColor,
              child,
              child != null
                  ? TimelineService.determineCurrentPhase(child)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 180,
          height: 32,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 140,
          height: 20,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(
    BuildContext context,
    Color textColor,
    Color secondaryColor,
    Child? child,
    Phase? phase,
  ) {
    final greeting = getTimeBasedGreeting();
    final name = child?.name ?? 'Maman';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Row(
      children: [
        // Left content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '$greeting, $name! 👋',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              // Phase badge
              if (phase != null && child != null)
                Row(
                  children: [
                    Icon(phase.icon, size: 16, color: phase.color),
                    const SizedBox(width: 6),
                    Text(
                      '${phase.labelFr} • ${child.name}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Bienvenue sur Luckymam!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: secondaryColor,
                  ),
                ),
            ],
          ),
        ),
        // Avatar circle
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primary, primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              child?.name.isNotEmpty == true
                  ? child!.name[0].toUpperCase()
                  : '',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
