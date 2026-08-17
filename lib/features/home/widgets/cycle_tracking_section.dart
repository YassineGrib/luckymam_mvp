import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/profile_screen.dart';

/// Visual cycle tracker section for the dashboard.
class CycleTrackingSection extends ConsumerStatefulWidget {
  const CycleTrackingSection({super.key});

  @override
  ConsumerState<CycleTrackingSection> createState() =>
      _CycleTrackingSectionState();
}

class _CycleTrackingSectionState extends ConsumerState<CycleTrackingSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, st) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final cycleInfo = profile.cycleInfo;
        final isPregnant = profile.status == UserStatus.pregnant;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: GestureDetector(
            onTap: () {
              final expanding = !_isExpanded;
              setState(() {
                _isExpanded = expanding;
              });
              if (expanding && isPregnant) {
                AnalyticsService().logEvent('pregnancy_panel_viewed');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, isPregnant, cycleInfo),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isExpanded
                          ? _buildExpandedContent(
                              context,
                              profile,
                              isPregnant,
                              cycleInfo,
                            )
                          : const SizedBox(width: double.infinity, height: 0),
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

  // ── Pregnancy helpers ────────────────────────────────────────────────────────

  int _pregnancyWeek(DateTime lmp) =>
      DateTime.now().difference(lmp).inDays ~/ 7;

  DateTime _dpa(DateTime lmp) => lmp.add(const Duration(days: 280));

  int _daysUntilDpa(DateTime lmp) =>
      _dpa(lmp).difference(DateTime.now()).inDays;

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    bool isPregnant,
    CycleInfo cycleInfo,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    IconData icon = Icons.water_drop_rounded;
    
    String title = lang == 'ar'
        ? 'متابعة الدورة'
        : lang == 'en'
            ? 'Cycle Tracking'
            : 'Suivi du Cycle';

    String subtitle = lang == 'ar'
        ? 'تفعيل المتابعة'
        : lang == 'en'
            ? 'Activate tracking'
            : 'Activer le suivi';

    if (isPregnant) {
      icon = Icons.pregnant_woman_rounded;
      title = lang == 'ar'
          ? 'حملي'
          : lang == 'en'
              ? 'My Pregnancy'
              : 'Ma Grossesse';
      final lmp = cycleInfo.lastPeriodDate;
      if (lmp != null) {
        final week = _pregnancyWeek(lmp);
        final daysLeft = _daysUntilDpa(lmp);
        subtitle = lang == 'ar'
            ? 'الأسبوع $week · الولادة المتوقعة خلال $daysLeft يوم'
            : lang == 'en'
                ? 'Week $week · Due in $daysLeft days'
                : 'Semaine $week · DPA dans $daysLeft j';
      } else {
        subtitle = lang == 'ar'
            ? 'تحديد تاريخ بداية الحمل'
            : lang == 'en'
                ? 'Enter my start date'
                : 'Renseigner ma date de début';
      }
    } else if (cycleInfo.isTracking && cycleInfo.lastPeriodDate != null) {
      final phase = cycleInfo.currentPhase;
      final phaseTranslated = lang == 'ar'
          ? (phase == 'Menstruation'
              ? 'الحيض'
              : phase == 'Folliculaire'
                  ? 'الطور الجريبي'
                  : phase == 'Ovulation'
                      ? 'التبويض'
                      : phase == 'Lutéale'
                          ? 'الطور الأصفري'
                          : phase)
          : lang == 'en'
              ? (phase == 'Menstruation'
                  ? 'Menstruation'
                  : phase == 'Folliculaire'
                      ? 'Follicular'
                      : phase == 'Ovulation'
                          ? 'Ovulation'
                          : phase == 'Lutéale'
                              ? 'Luteal'
                              : phase)
              : phase;
      subtitle = lang == 'ar'
          ? 'اليوم ${cycleInfo.currentDay} · $phaseTranslated'
          : lang == 'en'
              ? 'Day ${cycleInfo.currentDay} · $phaseTranslated'
              : 'Jour ${cycleInfo.currentDay} · $phaseTranslated';
    }

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: _isExpanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    UserProfile profile,
    bool isPregnant,
    CycleInfo cycleInfo,
  ) {
    if (isPregnant) {
      return _buildPregnancyContent(context, cycleInfo);
    }

    if (!cycleInfo.isTracking || cycleInfo.lastPeriodDate == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(color: Colors.white.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.magentaPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Configurer mon cycle',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // Active tracking
    final progress = cycleInfo.currentDay / cycleInfo.cycleLength;
    final nextPeriod = cycleInfo.nextPeriodDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? 'يوم'
                            : Localizations.localeOf(context).languageCode == 'en'
                                ? 'Day'
                                : 'Jour',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${cycleInfo.currentDay}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPhaseDescription(cycleInfo.currentPhase, Localizations.localeOf(context).languageCode),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                    if (nextPeriod != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'الحيض خلال ${nextPeriod.difference(DateTime.now()).inDays} يوم'
                              : Localizations.localeOf(context).languageCode == 'en'
                                  ? 'Period in ${nextPeriod.difference(DateTime.now()).inDays} days'
                                  : 'Règles dans ${nextPeriod.difference(DateTime.now()).inDays} j',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _logPeriod(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.magentaPink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تسجيل دورتي الشهرية'
                  : Localizations.localeOf(context).languageCode == 'en'
                      ? 'Log my period'
                      : 'Enregistrer mes règles',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyContent(BuildContext context, CycleInfo cycleInfo) {
    final lmp = cycleInfo.lastPeriodDate;
    final lang = Localizations.localeOf(context).languageCode;

    if (lmp == null) {
      // No DDR set — prompt user
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(color: Colors.white.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 16),
            Text(
              lang == 'ar'
                  ? 'سجّلي تاريخ آخر دورة شهرية (DDR)\nلمتابعة حملك أسبوعًا بأسبوع.'
                  : lang == 'en'
                      ? 'Enter your last menstrual period (LMP) date\nto track your pregnancy week by week.'
                      : 'Renseignez votre date de dernières règles (DDR)\npour suivre votre grossesse semaine par semaine.',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _enterLmp(context),
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(
                lang == 'ar'
                    ? 'إدخال تاريخ آخر دورة'
                    : lang == 'en'
                        ? 'Enter my LMP'
                        : 'Entrer ma DDR',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.magentaPink,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final week = _pregnancyWeek(lmp);
    final dpa = _dpa(lmp);
    final daysLeft = _daysUntilDpa(lmp);
    final dpaLabel =
        '${dpa.day.toString().padLeft(2, '0')}/${dpa.month.toString().padLeft(2, '0')}/${dpa.year}';
    final progress = (week / 40).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              // Week ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang == 'ar'
                            ? 'أسبوع'
                            : lang == 'en'
                                ? 'Weeks'
                                : 'SA',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '$week',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'ar'
                          ? 'الأسبوع $week / 40'
                          : lang == 'en'
                              ? 'Week $week / 40'
                              : 'Semaine $week / 40',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang == 'ar'
                            ? 'تاريخ الولادة المتوقع: $dpaLabel'
                            : lang == 'en'
                                ? 'Due Date: $dpaLabel'
                                : 'DPA : $dpaLabel',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang == 'ar'
                            ? 'باقي $daysLeft يوم على الولادة'
                            : lang == 'en'
                                ? '$daysLeft days left until delivery'
                                : 'J−$daysLeft avant l\'accouchement',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => _enterLmp(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(
              lang == 'ar'
                  ? 'تعديل تاريخ آخر دورة'
                  : lang == 'en'
                      ? 'Modify my LMP'
                      : 'Modifier ma DDR',
              style: GoogleFonts.outfit(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _enterLmp(BuildContext context) async {
    final now = DateTime.now();
    final lang = Localizations.localeOf(context).languageCode;
    final date = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 70)),
      firstDate: now.subtract(const Duration(days: 280)),
      lastDate: now,
      helpText: lang == 'ar'
          ? 'تاريخ آخر دورة شهرية (DDR)'
          : lang == 'en'
              ? 'Last menstrual period date (LMP)'
              : 'Date de dernières règles (DDR)',
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

    if (date != null && mounted) {
      await ref.read(profileActionsProvider.notifier).savePregnancyLmp(date);
      AnalyticsService().logEvent('lmp_saved');
      final lmp = date;
      final dpa = lmp.add(const Duration(days: 280));
      AnalyticsService().logEvent('edd_computed', parameters: {
        'edd': dpa.toIso8601String(),
        'week': DateTime.now().difference(lmp).inDays ~/ 7,
      });
    }
  }

  String _getPhaseDescription(String phase, String lang) {
    if (lang == 'ar') {
      switch (phase) {
        case 'Règles':
        case 'Menstruation':
          return 'تبدأ دورتكِ الآن. اعتني بنفسكِ.';
        case 'Phase Folliculaire':
        case 'Folliculaire':
          return 'يستعد جسمكِ الآن. تشعرين بنشاط أكبر.';
        case 'Phase Ovulatoire':
        case 'Ovulation':
          return 'فترة الخصوبة القصوى.';
        case 'Phase Lutéale':
        case 'Lutéale':
          return 'الاستعداد للدورة القادمة.';
        default:
          return 'تطور دورتكِ النسائية.';
      }
    } else if (lang == 'en') {
      switch (phase) {
        case 'Règles':
        case 'Menstruation':
          return 'Your cycle begins. Take care of yourself.';
        case 'Phase Folliculaire':
        case 'Folliculaire':
          return 'Your body is preparing. You feel more energetic.';
        case 'Phase Ovulatoire':
        case 'Ovulation':
          return 'Peak fertility period.';
        case 'Phase Lutéale':
        case 'Lutéale':
          return 'Preparation for the next cycle.';
        default:
          return 'Evolution of your cycle.';
      }
    } else {
      switch (phase) {
        case 'Règles':
        case 'Menstruation':
          return 'Votre cycle commence. Prenez soin de vous.';
        case 'Phase Folliculaire':
        case 'Folliculaire':
          return 'Votre corps se prépare. Vous vous sentez plus énergique.';
        case 'Phase Ovulatoire':
        case 'Ovulation':
          return 'Période de fertilité maximale.';
        case 'Phase Lutéale':
        case 'Lutéale':
          return 'Préparation pour le prochain cycle.';
        default:
          return 'Évolution de votre cycle féminin.';
      }
    }
  }

  void _logPeriod(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
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

    if (date != null) {
      await ref.read(profileActionsProvider.notifier).logPeriodStart(date);
    }
  }
}
