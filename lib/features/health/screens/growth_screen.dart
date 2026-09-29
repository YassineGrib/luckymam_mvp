import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/auth_logo_background.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../profile/models/profile_models.dart';
import '../models/growth_entry.dart';
import '../providers/health_providers.dart';
import '../widgets/growth_chart_widget.dart';
import '../widgets/growth_entry_card.dart';

String _healthDateLocale(String languageCode) =>
    languageCode == 'fr' ? 'fr_FR' : languageCode;

/// Growth chart screen — log weight & height, view WHO percentile curves,
/// and track vital statistics in a modern Luxury Squircle Bento interface.
class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key, required this.child});
  final Child child;

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  bool _analyticsLogged = false;
  GrowthMetricType _selectedMetric = GrowthMetricType.weight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final canPop = Navigator.of(context).canPop();
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final entriesAsync = ref.watch(growthEntriesProvider(widget.child.id));

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient lighting & watermark when standalone
          if (canPop) ...[
            const TopAmbientGradient(),
            const AuthLogoBackground(lightOpacity: 0.05, darkOpacity: 0.03),
          ],

          entriesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.coral),
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                l10n.healthErrorWithDetail('$e'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.error),
              ),
            ),
            data: (entries) {
              if (!_analyticsLogged) {
                _analyticsLogged = true;
                AnalyticsService().logEvent('growth_chart_viewed', parameters: {
                  'child_id': widget.child.id,
                  'entry_count': entries.length,
                });
              }

              // Sort entries from newest to oldest for statistics
              final sortedEntries = List<GrowthEntry>.from(entries)
                ..sort((a, b) => b.date.compareTo(a.date));

              final latest = sortedEntries.isNotEmpty ? sortedEntries.first : null;
              final previous = sortedEntries.length > 1 ? sortedEntries[1] : null;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Standalone Luxury Top Header ──
                  if (canPop)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenPaddingH,
                          MediaQuery.of(context).padding.top + 8,
                          AppSpacing.screenPaddingH,
                          6,
                        ),
                        child: Row(
                          children: [
                            // Frosted Squircle Back Button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white12
                                        : const Color(0xFFE8E0E4),
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
                                  context.isRtl
                                      ? Icons.arrow_forward_ios_rounded
                                      : Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Screen Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang == 'ar'
                                        ? 'مخطط النمو والقياسات'
                                        : (lang == 'fr'
                                            ? 'Courbe de Croissance'
                                            : 'Growth Tracker'),
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.child.name} • ${lang == 'ar' ? 'منحنيات منظمة الصحة العالمية (WHO)' : 'Courbes officielles OMS'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick Add Entry CTA
                            GestureDetector(
                              onTap: () => _showAddSheet(context, textColor, isDark, lang),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.coral,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.coral.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      lang == 'ar' ? 'قياس جديد' : 'Mesurer',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
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
              // ── 1. Top Vital Stats Bento Row ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    AppSpacing.md,
                    AppSpacing.screenPaddingH,
                    0,
                  ),
                  child: _buildVitalStatsBento(
                    context,
                    latest: latest,
                    previous: previous,
                    isDark: isDark,
                    textColor: textColor,
                    secondary: secondary,
                    lang: lang,
                  ),
                ),
              ),

              // ── 2. Metric Switcher (Weight vs Height) ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    14,
                    AppSpacing.screenPaddingH,
                    0,
                  ),
                  child: _buildMetricSwitcher(context, isDark, textColor, lang),
                ),
              ),

              // ── 3. Growth Chart Bento Container ────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    14,
                    AppSpacing.screenPaddingH,
                    0,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2128) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white12
                          : AppColors.onSurfaceLight.withValues(alpha: 0.07),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.035,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart Title & Dynamic Legend
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _selectedMetric.isWeight
                                  ? Icons.monitor_weight_outlined
                                  : Icons.height_rounded,
                              size: 18,
                              color: AppColors.coral,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedMetric.isWeight
                                  ? (lang == 'ar'
                                      ? 'منحنى الوزن (WHO)'
                                      : 'Courbe de poids (OMS)')
                                  : (lang == 'ar'
                                      ? 'منحنى الطول (WHO)'
                                      : 'Courbe de taille (OMS)'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Legend Pills
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _buildLegendItem(
                            color: AppColors.coral,
                            label: widget.child.name,
                            isChildCurve: true,
                          ),
                          _buildLegendItem(
                            color: AppColors.smaltBlue,
                            label: lang == 'ar' ? 'معيار OMS p50' : 'Norme OMS p50',
                            isDashed: true,
                          ),
                          _buildLegendItem(
                            color: AppColors.smaltBlue.withValues(alpha: 0.35),
                            label: lang == 'ar'
                                ? 'نطاق النمو الطبيعي (p15-p85)'
                                : 'Zone normale (p15-p85)',
                            isZone: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // The Chart Canvas
                      SizedBox(
                        height: 230,
                        child: GrowthChartWidget(
                          entries: entries,
                          childBirthDate: widget.child.birthDate,
                          isGirl: widget.child.gender == ChildGender.girl,
                          metricType: _selectedMetric,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 4. Measurement History Header ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    22,
                    AppSpacing.screenPaddingH,
                    10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.healthMeasurementHistory,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : AppColors.onSurfaceLight)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lang == 'ar'
                              ? '${entries.length} تسجيلات'
                              : '${entries.length} relevés',
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 5. History Entries List ────────────────────────────
              if (entries.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmpty(secondary, l10n, lang),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    0,
                    AppSpacing.screenPaddingH,
                    110,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => GrowthEntryCard(
                        entry: sortedEntries[i],
                        onDelete: () => _confirmDelete(sortedEntries[i]),
                      ),
                      childCount: sortedEntries.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            lang == 'ar' ? 'تسجيل قياس جديد' : l10n.healthMeasurementFab,
            style: AppTypography.fromContext(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAddSheet(context, textColor, isDark, lang);
          },
        ),
      ),
    );
  }

  // ─── Top Vital Stats Bento ───────────────────────────────────────────────

  Widget _buildVitalStatsBento(
    BuildContext context, {
    required GrowthEntry? latest,
    required GrowthEntry? previous,
    required bool isDark,
    required Color textColor,
    required Color secondary,
    required String lang,
  }) {
    final double? latestWeight = latest?.weightKg;
    final double? prevWeight = previous?.weightKg;
    final double? weightDiff =
        latestWeight != null && prevWeight != null ? (latestWeight - prevWeight) : null;

    final double? latestHeight = latest?.heightCm;
    final double? prevHeight = previous?.heightCm;
    final double? heightDiff =
        latestHeight != null && prevHeight != null ? (latestHeight - prevHeight) : null;

    return Row(
      children: [
        // Latest Weight Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2128) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : AppColors.onSurfaceLight.withValues(alpha: 0.07),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang == 'ar' ? 'الوزن الأخير' : 'Dernier Poids',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                    const Icon(
                      Icons.monitor_weight_outlined,
                      size: 16,
                      color: AppColors.coral,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  latestWeight != null ? '${latestWeight.toStringAsFixed(1)} kg' : '--',
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (weightDiff != null) ...[
                      Icon(
                        weightDiff >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: weightDiff >= 0 ? AppColors.success : AppColors.casablanca,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${weightDiff >= 0 ? '+' : ''}${weightDiff.toStringAsFixed(1)} kg',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: weightDiff >= 0 ? AppColors.success : AppColors.casablanca,
                        ),
                      ),
                    ] else ...[
                      Text(
                        lang == 'ar' ? 'معيار OMS ✓' : 'Norme OMS ✓',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Latest Height Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2128) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : AppColors.onSurfaceLight.withValues(alpha: 0.07),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang == 'ar' ? 'الطول الأخير' : 'Dernière Taille',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                    const Icon(
                      Icons.height_rounded,
                      size: 16,
                      color: AppColors.smaltBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  latestHeight != null ? '${latestHeight.toStringAsFixed(1)} cm' : '--',
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.smaltBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (heightDiff != null) ...[
                      Icon(
                        heightDiff >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: heightDiff >= 0 ? AppColors.success : AppColors.casablanca,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${heightDiff >= 0 ? '+' : ''}${heightDiff.toStringAsFixed(1)} cm',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: heightDiff >= 0 ? AppColors.success : AppColors.casablanca,
                        ),
                      ),
                    ] else ...[
                      Text(
                        lang == 'ar' ? 'نمو متوازن ✓' : 'Équilibré ✓',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Metric Switcher (Weight / Height) ───────────────────────────────────

  Widget _buildMetricSwitcher(
    BuildContext context,
    bool isDark,
    Color textColor,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.onSurfaceLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Weight Switch Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMetric = GrowthMetricType.weight);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedMetric.isWeight
                      ? (isDark ? const Color(0xFF1E2128) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedMetric.isWeight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monitor_weight_outlined,
                      size: 16,
                      color: _selectedMetric.isWeight
                          ? AppColors.coral
                          : textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      lang == 'ar' ? 'الوزن (kg)' : 'Poids (kg)',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        fontWeight: _selectedMetric.isWeight
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: _selectedMetric.isWeight
                            ? textColor
                            : textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Height Switch Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMetric = GrowthMetricType.height);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedMetric.isHeight
                      ? (isDark ? const Color(0xFF1E2128) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedMetric.isHeight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.height_rounded,
                      size: 16,
                      color: _selectedMetric.isHeight
                          ? AppColors.smaltBlue
                          : textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      lang == 'ar' ? 'الطول (cm)' : 'Taille (cm)',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        fontWeight: _selectedMetric.isHeight
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: _selectedMetric.isHeight
                            ? textColor
                            : textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isChildCurve = false,
    bool isDashed = false,
    bool isZone = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isZone)
          Container(
            width: 14,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else if (isDashed)
          Row(
            children: [
              Container(width: 4, height: 2, color: color),
              const SizedBox(width: 2),
              Container(width: 4, height: 2, color: color),
              const SizedBox(width: 2),
              Container(width: 4, height: 2, color: color),
            ],
          )
        else
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.fromContext(
            context,
            fontSize: 10,
            fontWeight: isChildCurve ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(Color secondary, AppLocalizations l10n, String lang) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Icon(
                Icons.monitor_weight_outlined,
                size: 54,
                color: AppColors.coral.withValues(alpha: 0.35),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.healthNoMeasurementsTitle,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.healthNoMeasurementsHint,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  void _confirmDelete(GrowthEntry entry) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.healthDeleteMeasurementTitle,
          style: AppTypography.fromContext(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.healthCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(growthActionsProvider.notifier).deleteEntry(
                    childId: widget.child.id,
                    entryId: entry.id,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.healthDelete),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(
    BuildContext context,
    Color textColor,
    bool isDark,
    String lang,
  ) {
    final l10n = context.l10n;
    final dateLocale = _healthDateLocale(lang);
    DateTime selectedDate = DateTime.now();
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final surface = isDark ? const Color(0xFF1E2128) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            16,
            AppSpacing.screenPaddingH,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_chart_rounded,
                      color: AppColors.coral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    lang == 'ar' ? 'تسجيل قياس نمو جديد' : 'Nouveau relevé de croissance',
                    style: AppTypography.fromContext(
                      ctx,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Date Picker Squircle
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: widget.child.birthDate,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModal(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('d MMMM yyyy', dateLocale).format(selectedDate),
                        style: AppTypography.fromContext(
                          ctx,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.coral,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Weight Input
              TextFormField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.fromContext(
                  ctx,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  labelText: l10n.healthWeightKg,
                  prefixIcon: const Icon(
                    Icons.monitor_weight_outlined,
                    color: AppColors.coral,
                    size: 20,
                  ),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.coral,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Height Input
              TextFormField(
                controller: heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.fromContext(
                  ctx,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  labelText: l10n.healthHeightCm,
                  prefixIcon: const Icon(
                    Icons.height_rounded,
                    color: AppColors.smaltBlue,
                    size: 20,
                  ),
                  suffixText: 'cm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.smaltBlue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notes Input
              TextFormField(
                controller: notesCtrl,
                style: AppTypography.fromContext(
                  ctx,
                  fontSize: 13,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  labelText: lang == 'ar' ? 'ملاحظات إضافية (اختياري)' : 'Notes (facultatif)',
                  prefixIcon: const Icon(
                    Icons.notes_rounded,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save CTA Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final w = double.tryParse(
                        weightCtrl.text.replaceAll(',', '.'),
                      );
                      final h = double.tryParse(
                        heightCtrl.text.replaceAll(',', '.'),
                      );
                      if (w == null && h == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang == 'ar'
                                  ? 'يرجى إدخال الوزن أو الطول على الأقل'
                                  : 'Veuillez saisir au moins le poids ou la taille',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                      await ref
                          .read(growthActionsProvider.notifier)
                          .addEntry(
                            childId: widget.child.id,
                            date: selectedDate,
                            weightKg: w,
                            heightCm: h,
                            notes: notesCtrl.text.trim().isNotEmpty
                                ? notesCtrl.text.trim()
                                : null,
                          );
                    },
                    icon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      l10n.healthSave,
                      style: AppTypography.fromContext(
                        ctx,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
