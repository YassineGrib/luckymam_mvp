import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../providers/home_providers.dart';

/// Horizontal scroll section for health quick access cards.
class HealthQuickAccess extends ConsumerWidget {
  const HealthQuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final nextVaccine = ref.watch(nextVaccineProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SANTÉ',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Horizontal cards list
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Next vaccine card
              _buildHealthCard(
                context: context,
                isDark: isDark,
                icon: Icons.vaccines_rounded,
                title: nextVaccine?.group.vaccines.first.nameShort ?? 'Vaccin',
                subtitle: nextVaccine != null
                    ? _getVaccineStatus(nextVaccine.statusType)
                    : 'À jour',
                color: nextVaccine?.statusType == VaccineStatusType.overdue
                    ? AppColors.error
                    : AppColors.success,
                onTap: () {
                  // Navigate to vaccinations tab
                  _navigateToTab(context, 3);
                },
              ),
              // Medical appointment card
              _buildHealthCard(
                context: context,
                isDark: isDark,
                icon: Icons.calendar_month_rounded,
                title: 'Prochain RDV',
                subtitle: 'Voir calendrier',
                color: AppColors.smaltBlue,
                onTap: () {
                  // TODO: Navigate to appointments
                },
              ),
              // Health check card
              _buildHealthCard(
                context: context,
                isDark: isDark,
                icon: Icons.check_circle_rounded,
                title: 'Check-up',
                subtitle: 'Tout est bon',
                color: AppColors.success,
                onTap: () {
                  // Navigate to vaccinations
                  _navigateToTab(context, 3);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getVaccineStatus(VaccineStatusType type) {
    switch (type) {
      case VaccineStatusType.overdue:
        return 'En retard!';
      case VaccineStatusType.dueSoon:
        return 'À faire';
      case VaccineStatusType.upcoming:
        return 'Bientôt';
      case VaccineStatusType.completed:
        return 'Fait ✓';
    }
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    // Find the ancestor HomeScreen state and change tab
    // This is a simplified approach - ideally use a navigation provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voir onglet Vaccinations'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildHealthCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.onSurfaceLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
