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
            _buildGreeting(context, ref, textColor, secondaryColor, null, null),
        data: (children) {
          if (children.isEmpty) {
            return _buildGreeting(
              context,
              ref,
              textColor,
              secondaryColor,
              null,
              null,
            );
          }

          return selectedChildAsync.when(
            loading: () => _buildSkeleton(textColor),
            error: (_, __) => _buildGreeting(
              context,
              ref,
              textColor,
              secondaryColor,
              null,
              null,
            ),
            data: (child) => _buildGreeting(
              context,
              ref,
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
    WidgetRef ref,
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
                GestureDetector(
                  onTap: () => _showChildSelectionSheet(context, ref),
                  child: Row(
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
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: secondaryColor,
                      ),
                    ],
                  ),
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
        GestureDetector(
          onTap: () => _showChildSelectionSheet(context, ref),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
        ),
      ],
    );
  }

  void _showChildSelectionSheet(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.read(childrenProvider);

    childrenAsync.whenData((children) {
      if (children.isEmpty) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choisir un enfant',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...children.map((child) {
                  final isSelected =
                      ref.read(selectedChildIdProvider) == child.id ||
                      (ref.read(selectedChildIdProvider) == null &&
                          children.first.id == child.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.primaryLight
                          : Colors.grey.shade200,
                      child: Text(
                        child.name[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      child.name,
                      style: GoogleFonts.outfit(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryLight,
                          )
                        : null,
                    onTap: () {
                      ref.read(selectedChildIdProvider.notifier).state =
                          child.id;
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to add child screen
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ajouter un enfant'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
