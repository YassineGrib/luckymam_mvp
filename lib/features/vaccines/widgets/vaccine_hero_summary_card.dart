import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../profile/models/profile_models.dart';
import '../models/vaccine_status.dart';
import '../providers/vaccine_providers.dart';

/// Luxury Hero companion summary card for the Vaccination Calendar.
/// Displays live completion percentage, progress bar, and next upcoming vaccine.
class VaccineHeroSummaryCard extends StatefulWidget {
  final Child child;
  final List<VaccineGroupWithStatus> vaccineGroups;

  const VaccineHeroSummaryCard({
    super.key,
    required this.child,
    required this.vaccineGroups,
  });

  @override
  State<VaccineHeroSummaryCard> createState() => _VaccineHeroSummaryCardState();
}

class _VaccineHeroSummaryCardState extends State<VaccineHeroSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant VaccineHeroSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vaccineGroups != widget.vaccineGroups) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    final totalCount = widget.vaccineGroups.length;
    final completedCount =
        widget.vaccineGroups.where((g) => g.isCompleted).length;
    final targetProgress =
        totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final percentage = (targetProgress * 100).toInt();

    // Find next upcoming / overdue vaccine
    VaccineGroupWithStatus? nextGroup;
    for (final group in widget.vaccineGroups) {
      if (!group.isCompleted) {
        nextGroup = group;
        break;
      }
    }

    final title = lang == 'ar'
        ? 'الحماية بالتطعيم'
        : (lang == 'en' ? 'Vaccine Protection' : 'Protection Vaccinale');

    final subtitle = lang == 'ar'
        ? 'البرنامج الوطني • ${widget.child.name}'
        : (lang == 'en'
            ? 'National Schedule • ${widget.child.name}'
            : 'Programme National • ${widget.child.name}');

    final counterLabel = lang == 'ar'
        ? '$completedCount من $totalCount مراحل مكتملة'
        : (lang == 'en'
            ? '$completedCount of $totalCount stages done'
            : '$completedCount sur $totalCount étapes effectuées');

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: 6,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2B1D2A),
                  const Color(0xFF1E1E26),
                ]
              : [
                  const Color(0xFFFFF0F5),
                  const Color(0xFFF7ECFC),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.35)
              : AppColors.primaryLight.withValues(alpha: 0.20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner bleeding watermark icon
          PositionedDirectional(
            bottom: -18,
            end: -12,
            child: IgnorePointer(
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 110,
                color: AppColors.primaryLight.withValues(
                  alpha: isDark ? 0.09 : 0.06,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row: Medical Shield Badge + Title + Percentage ──
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.vaccines_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.onSurfaceLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Percentage Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$percentage%',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Animated Linear Progress Bar ──
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, _) {
                    final currentVal = targetProgress * _progressAnim.value;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: currentVal,
                        minHeight: 7,
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.black.withValues(alpha: 0.06),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryLight,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Counter Label
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      counterLabel,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Next Due Vaccine Highlight Banner ──
                _buildNextDueBanner(context, nextGroup, isDark, lang),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDueBanner(
    BuildContext context,
    VaccineGroupWithStatus? nextGroup,
    bool isDark,
    String lang,
  ) {
    if (nextGroup == null) {
      // All vaccines completed celebration
      final doneText = lang == 'ar'
          ? '🎉 اكتملت جميع تطعيمات هذه المرحلة!'
          : (lang == 'en'
              ? '🎉 All scheduled vaccinations up to date!'
              : '🎉 Toutes les vaccinations sont à jour !');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                doneText,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Determine timing label & styling
    final isOverdue = nextGroup.statusType == VaccineStatusType.overdue;
    final isDueSoon = nextGroup.statusType == VaccineStatusType.dueSoon;

    final Color badgeBg;
    final Color badgeText;
    final String countdownText;

    if (isOverdue) {
      badgeBg = AppColors.error.withValues(alpha: 0.15);
      badgeText = AppColors.error;
      final days = -nextGroup.daysUntilDue;
      countdownText = lang == 'ar'
          ? 'متأخر بـ $days يوم'
          : (lang == 'en' ? '$days days late' : 'En retard de $days j');
    } else if (isDueSoon) {
      badgeBg = AppColors.warning.withValues(alpha: 0.18);
      badgeText = const Color(0xFFD97706); // Amber dark
      final days = nextGroup.daysUntilDue;
      if (days == 0) {
        countdownText = lang == 'ar'
            ? 'اليوم'
            : (lang == 'en' ? 'Today' : 'Aujourd\'hui');
      } else {
        countdownText = lang == 'ar'
            ? 'خلال $days يوم'
            : (lang == 'en' ? 'In $days days' : 'Dans $days j');
      }
    } else {
      badgeBg = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
      badgeText = isDark ? Colors.white70 : AppColors.textSecondaryLight;
      countdownText = DateFormat('d MMM yyyy', lang).format(nextGroup.expectedDate);
    }

    final nextPrefix = lang == 'ar'
        ? 'اللقاح القادم'
        : (lang == 'en' ? 'Next vaccine' : 'Prochain vaccin');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B22) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : AppColors.primaryLight.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOverdue
                  ? Icons.error_outline_rounded
                  : (isDueSoon ? Icons.alarm_rounded : Icons.event_rounded),
              size: 16,
              color: badgeText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$nextPrefix : ${nextGroup.group.getAgeLabel(lang)}',
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.onSurfaceLight,
                  ),
                ),
                Text(
                  nextGroup.group.vaccineCodesLabel,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 11,
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              countdownText,
              style: AppTypography.fromContext(
                context,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
