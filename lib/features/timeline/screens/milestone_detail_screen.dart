import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../notifications/notifications_screen.dart' show notificationPrefsProvider;
import '../../profile/providers/profile_providers.dart';
import '../data/milestone_advice_data.dart';
import '../models/milestone.dart';
import '../models/phase.dart';
import '../services/milestone_notification_service.dart';
import '../services/timeline_service.dart';

String _milestoneDateLocale(String languageCode) =>
    languageCode == 'fr' ? 'fr_FR' : languageCode;

String _formatReminderDateTime(BuildContext context, DateTime date) {
  final lang = Localizations.localeOf(context).languageCode;
  final pattern = lang == 'ar'
      ? 'd MMM في HH:mm'
      : lang == 'en'
          ? 'd MMM at HH:mm'
          : 'd MMM à HH:mm';
  return DateFormat(pattern, _milestoneDateLocale(lang)).format(date);
}

String _formatPresetDateAtNine(BuildContext context, DateTime date) {
  final lang = Localizations.localeOf(context).languageCode;
  return DateFormat(
    context.l10n.milestone_reminder_date_at_nine,
    _milestoneDateLocale(lang),
  ).format(date);
}

enum _MilestoneStatus { completed, overdue, current, upcoming }

/// Detail screen for a single milestone
class MilestoneDetailScreen extends ConsumerWidget {
  final MilestoneWithDueDate milestone;
  final String childId;

  const MilestoneDetailScreen({
    super.key,
    required this.milestone,
    required this.childId,
  });

  _MilestoneStatus _resolveStatus(MilestoneWithDueDate m) {
    if (m.isCompleted) return _MilestoneStatus.completed;
    if (m.dueDate == null) return _MilestoneStatus.upcoming;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(m.dueDate!.year, m.dueDate!.month, m.dueDate!.day);
    if (due.isBefore(today.subtract(const Duration(days: 7)))) {
      return _MilestoneStatus.overdue;
    }
    if (due.isBefore(today.add(const Duration(days: 1)))) {
      return _MilestoneStatus.current;
    }
    return _MilestoneStatus.upcoming;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.onBackgroundDark
        : AppColors.onBackgroundLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark
        ? const Color(0xFF131114)
        : const Color(0xFFFAF7F8);
    final m = milestone.milestone;
    final category = m.category;
    final phase = m.phase;
    final status = _resolveStatus(milestone);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Atmospheric Ambient Glow Tinted by Category Color ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color.withValues(alpha: isDark ? 0.22 : 0.16),
                      category.color.withValues(alpha: isDark ? 0.06 : 0.03),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // ─── Main Bento Scroll Content ───
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. Floating Top Navigation Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Frosted Squircle Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFE8E0E4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.25 : 0.04,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isRtl
                                    ? Icons.arrow_forward_ios_rounded
                                    : Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),

                        // Center: Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: category.color.withValues(alpha: 0.25),
                              width: 0.9,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.03,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 14,
                                color: category.color,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                category.getLabel(lang),
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Trailing placeholder to balance width with 42px back button
                        const SizedBox(width: 42),
                      ],
                    ),
                  ),
                ),

                // 2. Bento Scroll List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Hero Milestone Card
                      _buildHeroCard(
                        context: context,
                        isDark: isDark,
                        lang: lang,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        m: m,
                        category: category,
                        phase: phase,
                        status: status,
                      ),

                      const SizedBox(height: 14),

                      // Phase & Suggested Timing Bento Row
                      _buildInfoCardsRow(
                        context: context,
                        isDark: isDark,
                        lang: lang,
                        phase: phase,
                        m: m,
                      ),

                      const SizedBox(height: 14),

                      // Linked Capsule Card or Capture Action CTA
                      if (milestone.capsuleId != null)
                        _buildLinkedCapsuleCard(
                          context: context,
                          ref: ref,
                          isDark: isDark,
                          lang: lang,
                          textColor: textColor,
                          secondaryText: secondaryText,
                        )
                      else if (m.canHaveCapsule)
                        _buildCaptureButton(context),

                      if (milestone.capsuleId != null || m.canHaveCapsule)
                        const SizedBox(height: 14),

                      // Conseils & Astuces Photo Bento Card
                      _buildConseilBentoCard(
                        context: context,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        m: m,
                        category: category,
                      ),

                      const SizedBox(height: 14),

                      // Programmer un Rappel Bento Card
                      _buildReminderBentoCard(
                        context: context,
                        ref: ref,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        category: category,
                      ),

                      const SizedBox(height: 18),

                      // Completion Status / Mark Complete Button
                      _buildCompletionSection(
                        context: context,
                        ref: ref,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryText: secondaryText,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required Color textColor,
    required Color secondaryText,
    required Milestone m,
    required MilestoneCategory category,
    required Phase phase,
    required _MilestoneStatus status,
  }) {
    final surfaceColor = isDark ? const Color(0xFF1E1A1E) : Colors.white;
    final borderColor = isDark ? AppColors.dividerDark : const Color(0xFFEBEBF0);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Corner bleeding watermark icon
          PositionedDirectional(
            bottom: -16,
            end: -12,
            child: IgnorePointer(
              child: Icon(
                category.icon,
                size: 110,
                color: category.color.withValues(alpha: isDark ? 0.08 : 0.045),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon badge + Phase tag + Status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: category.color.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          category.icon,
                          size: 26,
                          color: category.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: phase.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      phase.icon,
                                      size: 11,
                                      color: phase.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      phase.getLabel(lang),
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: phase.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : const Color(0xFFF2EFF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  m.ageRange,
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            category.getLabel(lang),
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(context, status, phase),
                  ],
                ),

                const SizedBox(height: 16),

                // Milestone Title
                Text(
                  m.getTitle(lang),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Milestone Description
                Text(
                  m.getDescription(lang),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 14.5,
                    height: 1.55,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, _MilestoneStatus status, Phase phase) {
    if (status == _MilestoneStatus.upcoming) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final String label;
    final Color bgColor;
    final Color color;
    final IconData icon;

    switch (status) {
      case _MilestoneStatus.completed:
        label = l10n.timelineStatusCompleted;
        bgColor = AppColors.success.withValues(alpha: 0.15);
        color = AppColors.success;
        icon = Icons.check_rounded;
        break;
      case _MilestoneStatus.overdue:
        label = l10n.timelineStatusOverdue;
        bgColor = AppColors.error.withValues(alpha: 0.12);
        color = AppColors.error;
        icon = Icons.priority_high_rounded;
        break;
      case _MilestoneStatus.current:
        label = l10n.timelineStatusNow;
        bgColor = phase.color.withValues(alpha: 0.12);
        color = phase.color;
        icon = Icons.star_rounded;
        break;
      case _MilestoneStatus.upcoming:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.fromContext(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardsRow({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required Phase phase,
    required Milestone m,
  }) {
    final l10n = context.l10n;
    final surfaceColor = isDark ? const Color(0xFF1E1A1E) : Colors.white;
    final borderColor = isDark ? AppColors.dividerDark : const Color(0xFFEBEBF0);

    return Row(
      children: [
        // Phase Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: phase.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(phase.icon, size: 18, color: phase.color),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.milestone_phase,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phase.getLabel(lang),
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Suggested Age Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.info,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.milestone_suggested,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.ageRange,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedCapsuleCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required String lang,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;
    final formattedDate = milestone.completedAt != null
        ? DateFormat('d MMMM yyyy', lang).format(milestone.completedAt!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152219) : const Color(0xFFF0FAF3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLinkedCapsule(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.success,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.milestone_capsule_ready,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Actif',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formattedDate != null
                            ? 'Enregistré le $formattedDate'
                            : l10n.milestone_tap_to_open_memory,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12.5,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logEvent('milestone_capsule_cta_shown', parameters: {
        'milestone_id': milestone.milestone.id,
      });
    });

    return _AnimatedPressCard(
      onTap: () => _openCreateCapsule(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.magentaPink.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.milestone_capture_this_moment,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Photo, audio ou note dans la boîte à souvenirs',
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConseilBentoCard({
    required BuildContext context,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
    required Milestone m,
    required MilestoneCategory category,
  }) {
    final l10n = context.l10n;
    final advice = getMilestoneAdvice(m.id, category);
    final surfaceColor = isDark ? const Color(0xFF1E1A1E) : Colors.white;
    final borderColor = isDark ? AppColors.dividerDark : const Color(0xFFEBEBF0);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showConseilSheet(context, m),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lightbulb_rounded,
                      size: 22,
                      color: category.color,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.milestone_tips_and_photo_ideas,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        advice.explanation,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12.5,
                          height: 1.45,
                          color: secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Voir tous les conseils & idées photo',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: category.color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: category.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderBentoCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
    required MilestoneCategory category,
  }) {
    final l10n = context.l10n;
    final reminderAsync = ref.watch(
      milestoneReminderProvider((
        childId: childId,
        milestoneId: milestone.milestone.id,
      )),
    );

    return reminderAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, _) => const SizedBox.shrink(),
      data: (reminderDate) {
        final isSet = reminderDate != null;
        final accentColor = isSet ? AppColors.success : AppColors.info;
        final surfaceColor = isDark ? const Color(0xFF1E1A1E) : Colors.white;
        final borderColor = isDark ? AppColors.dividerDark : const Color(0xFFEBEBF0);

        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSet
                  ? AppColors.success.withValues(alpha: 0.35)
                  : borderColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showReminderSheet(context, ref, reminderDate),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          isSet
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          size: 22,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSet
                                ? l10n.milestone_reminder_on(
                                    _formatReminderDateTime(context, reminderDate),
                                  )
                                : l10n.milestone_schedule_reminder,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isSet ? AppColors.success : textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isSet
                                ? 'Appuyez pour modifier ou annuler le rappel'
                                : 'Recevoir une alerte au moment opportun',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12.5,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: secondaryText.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletionSection({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
  }) {
    final l10n = context.l10n;

    if (milestone.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_rounded,
              size: 20,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            Text(
              'Ce jalon a été complété avec succès 🎉',
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    // When not completed yet, show Mark as Complete button
    return _AnimatedPressCard(
      onTap: () => _markComplete(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 20,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.milestone_mark_complete,
              style: AppTypography.fromContext(
                context,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateCapsule(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CreateCapsuleScreen(milestoneId: milestone.milestone.id),
      ),
    );
  }

  void _openLinkedCapsule(BuildContext context, WidgetRef ref) {
    if (milestone.capsuleId == null) return;
    final capsules = ref.read(capsulesProvider).value ?? [];
    final capsule = capsules
        .where((c) => c.id == milestone.capsuleId)
        .firstOrNull;
    if (capsule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.milestone_capsule_not_found),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CapsuleDetailScreen(capsule: capsule)),
    );
  }

  void _showConseilSheet(BuildContext context, dynamic m) {
    final advice = getMilestoneAdvice(
      milestone.milestone.id,
      milestone.milestone.category,
    );

    AnalyticsService().logEvent(
      'milestone_advice_opened',
      parameters: {'milestone_id': milestone.milestone.id},
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConseilSheet(
        milestone: milestone,
        advice: advice,
      ),
    );
  }

  void _showReminderSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentReminder,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReminderSheet(
        milestone: milestone,
        childId: childId,
        currentReminder: currentReminder,
      ),
    );
  }

  void _markComplete(BuildContext context, WidgetRef ref) async {
    final service = ref.read(timelineServiceProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await service.completeMilestone(
        userId: uid,
        childId: childId,
        milestoneId: milestone.milestone.id,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.milestone_marked_complete),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.milestone_error('$e')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Lightweight micro-interaction press wrapper
class _AnimatedPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressCard({required this.child, required this.onTap});

  @override
  State<_AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<_AnimatedPressCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Bottom sheet showing explanation + photo tips for a milestone
class _ConseilSheet extends StatelessWidget {
  const _ConseilSheet({
    required this.milestone,
    required this.advice,
  });

  final MilestoneWithDueDate milestone;
  final MilestoneAdvice advice;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final categoryColor = milestone.milestone.category.color;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.lightbulb_rounded, color: categoryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.milestone_tips,
                            style: AppTypography.fromContext(context, 
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            milestone.milestone.getTitle(lang),
                            style: AppTypography.fromContext(context, 
                              fontSize: 13,
                              color: secondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: secondaryColor),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 32),
                  children: [
                    // Explanation section
                    _SectionTitle(
                      icon: Icons.info_outline_rounded,
                      label: l10n.milestone_understand_this,
                      color: categoryColor,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        advice.explanation,
                        style: AppTypography.fromContext(context, 
                          fontSize: 14,
                          height: 1.6,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Key points section (medical info, vaccine details, etc.)
                    if (advice.keyPoints.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: Icons.check_circle_outline_rounded,
                        label: l10n.milestone_key_points,
                        color: AppColors.info,
                      ),
                      const SizedBox(height: 10),
                      ...advice.keyPoints.map(
                        (point) => _KeyPointTile(
                          point: point,
                          textColor: textColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Photo tips section
                    _SectionTitle(
                      icon: Icons.camera_alt_rounded,
                      label: l10n.milestone_photo_ideas,
                      color: AppColors.magentaPink,
                    ),
                    const SizedBox(height: 10),
                    ...advice.photoTips.asMap().entries.map(
                      (entry) => _PhotoTipTile(
                        number: entry.key + 1,
                        tip: entry.value,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.fromContext(context, 
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PhotoTipTile extends StatelessWidget {
  const _PhotoTipTile({
    required this.number,
    required this.tip,
    required this.isDark,
    required this.textColor,
  });

  final int number;
  final String tip;
  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTypography.fromContext(context, 
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                tip,
                style: AppTypography.fromContext(context, 
                  fontSize: 14,
                  height: 1.5,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyPointTile extends StatelessWidget {
  const _KeyPointTile({
    required this.point,
    required this.textColor,
  });

  final String point;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_rounded,
              size: 18,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              point,
              style: AppTypography.fromContext(context, 
                fontSize: 14,
                height: 1.5,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to schedule, reschedule, or cancel a milestone reminder.
class _ReminderSheet extends ConsumerStatefulWidget {
  const _ReminderSheet({
    required this.milestone,
    required this.childId,
    required this.currentReminder,
  });

  final MilestoneWithDueDate milestone;
  final String childId;
  final DateTime? currentReminder;

  @override
  ConsumerState<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<_ReminderSheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final now = DateTime.now();

    final presets = <_ReminderPreset>[
      _ReminderPreset(
        label: l10n.milestone_reminder_tomorrow,
        subtitle: _formatPresetDateAtNine(
          context,
          DateTime(now.year, now.month, now.day + 1, 9),
        ),
        dateTime: DateTime(now.year, now.month, now.day + 1, 9),
      ),
      _ReminderPreset(
        label: l10n.milestone_reminder_in_3_days,
        subtitle: _formatPresetDateAtNine(
          context,
          DateTime(now.year, now.month, now.day + 3, 9),
        ),
        dateTime: DateTime(now.year, now.month, now.day + 3, 9),
      ),
      _ReminderPreset(
        label: l10n.milestone_reminder_in_1_week,
        subtitle: _formatPresetDateAtNine(
          context,
          DateTime(now.year, now.month, now.day + 7, 9),
        ),
        dateTime: DateTime(now.year, now.month, now.day + 7, 9),
      ),
      if (widget.milestone.dueDate != null &&
          widget.milestone.dueDate!.isAfter(now))
        _ReminderPreset(
          label: l10n.milestone_reminder_on_milestone_day,
          subtitle: _formatPresetDateAtNine(
            context,
            DateTime(
              widget.milestone.dueDate!.year,
              widget.milestone.dueDate!.month,
              widget.milestone.dueDate!.day,
              9,
            ),
          ),
          dateTime: DateTime(
            widget.milestone.dueDate!.year,
            widget.milestone.dueDate!.month,
            widget.milestone.dueDate!.day,
            9,
          ),
        ),
    ];

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.milestone_schedule_reminder,
                      style: AppTypography.fromContext(context, 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      widget.milestone.milestone.getTitle(lang),
                      style: AppTypography.fromContext(context, 
                        fontSize: 13,
                        color: secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: secondaryColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...presets.map(
            (p) => _ReminderTile(
              label: p.label,
              subtitle: p.subtitle,
              icon: Icons.schedule_rounded,
              isDark: isDark,
              onTap: _busy ? null : () => _schedule(p.dateTime),
            ),
          ),
          _ReminderTile(
            label: l10n.milestone_reminder_choose_date_time,
            subtitle: l10n.milestone_reminder_manual_selection,
            icon: Icons.edit_calendar_rounded,
            isDark: isDark,
            onTap: _busy ? null : _pickCustomDateTime,
          ),
          if (widget.currentReminder != null) ...[
            const SizedBox(height: 8),
            _ReminderTile(
              label: l10n.milestone_reminder_cancel,
              subtitle: l10n.milestone_reminder_cancel_subtitle,
              icon: Icons.notifications_off_rounded,
              isDark: isDark,
              destructive: true,
              onTap: _busy ? null : _cancelReminder,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickCustomDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;

    final scheduledFor = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await _schedule(scheduledFor);
  }

  Future<void> _schedule(DateTime scheduledFor) async {
    if (scheduledFor.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.milestone_reminder_future_date_required),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final prefsEnabled = ref.read(notificationPrefsProvider).milestone;
    if (!prefsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.milestone_reminder_enable_notifications),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final children = await ref.read(childrenProvider.future);
      final child = children.where((c) => c.id == widget.childId).firstOrNull;
      if (child == null) return;

      final service = ref.read(milestoneNotificationServiceProvider);
      await service.scheduleCustomReminder(
        child: child,
        milestone: widget.milestone,
        scheduledFor: scheduledFor,
      );

      AnalyticsService().logEvent(
        'milestone_reminder_set',
        parameters: {
          'milestone_id': widget.milestone.milestone.id,
          'scheduled_for': scheduledFor.toIso8601String(),
        },
      );

      ref.invalidate(
        milestoneReminderProvider((
          childId: widget.childId,
          milestoneId: widget.milestone.milestone.id,
        )),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.milestone_reminder_scheduled(
                _formatReminderDateTime(context, scheduledFor),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelReminder() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(milestoneNotificationServiceProvider);
      await service.cancelCustomReminder(
        childId: widget.childId,
        milestoneId: widget.milestone.milestone.id,
      );

      ref.invalidate(
        milestoneReminderProvider((
          childId: widget.childId,
          milestoneId: widget.milestone.milestone.id,
        )),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.milestone_reminder_cancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ReminderPreset {
  const _ReminderPreset({
    required this.label,
    required this.subtitle,
    required this.dateTime,
  });

  final String label;
  final String subtitle;
  final DateTime dateTime;
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.info;
    final textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.fromContext(context, 
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.fromContext(context, 
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: secondaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
