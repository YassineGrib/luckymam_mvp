import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/profile_screen.dart';

/// Visual cycle tracker section for the dashboard.
class CycleTrackingSection extends ConsumerWidget {
  const CycleTrackingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final cycleInfo = profile.cycleInfo;
        final isPregnant = profile.status == UserStatus.pregnant;

        if (isPregnant)
          return _buildPregnancyTracker(context, profile, isDark, primaryColor);
        if (!cycleInfo.isTracking || cycleInfo.lastPeriodDate == null) {
          return _buildSetupPrompt(context, isDark, primaryColor);
        }

        return _buildCycleTracker(
          context,
          ref,
          cycleInfo,
          isDark,
          primaryColor,
          textColor,
          secondaryColor,
        );
      },
    );
  }

  Widget _buildCycleTracker(
    BuildContext context,
    WidgetRef ref,
    CycleInfo cycleInfo,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color secondaryColor,
  ) {
    final phase = cycleInfo.currentPhase;
    final phaseColor = _getPhaseColor(phase);
    final progress = cycleInfo.currentDay / cycleInfo.cycleLength;
    final nextPeriod = cycleInfo.nextPeriodDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: phaseColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.loop_rounded, color: phaseColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Suivi du Cycle',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (nextPeriod != null)
                  Text(
                    'Règles dans ${nextPeriod.difference(DateTime.now()).inDays} j',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: phaseColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Circular indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: phaseColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(phaseColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Jour',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: secondaryColor,
                          ),
                        ),
                        Text(
                          '${cycleInfo.currentDay}',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Phase Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: phaseColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          phase,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: phaseColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPhaseDescription(phase),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: secondaryColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Quick Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logPeriod(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: phaseColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Enregistrer mes règles',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyTracker(
    BuildContext context,
    UserProfile profile,
    bool isDark,
    Color primaryColor,
  ) {
    // Basic pregnancy tracker placeholder
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.1),
              primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pregnant_woman_rounded,
                color: Colors.pink,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ma Grossesse',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Suivi hebdomadaire et conseils.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPrompt(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.goldenrod,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activer le suivi de cycle',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prévoyez vos règles et dates d\'ovulation.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Règles':
        return Colors.redAccent;
      case 'Phase Folliculaire':
        return Colors.blueAccent;
      case 'Phase Ovulatoire':
        return Colors.purpleAccent;
      case 'Phase Lutéale':
        return Colors.orangeAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'Règles':
        return 'Votre cycle commence. Prenez soin de vous.';
      case 'Phase Folliculaire':
        return 'Votre corps se prépare. Vous vous sentez plus énergique.';
      case 'Phase Ovulatoire':
        return 'Période de fertilité maximale.';
      case 'Phase Lutéale':
        return 'Préparation pour le prochain cycle.';
      default:
        return 'Évolution de votre cycle féminin.';
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
              seedColor: Colors.purple,
              primary: Colors.purple,
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
