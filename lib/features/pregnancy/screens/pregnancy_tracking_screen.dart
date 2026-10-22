import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/medical_disclaimer_banner.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../home/data/home_tips_data.dart';
import '../../profile/models/pregnancy.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';

/// Dedicated pregnancy tracking screen showing gestational age,
/// trimester, countdown to delivery (EDD/DPA), weekly advice, and LMP settings.
class PregnancyTrackingScreen extends ConsumerWidget {
  const PregnancyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final activePregnancy = ref.watch(activePregnancyProvider);
    final profile = ref.watch(profileProvider).valueOrNull;

    final now = DateTime.now();
    DateTime? lmp = activePregnancy?.lmpDate ?? profile?.lastPregnancyDate ?? profile?.cycleInfo.lastPeriodDate;
    DateTime edd = activePregnancy?.eddDate ??
        (lmp != null ? Pregnancy.eddFromLmp(lmp) : now.add(const Duration(days: 210)));

    final week = activePregnancy?.gestationalWeek(now) ??
        (lmp != null ? (now.difference(lmp).inDays ~/ 7).clamp(0, 42) : 10);
    final day = activePregnancy?.gestationalDay(now) ??
        (lmp != null ? (now.difference(lmp).inDays % 7).clamp(0, 6) : 0);
    final daysUntilDue = activePregnancy?.daysUntilDue(now) ??
        DateTime(edd.year, edd.month, edd.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    final trimester = activePregnancy?.trimester(now) ??
        (week < 14 ? 1 : (week < 28 ? 2 : 3));

    final title = isAr ? 'متابعة الحمل' : (isFr ? 'Suivi de grossesse' : 'Pregnancy Tracking');
    final subtitle = isAr ? 'رحلة الأمومة أسبوعاً بأسبوع' : (isFr ? 'Mon parcours semaine par semaine' : 'Week by week journey');

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 420),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header Bar ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.screenPaddingH,
                      AppSpacing.md,
                      AppSpacing.screenPaddingH,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: primary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: secondaryText),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pregnant_woman_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Hero Gestational Week Card ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _buildGestationalCard(
                      context,
                      isDark: isDark,
                      week: week,
                      day: day,
                      trimester: trimester,
                      lang: lang,
                    ),
                  ),
                ),

                // ── Due Date & Countdown Bento Card ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _buildCountdownCard(
                      context,
                      ref,
                      isDark: isDark,
                      edd: edd,
                      lmp: lmp,
                      daysUntilDue: daysUntilDue,
                      lang: lang,
                      activePregnancy: activePregnancy,
                    ),
                  ),
                ),

                // ── Weekly Tip / Advice Card ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _buildAdviceCard(
                      context,
                      isDark: isDark,
                      lang: lang,
                      week: week,
                    ),
                  ),
                ),

                // ── Medical Disclaimer ──────────────────────────────────────
                const SliverToBoxAdapter(
                  child: MedicalDisclaimerBanner(compact: false),
                ),

                // ── Manage / End Pregnancy Action ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: _buildManageButton(
                      context,
                      ref,
                      isDark: isDark,
                      lang: lang,
                      activePregnancy: activePregnancy,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestationalCard(
    BuildContext context, {
    required bool isDark,
    required int week,
    required int day,
    required int trimester,
    required String lang,
  }) {
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final trimesterText = isAr
        ? (trimester == 1
            ? 'الثلث الأول'
            : (trimester == 2 ? 'الثلث الثاني' : 'الثلث الثالث'))
        : (isFr
            ? '$trimester${trimester == 1 ? 'er' : 'ème'} trimestre'
            : '$trimester${trimester == 1 ? 'st' : (trimester == 2 ? 'nd' : 'rd')} trimester');

    final weekLabel = isAr ? 'الأسبوع $week' : (isFr ? 'Semaine $week' : 'Week $week');
    final dayLabel = day > 0
        ? (isAr ? '+ $day أيام' : (isFr ? '+ $day j' : '+ $day d'))
        : '';

    final progressRatio = (week / 40.0).clamp(0.05, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF2C1D2C), Color(0xFF221A2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFF0F5), Color(0xFFF3E8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.90),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFFE8D5F0).withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.magentaPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  trimesterText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.magentaPink,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: AppColors.magentaPink,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(progressRatio * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF4A354F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                weekLabel,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF26182B),
                  letterSpacing: -0.5,
                ),
              ),
              if (dayLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.magentaPink,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white,
              valueColor: const AlwaysStoppedAnimation(AppColors.magentaPink),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'البداية' : (isFr ? 'Début' : 'Start'),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : const Color(0xFF7A6B80),
                ),
              ),
              Text(
                isAr ? '40 أسبوعاً' : (isFr ? '40 semaines' : '40 weeks'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF4A354F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    WidgetRef ref, {
    required bool isDark,
    required DateTime edd,
    required DateTime? lmp,
    required int daysUntilDue,
    required String lang,
    required Pregnancy? activePregnancy,
  }) {
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final daysLabel = daysUntilDue >= 0
        ? (isAr ? 'متبقي $daysUntilDue يوماً' : (isFr ? 'Encore $daysUntilDue jours' : '$daysUntilDue days left'))
        : (isAr ? 'تجاوزت الموعد بـ ${-daysUntilDue} يوماً' : (isFr ? 'Dépassé de ${-daysUntilDue} jours' : 'Overdue by ${-daysUntilDue} days'));

    final eddStr = '${edd.day}/${edd.month}/${edd.year}';
    final lmpStr = lmp != null ? '${lmp.day}/${lmp.month}/${lmp.year}' : '--/--/----';

    final dueTitle = isAr ? 'موعد الولادة المتوقع' : (isFr ? 'Date d\'accouchement prévue' : 'Estimated Due Date');
    final lmpTitle = isAr ? 'تاريخ آخر دورة (DDR)' : (isFr ? 'Date des dernières règles (DDR)' : 'Last Menstrual Period (LMP)');
    final editButtonText = isAr ? 'تعديل التاريخ' : (isFr ? 'Modifier la date' : 'Edit date');

    final cardBg = isDark ? const Color(0xFF231F2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF241C2B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEADBEE),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dueTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF706277),
                      ),
                    ),
                    Text(
                      eddStr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  daysLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coral,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lmpTitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF706277),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lmpStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _pickNewLmp(context, ref, lmp, activePregnancy),
                icon: const Icon(Icons.edit_calendar_rounded, size: 15),
                label: Text(editButtonText),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.magentaPink,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(
    BuildContext context, {
    required bool isDark,
    required String lang,
    required int week,
  }) {
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final adviceTitle = isAr ? 'نصيحة الأسبوع' : (isFr ? 'Conseil de la semaine' : 'Tip of the week');
    final tip = HomeTipsData.tipFor(lang, UserStatus.pregnant);

    final cardBg = isDark ? const Color(0xFF231F2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF241C2B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEADBEE),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldenrod.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.goldenrod,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adviceTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: isDark ? Colors.white70 : const Color(0xFF5A4D60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(
    BuildContext context,
    WidgetRef ref, {
    required bool isDark,
    required String lang,
    required Pregnancy? activePregnancy,
  }) {
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final endTitle = isAr ? 'إنهاء أو إلغاء متابعة الحمل' : (isFr ? 'Terminer ou annuler le suivi' : 'End or cancel tracking');

    return Center(
      child: OutlinedButton.icon(
        onPressed: () => _confirmEndPregnancy(context, ref, activePregnancy, lang),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
        label: Text(endTitle),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white70 : const Color(0xFF6B5872),
          side: BorderSide(
            color: isDark ? Colors.white24 : const Color(0xFFD6C8DD),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Future<void> _pickNewLmp(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentLmp,
    Pregnancy? activePregnancy,
  ) async {
    final defaultName = context.l10n.childExpectedDefaultName;
    final helpText = context.l10n.cycleLmpDatePickerHelp;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentLmp ?? now.subtract(const Duration(days: 70)),
      firstDate: now.subtract(const Duration(days: 280)),
      lastDate: now,
      helpText: helpText,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.magentaPink,
              primary: AppColors.magentaPink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final profileService = ref.read(profileServiceProvider);

      if (activePregnancy != null) {
        // If active pregnancy already exists, end or update it:
        await profileService.endPregnancy(activePregnancy.id, keepMemories: false);
      }
      await profileService.declarePregnancy(
        lmpDate: picked,
        placeholderName: defaultName,
      );
    }
  }

  Future<void> _confirmEndPregnancy(
    BuildContext context,
    WidgetRef ref,
    Pregnancy? activePregnancy,
    String lang,
  ) async {
    if (activePregnancy == null) {
      Navigator.of(context).pop();
      return;
    }

    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final title = isAr ? 'إنهاء متابعة الحمل' : (isFr ? 'Terminer le suivi' : 'End tracking');
    final content = isAr
        ? 'هل ترغبين في إنهاء المتابعة وحفظ السجل في الذكريات، أم إلغاء وحذف هذا الحمل (إذا تم اختياره بالخطأ)؟'
        : (isFr
            ? 'Souhaitez-vous archiver ce suivi dans vos souvenirs ou annuler et supprimer le suivi ?'
            : 'Would you like to archive this tracking in your memories, or cancel and delete it?');
    final cancelLabel = isAr ? 'تراجع' : (isFr ? 'Annuler' : 'Cancel');
    final deleteLabel = isAr ? 'إلغاء وحذف' : (isFr ? 'Annuler et supprimer' : 'Cancel & delete');
    final archiveLabel = isAr ? 'حفظ في الذكريات' : (isFr ? 'Garder en souvenirs' : 'Keep in memories');

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'dismiss'),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'archive'),
            child: Text(archiveLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(deleteLabel),
          ),
        ],
      ),
    );

    if (choice != null && choice != 'dismiss') {
      final keepMemories = choice == 'archive';
      await ref.read(profileServiceProvider).endPregnancy(
            activePregnancy.id,
            keepMemories: keepMemories,
          );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
