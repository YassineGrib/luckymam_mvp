import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/profile_screen.dart';
import '../../profile/providers/profile_providers.dart';

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
              setState(() => _isExpanded = expanding);
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

  int _pregnancyWeek(DateTime lmp) =>
      DateTime.now().difference(lmp).inDays ~/ 7;

  DateTime _dpa(DateTime lmp) => lmp.add(const Duration(days: 280));

  int _daysUntilDpa(DateTime lmp) =>
      _dpa(lmp).difference(DateTime.now()).inDays;

  Widget _buildHeader(
    BuildContext context,
    bool isPregnant,
    CycleInfo cycleInfo,
  ) {
    final l10n = context.l10n;
    var icon = Icons.water_drop_rounded;
    var title = l10n.cycleTrackingTitle;
    var subtitle = l10n.cycleActivateTracking;

    if (isPregnant) {
      icon = Icons.pregnant_woman_rounded;
      title = l10n.dashboardHealthPregnancy;
      final lmp = cycleInfo.lastPeriodDate;
      if (lmp != null) {
        subtitle = l10n.cyclePregnancySubtitleWeekDays(
          _pregnancyWeek(lmp),
          _daysUntilDpa(lmp),
        );
      } else {
        subtitle = l10n.cycleEnterPregnancyStart;
      }
    } else if (cycleInfo.isTracking && cycleInfo.lastPeriodDate != null) {
      subtitle = l10n.cycleDayPhase(
        cycleInfo.currentDay,
        _phaseLabel(l10n, cycleInfo.currentPhase),
      );
    }

    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.8),
      fontSize: 11,
    );

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
                Text(title, style: labelStyle),
                Text(subtitle, style: subtitleStyle),
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

    final l10n = context.l10n;

    if (!cycleInfo.isTracking || cycleInfo.lastPeriodDate == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 18),
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
              child: Text(l10n.cycleConfigure),
            ),
          ],
        ),
      );
    }

    final progress = cycleInfo.currentDay / cycleInfo.cycleLength;
    final nextPeriod = cycleInfo.nextPeriodDate;
    final whiteBold = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 18),
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
                        l10n.cycleDayLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text('${cycleInfo.currentDay}', style: whiteBold),
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
                      _phaseDescription(l10n, cycleInfo.currentPhase),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          l10n.cyclePeriodInDays(
                            nextPeriod.difference(DateTime.now()).inDays,
                          ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: Colors.white, fontSize: 11),
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
            child: Text(l10n.cycleLogPeriod),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyContent(BuildContext context, CycleInfo cycleInfo) {
    final l10n = context.l10n;
    final lmp = cycleInfo.lastPeriodDate;

    if (lmp == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(color: Colors.white.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 16),
            Text(
              l10n.cycleLmpPrompt,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _enterLmp(context),
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(l10n.cycleEnterLmp),
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
    final chipStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 18),
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
                        l10n.cycleWeekLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '$week',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                      l10n.cycleWeekProgress(week),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                        l10n.cycleDueDateLabel(dpaLabel),
                        style: chipStyle,
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
                        l10n.cycleDaysUntilDelivery(daysLeft),
                        style: chipStyle,
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
            child: Text(l10n.cycleModifyLmp),
          ),
        ],
      ),
    );
  }

  void _enterLmp(BuildContext context) async {
    final now = DateTime.now();
    final l10n = context.l10n;
    final date = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 70)),
      firstDate: now.subtract(const Duration(days: 280)),
      lastDate: now,
      helpText: l10n.cycleLmpDatePickerHelp,
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
      final dpa = date.add(const Duration(days: 280));
      AnalyticsService().logEvent('edd_computed', parameters: {
        'edd': dpa.toIso8601String(),
        'week': DateTime.now().difference(date).inDays ~/ 7,
      });
    }
  }

  String _phaseLabel(AppLocalizations l10n, String phase) {
    switch (phase) {
      case 'Menstruation':
      case 'Règles':
        return l10n.cyclePhaseMenstruation;
      case 'Folliculaire':
      case 'Phase Folliculaire':
        return l10n.cyclePhaseFollicular;
      case 'Ovulation':
      case 'Phase Ovulatoire':
        return l10n.cyclePhaseOvulation;
      case 'Lutéale':
      case 'Phase Lutéale':
        return l10n.cyclePhaseLuteal;
      default:
        return phase;
    }
  }

  String _phaseDescription(AppLocalizations l10n, String phase) {
    switch (phase) {
      case 'Menstruation':
      case 'Règles':
        return l10n.cyclePhaseDescMenstruation;
      case 'Folliculaire':
      case 'Phase Folliculaire':
        return l10n.cyclePhaseDescFollicular;
      case 'Ovulation':
      case 'Phase Ovulatoire':
        return l10n.cyclePhaseDescOvulation;
      case 'Lutéale':
      case 'Phase Lutéale':
        return l10n.cyclePhaseDescLuteal;
      default:
        return l10n.cyclePhaseDescDefault;
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
