import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_typography.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../reels/screens/reels_screen.dart';
import '../data/vaccine_education_data.dart';
import '../models/vaccine.dart';
import '../providers/vaccine_providers.dart';

/// Detail screen for a single vaccine, showing rich educational content.
class VaccineDetailScreen extends ConsumerWidget {
  const VaccineDetailScreen({
    super.key,
    required this.vaccine,
    required this.childId,
    required this.vaccineGroupId,
  });

  final Vaccine vaccine;
  final String childId;
  final String vaccineGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final info = vaccineEducationFor(vaccine.code);
    final accentColor = info?.color ?? AppColors.primaryLight;
    final headerIcon = info?.icon ?? Icons.vaccines_rounded;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _VaccineDetailHeader(
            vaccine: vaccine,
            accentColor: accentColor,
            icon: headerIcon,
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // Protects chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.vaccineDetailProtectsAgainst(
                              vaccine.getProtects(lang),
                            ),
                            style: AppTypography.fromContext(context,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (info != null) ...[
                    _InfoSection(
                      icon: Icons.info_outline_rounded,
                      title: l10n.vaccineDetailPurposeTitle,
                      content: info.getDescription(lang),
                      accentColor: accentColor,
                      surface: surface,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _InfoSection(
                      icon: Icons.biotech_rounded,
                      title: l10n.vaccineDetailHowItWorks,
                      content: info.getHowItWorks(lang),
                      accentColor: accentColor,
                      surface: surface,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _InfoSection(
                      icon: Icons.healing_rounded,
                      title: l10n.vaccineDetailSideEffects,
                      content: info.getSideEffects(lang),
                      accentColor: accentColor,
                      surface: surface,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.vaccineDetailFallback,
                        style: AppTypography.fromContext(context,
                          fontSize: 14,
                          color: secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Capsule Section
                  _buildCapsuleSection(context, ref, isDark, surface, textColor, secondaryText, accentColor),
                  const SizedBox(height: 16),

                  // Reels Section
                  _buildReelsSection(context, surface, textColor, secondaryText, accentColor),
                  const SizedBox(height: 16),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.withValues(alpha: 0.1)
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.vaccineDetailDisclaimer,
                            style: AppTypography.fromContext(context,
                              fontSize: 12,
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color surface,
    Color textColor,
    Color secondaryText,
    Color accentColor,
  ) {
    final statusesAsync = ref.watch(childVaccinationStatusesProvider(childId));
    final status = statusesAsync.whenOrNull(
      data: (list) => list.where((s) => s.vaccineGroupId == vaccineGroupId).firstOrNull,
    );
    final capsuleId = status?.capsuleId;

    if (capsuleId == null) {
      return _buildCapsuleCTA(context, accentColor, surface, textColor, secondaryText, isDark);
    }

    final capsulesAsync = ref.watch(capsulesProvider);
    return capsulesAsync.when(
      loading: () => Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
        ),
      ),
      error: (_, _) => _buildCapsuleCTA(context, accentColor, surface, textColor, secondaryText, isDark),
      data: (list) {
        final capsule = list.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) {
          return _buildCapsuleCTA(context, accentColor, surface, textColor, secondaryText, isDark);
        }
        return _buildLinkedCapsuleRow(context, capsule, isDark, surface, textColor, secondaryText, accentColor);
      },
    );
  }

  Widget _buildLinkedCapsuleRow(
    BuildContext context,
    Capsule capsule,
    bool isDark,
    Color surface,
    Color textColor,
    Color secondaryText,
    Color accentColor,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_enhance_rounded, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                context.l10n.vaccineLinkedMemory,
                style: AppTypography.fromContext(context,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onTap: () {
                    // Log analytical event
                    final AnalyticsService analytics = AnalyticsService();
                    analytics.logEvent(
                      'vax_capsule_viewed',
                      parameters: {
                        'childId': childId,
                        'vaccineGroupId': vaccineGroupId,
                        'capsuleId': capsule.id,
                      },
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CapsuleDetailScreen(capsule: capsule),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 70,
                    height: 70,
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
                          child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.vaccineCapsuleTitle,
                      style: AppTypography.fromContext(context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(capsule.emotion.icon, size: 14, color: secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          capsule.emotion.getLabel(lang),
                          style: AppTypography.fromContext(context,
                            fontSize: 13,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Log analytical event
                  final AnalyticsService analytics = AnalyticsService();
                  analytics.logEvent(
                    'vax_capsule_viewed',
                    parameters: {
                      'childId': childId,
                      'vaccineGroupId': vaccineGroupId,
                      'capsuleId': capsule.id,
                    },
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CapsuleDetailScreen(capsule: capsule),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleCTA(
    BuildContext context,
    Color accentColor,
    Color surface,
    Color textColor,
    Color secondaryText,
    bool isDark,
  ) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_enhance_rounded, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.vaccineMemorySection,
                style: AppTypography.fromContext(context,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.vaccineMemoryPrompt,
            style: AppTypography.fromContext(context,
              fontSize: 13,
              color: secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateCapsuleScreen(
                      vaccineGroupId: vaccineGroupId,
                      preselectedChildId: childId,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add_rounded, size: 18, color: accentColor),
              label: Text(
                l10n.capsule,
                style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsSection(
    BuildContext context,
    Color surface,
    Color textColor,
    Color secondaryText,
    Color accentColor,
  ) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  size: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.vaccineReelsTitle,
                style: AppTypography.fromContext(context,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.vaccineReelsSubtitle,
            style: AppTypography.fromContext(context,
              fontSize: 13,
              color: secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                AnalyticsService().logEvent(
                  'vax_reels_opened',
                  parameters: {
                    'childId': childId,
                    'vaccineCode': vaccine.code,
                  },
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReelsScreen(
                      initialVaccineCodes: [vaccine.code],
                      initialVaccineLabel: vaccine.code,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.play_circle_fill_rounded,
                size: 18,
                color: accentColor,
              ),
              label: Text(
                l10n.vaccineReelsButton,
                style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineDetailHeader extends StatelessWidget {
  const _VaccineDetailHeader({
    required this.vaccine,
    required this.accentColor,
    required this.icon,
  });

  final Vaccine vaccine;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withValues(alpha: 0.82)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset(
                    'assets/images/heroPatern.png',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Icon(icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vaccine.code,
                                  style: AppTypography.fromContext(context,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vaccine.nameFr,
                                  style: AppTypography.fromContext(context,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.88),
                                    height: 1.3,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
    required this.surface,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;
  final Color surface;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTypography.fromContext(context,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTypography.fromContext(context,
              fontSize: 13,
              color: secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
