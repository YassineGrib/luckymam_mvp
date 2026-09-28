import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../reels/screens/reels_screen.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../../vaccines/providers/vaccine_providers.dart';
import '../../vaccines/screens/vaccine_detail_screen.dart';

/// Card widget displaying a vaccine group with collapsible details,
/// dynamic floating watermark icon, micro-vaccine chips, and compact action controls.
class VaccineCard extends ConsumerStatefulWidget {
  const VaccineCard({
    super.key,
    required this.childId,
    required this.vaccineGroup,
    required this.onMarkComplete,
    required this.onMarkIncomplete,
  });

  final String childId;
  final VaccineGroupWithStatus vaccineGroup;
  final VoidCallback onMarkComplete;
  final VoidCallback onMarkIncomplete;

  @override
  ConsumerState<VaccineCard> createState() => _VaccineCardState();
}

class _VaccineCardState extends ConsumerState<VaccineCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final capsuleId = widget.vaccineGroup.status?.capsuleId;
    Capsule? linkedCapsule;
    if (capsuleId != null) {
      final capsulesAsync = ref.watch(capsulesProvider);
      linkedCapsule = capsulesAsync.whenOrNull(
        data: (list) => list.where((c) => c.id == capsuleId).firstOrNull,
      );
    }

    final isCompleted = widget.vaccineGroup.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(isDark),
          width: isCompleted ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? AppColors.success : Colors.black)
                .withValues(alpha: isDark ? 0.25 : (isCompleted ? 0.08 : 0.04)),
            blurRadius: isCompleted ? 10 : 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ── Dynamic Floating Watermark Icon (scales up when expanded, scales down when collapsed) ──
            PositionedDirectional(
              bottom: _isExpanded ? -20 : -10,
              end: _isExpanded ? -12 : -6,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.vaccines_rounded,
                    size: _isExpanded ? 104 : 54,
                    color: (isCompleted ? AppColors.success : primary)
                        .withValues(
                          alpha: isDark
                              ? (_isExpanded ? 0.09 : 0.04)
                              : (_isExpanded ? 0.08 : 0.035),
                        ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Header — always visible, tappable to expand/collapse
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          _buildStatusIcon(isDark, primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.vaccineGroup.group.getAgeLabel(lang),
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                _buildStatusText(secondaryText, primary),
                              ],
                            ),
                          ),
                          _buildActionButton(isDark, primary, textColor, linkedCapsule),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: secondaryText,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Collapsible details
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildDetails(
                    isDark,
                    textColor,
                    secondaryText,
                    primary,
                    linkedCapsule,
                    lang,
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(
    bool isDark,
    Color textColor,
    Color secondaryText,
    Color primary,
    Capsule? linkedCapsule,
    String lang,
  ) {
    final l10n = context.l10n;
    final isCompleted = widget.vaccineGroup.isCompleted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFF0EFF4),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Micro Vaccine Chips List ──
          ...widget.vaccineGroup.group.vaccines.map(
            (vaccine) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF22222C) : const Color(0xFFF7F6FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFECEAEF),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (isCompleted ? AppColors.success : primary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      vaccine.code,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isCompleted ? AppColors.success : primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vaccine.getName(lang),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // En savoir plus link
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VaccineDetailScreen(
                          vaccine: vaccine,
                          childId: widget.childId,
                          vaccineGroupId: widget.vaccineGroup.group.id,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 11.5, color: primary),
                          const SizedBox(width: 3),
                          Text(
                            l10n.vaccineDetails,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Notes callout if completed ──
          if (widget.vaccineGroup.status?.notes != null &&
              widget.vaccineGroup.status!.notes!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202028) : const Color(0xFFF3F3F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE5E5EB),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.edit_note_rounded, size: 16, color: primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.vaccineGroup.status!.notes!,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11.5,
                        color: secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xs),

          // ── Redesigned Compact Action Controls ──
          if (isCompleted) ...[
            // Completed state: horizontal actions row (Capsule + Reels)
            Row(
              children: [
                Expanded(
                  child: _buildCapsuleSection(isDark, textColor, secondaryText, primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReelsButton(primary, l10n),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Subtle, non-intrusive Cancel text button
            Center(
              child: TextButton.icon(
                onPressed: widget.onMarkIncomplete,
                icon: const Icon(Icons.undo_rounded, size: 13, color: AppColors.error),
                label: Text(
                  l10n.vaccineCancel,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ] else ...[
            // Pending state: Balanced Actions (Mark Complete + Reels) in 1:1 row
            Row(
              children: [
                Expanded(
                  child: _buildMarkDoneButton(primary, l10n),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReelsButton(primary, l10n),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkDoneButton(Color primary, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onMarkComplete,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.vaccineMarkDone,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelsButton(Color primary, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final codes = widget.vaccineGroup.group.vaccines
                .map((v) => v.code)
                .toList();
            AnalyticsService().logEvent(
              'vax_reels_opened',
              parameters: {
                'childId': widget.childId,
                'vaccineGroupId': widget.vaccineGroup.group.id,
              },
            );
            final lang = Localizations.localeOf(context).languageCode;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReelsScreen(
                  initialVaccineCodes: codes,
                  initialVaccineLabel: widget.vaccineGroup.group.getAgeLabel(lang),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 16,
                  color: primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.vaccineReelsButton,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleSection(
    bool isDark,
    Color textColor,
    Color secondaryText,
    Color primary,
  ) {
    final capsuleId = widget.vaccineGroup.status?.capsuleId;
    if (capsuleId == null) {
      return _buildCapsuleCTA(primary);
    }

    final capsulesAsync = ref.watch(capsulesProvider);
    return capsulesAsync.when(
      loading: () => Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: primary),
        ),
      ),
      error: (_, _) => _buildCapsuleCTA(primary),
      data: (list) {
        final capsule = list.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) {
          return _buildCapsuleCTA(primary);
        }
        return _buildLinkedCapsuleRow(capsule, isDark, textColor, secondaryText);
      },
    );
  }

  Widget _buildLinkedCapsuleRow(
    Capsule capsule,
    bool isDark,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: () {
        AnalyticsService().logEvent(
          'vax_capsule_viewed',
          parameters: {
            'childId': widget.childId,
            'vaccineGroupId': widget.vaccineGroup.group.id,
            'capsuleId': capsule.id,
          },
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapsuleDetailScreen(capsule: capsule),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF22222C) : const Color(0xFFF7F6FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Hero(
                  tag: 'capsule_${capsule.id}',
                  child: CachedNetworkImage(
                    imageUrl: capsule.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 14, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.vaccineLinkedMemoryEmoji,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    capsule.emotion.getLabel(Localizations.localeOf(context).languageCode),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 9.5,
                      color: secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 11, color: secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleCTA(Color primary) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateCapsuleScreen(
                  vaccineGroupId: widget.vaccineGroup.group.id,
                  preselectedChildId: widget.childId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.capsule,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (widget.vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        return AppColors.success.withValues(alpha: 0.4);
      case VaccineStatusType.overdue:
        return AppColors.error.withValues(alpha: 0.45);
      case VaccineStatusType.dueSoon:
        return AppColors.warning.withValues(alpha: 0.45);
      case VaccineStatusType.upcoming:
        return isDark ? AppColors.dividerDark : const Color(0xFFEBE8F0);
    }
  }

  Widget _buildStatusIcon(bool isDark, Color primary) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (widget.vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        icon = Icons.check_circle_rounded;
        color = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.14);
        break;
      case VaccineStatusType.overdue:
        icon = Icons.error_outline_rounded;
        color = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.14);
        break;
      case VaccineStatusType.dueSoon:
        icon = Icons.alarm_rounded;
        color = AppColors.warning;
        bgColor = AppColors.warning.withValues(alpha: 0.14);
        break;
      case VaccineStatusType.upcoming:
        icon = Icons.event_note_rounded;
        color = primary;
        bgColor = primary.withValues(alpha: 0.10);
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 21),
      ),
    );
  }

  Widget _buildStatusText(Color secondaryText, Color primary) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    String text;
    Color color = secondaryText;

    switch (widget.vaccineGroup.statusType) {
      case VaccineStatusType.completed:
        final date = widget.vaccineGroup.status?.completedAt;
        text = date != null
            ? l10n.vaccineDoneOn(
                DateFormat('d MMM yyyy', lang).format(date),
              )
            : l10n.vaccineCompleted;
        color = AppColors.success;
        break;
      case VaccineStatusType.overdue:
        text = l10n.vaccineOverdueDays(-widget.vaccineGroup.daysUntilDue);
        color = AppColors.error;
        break;
      case VaccineStatusType.dueSoon:
        if (widget.vaccineGroup.daysUntilDue == 0) {
          text = l10n.vaccineDueToday;
        } else {
          text = l10n.vaccineDueInDays(widget.vaccineGroup.daysUntilDue);
        }
        color = AppColors.casablanca;
        break;
      case VaccineStatusType.upcoming:
        text = DateFormat(
          'd MMM yyyy',
          lang,
        ).format(widget.vaccineGroup.expectedDate);
        break;
    }

    return Text(
      text,
      style: AppTypography.fromContext(
        context,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildActionButton(
    bool isDark,
    Color primary,
    Color textColor,
    Capsule? linkedCapsule,
  ) {
    if (linkedCapsule != null) {
      return GestureDetector(
        onTap: () {
          AnalyticsService().logEvent(
            'vax_capsule_viewed',
            parameters: {
              'childId': widget.childId,
              'vaccineGroupId': widget.vaccineGroup.group.id,
              'capsuleId': linkedCapsule.id,
            },
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CapsuleDetailScreen(capsule: linkedCapsule),
            ),
          );
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isDark ? AppColors.success.withValues(alpha: 0.5) : AppColors.success,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
              imageUrl: linkedCapsule.photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.vaccineGroup.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3.5,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 15, color: AppColors.success),
            const SizedBox(width: 3.5),
            Text(
              context.l10n.vaccineDone,
              style: AppTypography.fromContext(
                context,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3.5,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        context.l10n.vaccineMark,
        style: AppTypography.fromContext(
          context,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
