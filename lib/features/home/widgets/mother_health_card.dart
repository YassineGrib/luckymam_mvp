import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/profile_screen.dart';
import '../../../core/theme/app_typography.dart';

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

/// Card displaying mother's health summary (Cycle, Medical).
class MotherHealthCard extends ConsumerWidget {
  const MotherHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          // Navigate to profile (where health details are)
          // Ideally, we could navigate to specific tab/section if needed
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              colors: [cardColor, primaryColor.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
            data: (profile) {
              if (profile == null) return const SizedBox.shrink();

              final cycleInfo = profile.cycleInfo;
              final isPregnant = profile.status == UserStatus.pregnant;

              return Row(
                children: [
                  // Icon Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.pink.shade400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.healthMotherTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isDark
                                ? Colors.white
                                : AppColors.onSurfaceLight),
                        ),
                        const SizedBox(height: 4),
                        if (isPregnant)
                          Text(
                            l10n.healthMotherPregnancyTracking,
                            style: AppTypography.fromContext(context, fontSize: 13, color: isDark
                                  ? Colors.white70
                                  : AppColors.textSecondaryLight),
                          )
                        else if (cycleInfo.isTracking &&
                            cycleInfo.lastPeriodDate != null)
                          Text(
                            l10n.cycleDayPhase(
                              cycleInfo.currentDay,
                              _phaseLabel(l10n, cycleInfo.currentPhase),
                            ),
                            style: AppTypography.fromContext(context, fontSize: 13, color: isDark
                                  ? Colors.white70
                                  : AppColors.textSecondaryLight),
                          )
                        else
                          Text(
                            l10n.healthMotherViewMedicalInfo,
                            style: AppTypography.fromContext(context, fontSize: 13, color: isDark
                                  ? Colors.white70
                                  : AppColors.textSecondaryLight),
                          ),
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white30 : Colors.black12,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
