import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/extensions/profile_l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';
import '../../timeline/services/timeline_service.dart';
import '../../vaccines/providers/vaccine_providers.dart';

/// Redesigned boutique Child Summary Card.
/// Matches the squircle aesthetic, soft pastel tint, corner-bleeding watermark,
/// and clean typography of the modern Home Dashboard.
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
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;

    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : const Color(0xFF241C1A);
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    // Determine event badge
    String eventText = l10n.homeChildAllGood;
    IconData eventIcon = Icons.check_circle_rounded;
    Color eventColor = const Color(0xFF27AE60);

    if (nextVaccine != null) {
      eventText = l10n.homeChildVaccineLabel(nextVaccine!.group.vaccineCodesLabel);
      eventIcon = Icons.medical_services_rounded;
      eventColor = AppColors.error;
    } else if (nextMilestone != null) {
      eventText = nextMilestone!.milestone.getTitle(lang);
      eventIcon = Icons.star_rounded;
      eventColor = const Color(0xFFF39C12);
    }

    final bg = isDark ? const Color(0xFF241C20) : const Color(0xFFFFF4EE);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFFFDFD0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 152,
        margin: const EdgeInsetsDirectional.only(end: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
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
              // ─── Watermark Icon Bleeding into Corner ───────────────
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

              // ─── Foreground Content ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Child Avatar with soft ring
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: child.photoUrl != null
                                ? Image.network(
                                    child.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _fallbackChildAvatar(child.name, primaryColor),
                                  )
                                : _fallbackChildAvatar(child.name, primaryColor),
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 14,
                          color: secondaryColor,
                        ),
                      ],
                    ),

                    // Name & Age
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          child.localizedAgeString(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Event micro-pill at the bottom
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: eventColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(eventIcon, size: 11, color: eventColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              eventText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackChildAvatar(String name, Color primaryColor) {
    return Container(
      color: primaryColor.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: primaryColor,
        ),
      ),
    );
  }
}
