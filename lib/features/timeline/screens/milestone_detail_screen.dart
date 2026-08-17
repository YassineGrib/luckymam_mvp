import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../notifications/notifications_screen.dart' show notificationPrefsProvider;
import '../../profile/providers/profile_providers.dart';
import '../data/milestone_advice_data.dart';
import '../models/phase.dart';
import '../services/milestone_notification_service.dart';
import '../services/timeline_service.dart';

/// Detail screen for a single milestone
class MilestoneDetailScreen extends ConsumerWidget {
  final MilestoneWithDueDate milestone;
  final String childId;

  const MilestoneDetailScreen({
    super.key,
    required this.milestone,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.onBackgroundDark
        : AppColors.onBackgroundLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final m = milestone.milestone;
    final category = m.category;
    final phase = m.phase;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Hero header with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: category.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.color, category.color.withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(category.icon, size: 60, color: Colors.white),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category.getLabel(lang),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    m.getTitle(lang),
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    m.getDescription(lang),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: phase.icon,
                          label: lang == 'ar' ? 'المرحلة' : lang == 'en' ? 'Phase' : 'Phase',
                          value: phase.getLabel(lang),
                          color: phase.color,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.calendar_today_rounded,
                          label: lang == 'ar' ? 'مقترح' : lang == 'en' ? 'Suggested' : 'Suggéré',
                          value: m.ageRange,
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Capsule liée — bouton pour lire
                  if (milestone.capsuleId != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.photo_camera_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lang == 'ar'
                              ? 'الكبسولة جاهزة'
                              : lang == 'en'
                                  ? 'Capsule created'
                                  : 'Capsule réalisée',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (milestone.completedAt != null) ...[
                          const Spacer(),
                          Text(
                            DateFormat(
                              'd MMM yyyy',
                              lang,
                            ).format(milestone.completedAt!),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => _openLinkedCapsule(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                              child: const Icon(
                                Icons.play_circle_rounded,
                                color: AppColors.success,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang == 'ar'
                                        ? 'عرض الكبسولة'
                                        : lang == 'en'
                                            ? 'View Capsule'
                                            : 'Voir la capsule',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    lang == 'ar'
                                        ? 'اضغطي لفتح الذكرى'
                                        : lang == 'en'
                                            ? 'Tap to open the memory'
                                            : 'Appuyez pour ouvrir le souvenir',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.success.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Action buttons
                  if (m.canHaveCapsule && milestone.capsuleId == null)
                    _buildCaptureButton(context),

                  const SizedBox(height: AppSpacing.md),

                  // Conseil button
                  _buildConseilButton(context, m),

                  const SizedBox(height: AppSpacing.md),

                  // Reminder button
                  _buildReminderButton(context, ref),

                  const SizedBox(height: AppSpacing.md),

                  // Secondary actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          context,
                          ref,
                          icon: Icons.check_rounded,
                           label: lang == 'ar'
                              ? 'تحديد كمكتمل'
                              : lang == 'en'
                                  ? 'Mark complete'
                                  : 'Marquer terminé',
                          onTap: () => _markComplete(context, ref),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildSecondaryButton(
                          context,
                          ref,
                          icon: Icons.close_rounded,
                          label: lang == 'ar' ? 'إغلاق' : lang == 'en' ? 'Close' : 'Fermer',
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.onSurfaceDark
                  : AppColors.onSurfaceLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    // Fire once when the CTA is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logEvent('milestone_capsule_cta_shown', parameters: {
        'milestone_id': milestone.milestone.id,
      });
    });

    return GestureDetector(
      onTap: () => _openCreateCapsule(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.magentaPink.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              lang == 'ar'
                  ? 'توثيق هذه اللحظة'
                  : lang == 'en'
                      ? 'Capture this moment'
                      : 'Capturer ce moment',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
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
      final lang = Localizations.localeOf(context).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'الكبسولة غير موجودة'
                : lang == 'en'
                    ? 'Capsule not found'
                    : 'Capsule introuvable',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CapsuleDetailScreen(capsule: capsule)),
    );
  }

  Widget _buildConseilButton(BuildContext context, dynamic m) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showConseilSheet(context, m),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: milestone.milestone.category.color.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_rounded,
              size: 20,
              color: milestone.milestone.category.color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'نصائح وأفكار للصور'
                  : Localizations.localeOf(context).languageCode == 'en'
                      ? 'Tips & photo ideas'
                      : 'Conseils & idées photo',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: milestone.milestone.category.color,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildReminderButton(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        final color = isSet ? AppColors.success : AppColors.info;

        return GestureDetector(
          onTap: () => _showReminderSheet(context, ref, reminderDate),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSet
                  ? AppColors.success.withValues(alpha: 0.08)
                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSet
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    isSet
                        ? (lang == 'ar'
                            ? 'تذكير في ${DateFormat('d MMM في HH:mm', 'ar').format(reminderDate)}'
                            : lang == 'en'
                                ? 'Reminder on ${DateFormat('d MMM at HH:mm', 'en').format(reminderDate)}'
                                : 'Rappel le ${DateFormat('d MMM à HH:mm', 'fr_FR').format(reminderDate)}')
                        : (lang == 'ar'
                            ? 'برمجة تذكير'
                            : lang == 'en'
                                ? 'Schedule a reminder'
                                : 'Programmer un rappel'),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        final lang = Localizations.localeOf(context).languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? 'تم تحديد الجالون كمكتمل ✓'
                  : lang == 'en'
                      ? 'Milestone marked as complete ✓'
                      : 'Jalon marqué comme terminé ✓',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        final lang = Localizations.localeOf(context).languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? 'خطأ: $e'
                  : lang == 'en'
                      ? 'Error: $e'
                      : 'Erreur : $e',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                            lang == 'ar'
                                ? 'نصائح'
                                : lang == 'en'
                                    ? 'Tips'
                                    : 'Conseils',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            milestone.milestone.getTitle(lang),
                            style: GoogleFonts.outfit(
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    // Explanation section
                    _SectionTitle(
                      icon: Icons.info_outline_rounded,
                      label: lang == 'ar'
                          ? 'فهم هذا الجالون'
                          : lang == 'en'
                              ? 'Understand this milestone'
                              : 'Comprendre ce jalon',
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
                        style: GoogleFonts.outfit(
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
                        label: lang == 'ar'
                            ? 'نقاط هامة'
                            : lang == 'en'
                                ? 'Key Points'
                                : 'À retenir',
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
                      label: lang == 'ar'
                          ? 'أفكار للصور'
                          : lang == 'en'
                              ? 'Photo Ideas'
                              : 'Idées pour la photo',
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
          style: GoogleFonts.outfit(
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
                style: GoogleFonts.outfit(
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
                style: GoogleFonts.outfit(
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
              style: GoogleFonts.outfit(
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
        label: lang == 'ar'
            ? 'غداً'
            : lang == 'en'
                ? 'Tomorrow'
                : 'Demain',
        subtitle: DateFormat(
          lang == 'ar'
              ? 'd MMM في 09:00'
              : lang == 'en'
                  ? 'd MMM at 09:00'
                  : 'd MMM à 09:00',
          lang,
        ).format(DateTime(now.year, now.month, now.day + 1, 9)),
        dateTime: DateTime(now.year, now.month, now.day + 1, 9),
      ),
      _ReminderPreset(
        label: lang == 'ar'
            ? 'خلال 3 أيام'
            : lang == 'en'
                ? 'In 3 days'
                : 'Dans 3 jours',
        subtitle: DateFormat(
          lang == 'ar'
              ? 'd MMM في 09:00'
              : lang == 'en'
                  ? 'd MMM at 09:00'
                  : 'd MMM à 09:00',
          lang,
        ).format(DateTime(now.year, now.month, now.day + 3, 9)),
        dateTime: DateTime(now.year, now.month, now.day + 3, 9),
      ),
      _ReminderPreset(
        label: lang == 'ar'
            ? 'خلال أسبوع'
            : lang == 'en'
                ? 'In 1 week'
                : 'Dans 1 semaine',
        subtitle: DateFormat(
          lang == 'ar'
              ? 'd MMM في 09:00'
              : lang == 'en'
                  ? 'd MMM at 09:00'
                  : 'd MMM à 09:00',
          lang,
        ).format(DateTime(now.year, now.month, now.day + 7, 9)),
        dateTime: DateTime(now.year, now.month, now.day + 7, 9),
      ),
      if (widget.milestone.dueDate != null &&
          widget.milestone.dueDate!.isAfter(now))
        _ReminderPreset(
          label: lang == 'ar'
              ? 'يوم الجالون'
              : lang == 'en'
                  ? 'On milestone day'
                  : 'Le jour du jalon',
          subtitle: DateFormat(
            lang == 'ar'
                ? 'd MMM في 09:00'
                : lang == 'en'
                    ? 'd MMM at 09:00'
                    : 'd MMM à 09:00',
            lang,
          ).format(widget.milestone.dueDate!),
          dateTime: DateTime(
            widget.milestone.dueDate!.year,
            widget.milestone.dueDate!.month,
            widget.milestone.dueDate!.day,
            9,
          ),
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                      lang == 'ar'
                          ? 'برمجة تذكير'
                          : lang == 'en'
                              ? 'Schedule a reminder'
                              : 'Programmer un rappel',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      widget.milestone.milestone.getTitle(lang),
                      style: GoogleFonts.outfit(
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
            label: lang == 'ar'
                ? 'اختيار تاريخ ووقت'
                : lang == 'en'
                    ? 'Choose date & time'
                    : 'Choisir une date et heure',
            subtitle: lang == 'ar'
                ? 'تحديد يدوي'
                : lang == 'en'
                    ? 'Manual selection'
                    : 'Sélection manuelle',
            icon: Icons.edit_calendar_rounded,
            isDark: isDark,
            onTap: _busy ? null : _pickCustomDateTime,
          ),
          if (widget.currentReminder != null) ...[
            const SizedBox(height: 8),
            _ReminderTile(
              label: lang == 'ar'
                  ? 'إلغاء التذكير'
                  : lang == 'en'
                      ? 'Cancel reminder'
                      : 'Annuler le rappel',
              subtitle: lang == 'ar'
                  ? 'حذف التذكير المبرمج'
                  : lang == 'en'
                      ? 'Delete the scheduled reminder'
                      : 'Supprimer le rappel programmé',
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
      final lang = Localizations.localeOf(context).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'يرجى اختيار تاريخ في المستقبل'
                : lang == 'en'
                    ? 'Choose a date in the future'
                    : 'Choisissez une date dans le futur',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final prefsEnabled = ref.read(notificationPrefsProvider).milestone;
    if (!prefsEnabled) {
      final lang = Localizations.localeOf(context).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'يرجى تفعيل تنبيهات الجالونات في الإعدادات > الإشعارات'
                : lang == 'en'
                    ? 'Enable milestone notifications in Settings > Notifications'
                    : 'Activez les notifications de jalons dans Paramètres > Notifications',
          ),
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
        final lang = Localizations.localeOf(context).languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? 'تمت برمجة التذكير في ${DateFormat('d MMM في HH:mm', 'ar').format(scheduledFor)} ✓'
                  : lang == 'en'
                      ? 'Reminder scheduled for ${DateFormat('d MMM at HH:mm', 'en').format(scheduledFor)} ✓'
                      : 'Rappel programmé le ${DateFormat('d MMM à HH:mm', 'fr_FR').format(scheduledFor)} ✓',
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
        final lang = Localizations.localeOf(context).languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? 'تم إلغاء التذكير'
                  : lang == 'en'
                      ? 'Reminder cancelled'
                      : 'Rappel annulé',
            ),
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
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
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
