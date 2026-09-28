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

    final isGirl = child.gender == ChildGender.girl;
    final genderColor = isGirl
        ? (isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48))
        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB));
    final genderBgColor = isGirl
        ? (isDark ? const Color(0xFFFB7185).withValues(alpha: 0.15) : const Color(0xFFFFF1F2))
        : (isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.15) : const Color(0xFFEFF6FF));

    final bg = isDark ? const Color(0xFF241C20) : const Color(0xFFFFF4EE);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : (isGirl ? const Color(0xFFFFDFE5) : const Color(0xFFDCEBFE));

    final hasPhoto = child.photoUrl != null && child.photoUrl!.isNotEmpty;

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
                  : genderColor.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ─── 1. Full-Background Child Photo (Watermark / Transparent) ─
              if (hasPhoto) ...[
                Opacity(
                  opacity: isDark ? 0.35 : 0.32,
                  child: Image.network(
                    child.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                // Soft gradient scrim to ensure text and badges contrast perfectly
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                      colors: isDark
                          ? [
                              Colors.transparent,
                              const Color(0xFF241C20).withValues(alpha: 0.40),
                              const Color(0xFF241C20).withValues(alpha: 0.85),
                            ]
                          : [
                              Colors.transparent,
                              const Color(0xFFFFF4EE).withValues(alpha: 0.40),
                              const Color(0xFFFFF4EE).withValues(alpha: 0.88),
                            ],
                    ),
                  ),
                ),
              ] else ...[
                // Fallback: Large Baby Watermark Icon Bleeding into Corner
                Positioned(
                  bottom: -22,
                  right: -18,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.child_care_rounded,
                      size: 92,
                      color: isDark
                          ? genderColor.withValues(alpha: 0.04)
                          : genderColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ],

              // ─── 2. Foreground Card Content ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Child gender badge & Arrow outward
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: genderBgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: genderColor.withValues(alpha: 0.35),
                              width: 0.9,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGirl
                                    ? Icons.face_3_rounded
                                    : Icons.face_6_rounded,
                                size: 13,
                                color: genderColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isGirl ? l10n.profileGirl : l10n.profileBoy,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: genderColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            size: 13,
                            color: secondaryColor,
                          ),
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
                            fontSize: 16,
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
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
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
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: eventColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
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
}
