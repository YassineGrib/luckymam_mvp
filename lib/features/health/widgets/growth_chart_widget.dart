import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/growth_entry.dart';

/// Metric displayed on the growth chart.
enum GrowthMetricType {
  weight,
  height;

  bool get isWeight => this == GrowthMetricType.weight;
  bool get isHeight => this == GrowthMetricType.height;
}

/// WHO weight-for-age reference data (p50, boys, 0-60 months).
/// Source: WHO Child Growth Standards.
const _whoWeightP50Boys = <double>[
  3.3, 4.5, 5.6, 6.4, 7.0, 7.5, 7.9, 8.3, 8.6, 8.9, 9.2, 9.4, 9.6, 9.9,
  10.1, 10.3, 10.5, 10.7, 10.9, 11.1, 11.3, 11.5, 11.8, 12.0, 12.2, 12.4,
  12.5, 12.7, 12.9, 13.1, 13.3, 13.5, 13.6, 13.8, 14.0, 14.2, 14.3, 14.5,
  14.7, 14.8, 15.0, 15.2, 15.3, 15.5, 15.7, 15.8, 16.0, 16.2, 16.3, 16.5,
  16.7, 16.8, 17.0, 17.1, 17.3, 17.5, 17.7, 17.8, 18.0, 18.2, 18.3,
];

/// WHO weight-for-age reference data (p50, girls, 0-60 months).
const _whoWeightP50Girls = <double>[
  3.2, 4.2, 5.1, 5.8, 6.4, 6.9, 7.3, 7.6, 7.9, 8.2, 8.5, 8.7, 9.0, 9.2,
  9.4, 9.6, 9.8, 10.0, 10.2, 10.4, 10.6, 10.9, 11.1, 11.3, 11.5, 11.7,
  11.9, 12.1, 12.3, 12.5, 12.7, 12.9, 13.1, 13.3, 13.5, 13.7, 13.9, 14.1,
  14.3, 14.5, 14.7, 14.9, 15.1, 15.3, 15.5, 15.7, 15.9, 16.1, 16.3, 16.5,
  16.7, 16.9, 17.1, 17.3, 17.5, 17.7, 17.9, 18.1, 18.3, 18.5, 18.7,
];

/// WHO length/height-for-age reference data (p50, boys, 0-60 months, in cm).
/// Source: WHO Child Growth Standards.
const _whoHeightP50Boys = <double>[
  49.9, 54.7, 58.4, 61.4, 63.9, 65.9, 67.6, 69.2, 70.6, 72.0, 73.3, 74.5,
  75.7, 76.9, 78.0, 79.1, 80.2, 81.2, 82.3, 83.2, 84.2, 85.1, 86.0, 86.9,
  87.8, 88.5, 89.2, 89.9, 90.6, 91.2, 91.9, 92.5, 93.1, 93.7, 94.3, 94.9,
  96.1, 96.7, 97.4, 98.0, 98.6, 99.2, 99.9, 100.4, 101.0, 101.5, 102.1, 102.6,
  103.3, 103.8, 104.4, 105.0, 105.6, 106.1, 106.7, 107.2, 107.8, 108.3, 108.9, 109.4, 110.0,
];

/// WHO length/height-for-age reference data (p50, girls, 0-60 months, in cm).
const _whoHeightP50Girls = <double>[
  49.1, 53.7, 57.1, 59.8, 62.1, 64.0, 65.7, 67.3, 68.7, 70.1, 71.5, 72.8,
  74.0, 75.2, 76.4, 77.5, 78.6, 79.7, 80.7, 81.7, 82.7, 83.7, 84.6, 85.5,
  86.4, 87.1, 87.8, 88.5, 89.2, 89.9, 90.7, 91.3, 91.9, 92.5, 93.1, 93.7,
  95.1, 95.7, 96.4, 97.0, 97.6, 98.3, 99.0, 99.5, 100.1, 100.7, 101.3, 101.9,
  102.7, 103.3, 103.9, 104.5, 105.1, 105.7, 106.2, 106.7, 107.3, 107.8, 108.4, 108.9, 109.4,
];

/// Visual growth chart: plots user measurements against WHO standard reference
/// with normal healthy corridor (p15 - p85) and dual support for Weight & Height.
class GrowthChartWidget extends StatelessWidget {
  const GrowthChartWidget({
    super.key,
    required this.entries,
    required this.childBirthDate,
    required this.isGirl,
    this.metricType = GrowthMetricType.weight,
  });

  final List<GrowthEntry> entries;
  final DateTime childBirthDate;
  final bool isGirl;
  final GrowthMetricType metricType;

  double _ageMonths(DateTime date) =>
      date.difference(childBirthDate).inDays / 30.44;

  double _ceilTo(double v, double step) => (v / step).ceil() * step;

  /// Dynamic Y ceiling: safe bounds for Weight (kg) or Height (cm).
  double _computeMaxY(List<FlSpot> userSpots) {
    if (metricType.isHeight) {
      const minCeiling = 115.0;
      if (userSpots.isEmpty) return minCeiling;
      final maxData =
          userSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      final padded = maxData * 1.08;
      final ceiling = padded > minCeiling ? padded : minCeiling;
      return _ceilTo(ceiling, 10);
    } else {
      const minCeiling = 20.0;
      if (userSpots.isEmpty) return minCeiling;
      final maxData =
          userSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      final padded = maxData * 1.15;
      final ceiling = padded > minCeiling ? padded : minCeiling;
      return _ceilTo(ceiling, 5);
    }
  }

  /// Dynamic Y floor: for Height we start at 40cm, for Weight at 0kg.
  double _computeMinY() => metricType.isHeight ? 40.0 : 0.0;

  double _yInterval(double maxY) {
    if (metricType.isHeight) {
      return 15.0;
    }
    if (maxY <= 25) return 5.0;
    if (maxY <= 50) return 10.0;
    return 20.0;
  }

  double _computeMaxX() {
    final ageMonths = _ageMonths(DateTime.now());
    const minCeiling = 36.0;
    if (ageMonths <= minCeiling) return minCeiling;
    if (ageMonths <= 60.0) return 60.0;
    return _ceilTo(ageMonths + 6, 12);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.coral;
    final gridColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final List<double> whoMedian = metricType.isHeight
        ? (isGirl ? _whoHeightP50Girls : _whoHeightP50Boys)
        : (isGirl ? _whoWeightP50Girls : _whoWeightP50Boys);

    final maxX = _computeMaxX();

    // Normal zone variance factors (approx ±1 SD / p15 - p85)
    final double lowerFactor = metricType.isHeight ? 0.96 : 0.88;
    final double upperFactor = metricType.isHeight ? 1.04 : 1.13;

    // WHO Normal Zone Lower (p15)
    final lowerSpots = [
      for (var i = 0; i < whoMedian.length && i <= maxX; i++)
        FlSpot(i.toDouble(), whoMedian[i] * lowerFactor),
    ];

    // WHO Normal Zone Upper (p85)
    final upperSpots = [
      for (var i = 0; i < whoMedian.length && i <= maxX; i++)
        FlSpot(i.toDouble(), whoMedian[i] * upperFactor),
    ];

    // WHO Median Curve (p50)
    final medianSpots = [
      for (var i = 0; i < whoMedian.length && i <= maxX; i++)
        FlSpot(i.toDouble(), whoMedian[i]),
    ];

    // User actual measurements spots
    final rawSpots = entries.where((e) {
      if (metricType.isHeight) {
        return e.heightCm != null && e.heightCm! > 0;
      } else {
        return e.weightKg != null && e.weightKg! > 0;
      }
    }).map((e) {
      final months = _ageMonths(e.date).clamp(0.0, maxX);
      final val = metricType.isHeight ? e.heightCm! : e.weightKg!;
      return FlSpot(months, val);
    }).toList();

    rawSpots.sort((a, b) => a.x.compareTo(b.x));

    if (rawSpots.isEmpty && entries.isEmpty) {
      return _buildEmpty(context, primary, lang);
    }

    final minY = _computeMinY();
    final maxY = _computeMaxY(rawSpots);
    final yInterval = _yInterval(maxY);
    final xInterval = maxX <= 36 ? 6.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 18, 6),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: yInterval,
                getTitlesWidget: (v, meta) {
                  if (v == maxY || v < minY) return const SizedBox.shrink();
                  final unit = metricType.isHeight ? 'cm' : 'kg';
                  return Text(
                    '${v.toInt()} $unit',
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: xInterval,
                getTitlesWidget: (v, _) => Text(
                  l10n.healthChartAxisMonths('${v.toInt()}'),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          betweenBarsData: [
            // Shaded WHO Healthy Range Corridor (p15 to p85)
            BetweenBarsData(
              fromIndex: 0,
              toIndex: 1,
              color: AppColors.smaltBlue.withValues(alpha: isDark ? 0.08 : 0.06),
            ),
          ],
          lineBarsData: [
            // [0] WHO Lower Bound (p15)
            LineChartBarData(
              spots: lowerSpots,
              isCurved: true,
              color: AppColors.smaltBlue.withValues(alpha: 0.18),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
            // [1] WHO Upper Bound (p85)
            LineChartBarData(
              spots: upperSpots,
              isCurved: true,
              color: AppColors.smaltBlue.withValues(alpha: 0.18),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
            // [2] WHO Median (p50) Reference Line
            LineChartBarData(
              spots: medianSpots,
              isCurved: true,
              color: AppColors.smaltBlue.withValues(alpha: 0.6),
              barWidth: 1.8,
              dotData: const FlDotData(show: false),
              dashArray: [6, 4],
            ),
            // [3] Child's Real Growth Measurements Curve
            if (rawSpots.isNotEmpty)
              LineChartBarData(
                spots: rawSpots,
                isCurved: true,
                curveSmoothness: 0.2,
                color: primary,
                barWidth: 3,
                gradient: const LinearGradient(
                  colors: [AppColors.coral, AppColors.magentaPink],
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.coral,
                    strokeWidth: 2.5,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withValues(alpha: 0.22),
                      primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? const Color(0xFF1E2128) : Colors.white,
              tooltipBorder: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              tooltipRoundedRadius: 12,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((s) {
                  // Only show tooltip for user measurement (bar index 3)
                  if (s.barIndex != 3) return null;
                  final unit = metricType.isHeight ? 'cm' : 'kg';
                  final monthStr = s.x.toStringAsFixed(1);
                  final valStr = s.y.toStringAsFixed(1);
                  final label = lang == 'ar'
                      ? '$valStr $unit في عمر $monthStr شهر'
                      : '$valStr $unit à $monthStr mois';

                  return LineTooltipItem(
                    label,
                    AppTypography.fromContext(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.onSurfaceLight,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color primary, String lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              metricType.isHeight ? Icons.height_rounded : Icons.show_chart_rounded,
              size: 32,
              color: primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang == 'ar'
                ? 'لا توجد قياسات مسجلة حتى الآن'
                : 'Aucune mesure enregistrée pour le moment',
            textAlign: TextAlign.center,
            style: AppTypography.fromContext(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang == 'ar'
                ? 'اضغط على زر الإضافة بالأسفل لتسجيل أول قياس'
                : 'Appuyez sur le bouton ci-dessous pour ajouter une mesure',
            textAlign: TextAlign.center,
            style: AppTypography.fromContext(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: secondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
