import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';

import '../../timeline/services/timeline_service.dart';
import '../../vaccines/providers/vaccine_providers.dart';

/// Summary card for a child, showing photo, name, and next event.
class ChildSummaryCard extends StatelessWidget {
  const ChildSummaryCard({
    super.key,
    required this.child,
    this.nextVaccine,
    this.nextMilestone,
    required this.onTap,
  });

  final Child child;
  final VaccineGroupWithStatus? nextVaccine;
  final MilestoneWithDueDate? nextMilestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    // Determine what to show (Vaccine takes priority if urgent)
    String eventText = 'Tout va bien !';
    IconData eventIcon = Icons.check_circle_rounded;
    Color eventColor = Colors.green;

    if (nextVaccine != null) {
      eventText = 'Vaccin: ${nextVaccine!.group.vaccineCodesLabel}';
      eventIcon = Icons.medical_services_rounded;
      eventColor = AppColors.error; // Urgent
    } else if (nextMilestone != null) {
      eventText = nextMilestone!.milestone.titleFr;
      eventIcon = Icons.star_rounded;
      eventColor = AppColors.goldenrod;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child.photoUrl != null
                  ? ClipOval(
                      child: Image.network(child.photoUrl!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Text(
                        child.name.isNotEmpty
                            ? child.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Name & Age
            Text(
              child.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              child.ageString,
              style: GoogleFonts.outfit(fontSize: 12, color: secondaryColor),
            ),
            const SizedBox(height: 12),

            // Next Event
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: eventColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(eventIcon, size: 12, color: eventColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      eventText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: eventColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
