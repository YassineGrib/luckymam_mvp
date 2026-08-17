import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../models/growth_entry.dart';
import '../../../core/theme/app_typography.dart';

/// WHO weight-for-age reference data (p50, boys, 0-60 months).
/// Source: WHO Child Growth Standards.
const _whoWeightP50Boys = <double>[
  3.3,
  4.5,
  5.6,
  6.4,
  7.0,
  7.5,
  7.9,
  8.3,
  8.6,
  8.9,
  9.2,
  9.4,
  9.6,
  9.9,
  10.1,
  10.3,
  10.5,
  10.7,
  10.9,
  11.1,
  11.3,
  11.5,
  11.8,
  12.0,
  12.2,
  12.4,
  12.5,
  12.7,
  12.9,
  13.1,
  13.3,
  13.5,
  13.6,
  13.8,
  14.0,
  14.2,
  14.3,
  14.5,
  14.7,
  14.8,
  15.0,
  15.2,
  15.3,
  15.5,
  15.7,
  15.8,
  16.0,
  16.2,
  16.3,
  16.5,
  16.7,
  16.8,
  17.0,
  17.1,
  17.3,
  17.5,
  17.7,
  17.8,
  18.0,
  18.2,
  18.3,
];

/// WHO weight-for-age reference data (p50, girls, 0-60 months).
const _whoWeightP50Girls = <double>[
  3.2,
  4.2,
  5.1,
  5.8,
  6.4,
  6.9,
  7.3,
  7.6,
  7.9,
  8.2,
  8.5,
  8.7,
  9.0,
  9.2,
  9.4,
  9.6,
  9.8,
  10.0,
  10.2,
  10.4,
  10.6,
  10.9,
  11.1,
  11.3,
  11.5,
  11.7,
  11.9,
  12.1,
  12.3,
  12.5,
  12.7,
  12.9,
  13.1,
  13.3,
  13.5,
  13.7,
  13.9,
  14.1,
  14.3,
  14.5,
  14.7,
  14.9,
  15.1,
  15.3,
  15.5,
  15.7,
  15.9,
  16.1,
  16.3,
  16.5,
  16.7,
  16.9,
  17.1,
  17.3,
  17.5,
  17.7,
  17.9,
  18.1,
  18.3,
  18.5,
  18.7,
];

/// Visual growth chart: plots user measurements against WHO p50 reference.
class GrowthChartWidget extends StatelessWidget {
  const GrowthChartWidget({
    super.key,
    required this.entries,
    required this.childBirthDate,
    required this.isGirl,
  });

  final List<GrowthEntry> entries;
  final DateTime childBirthDate;
  final bool isGirl;

  double _ageMonths(DateTime date) => date.difference(childBirthDate).inDays / 30.44;

  /// Round [v] up to the next multiple of [step].
  double _ceilTo(double v, double step) => (v / step).ceil() * step;

  /// Compute smart Y-axis ceiling: at least 25 kg, above any real data point.
  double _computeMaxY(List<FlSpot> userSpots) {
    const minCeiling = 25.0;
    if (userSpots.isEmpty) return minCeiling;
    final maxData = userSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padded = maxData * 1.15;
    final ceiling = padded > minCeiling ? padded : minCeiling;
    return _ceilTo(ceiling, 5);
  }

  /// Pick a Y label interval that keeps the axis readable.
  double _yInterval(double maxY) {
    if (maxY <= 30) return 5;
    if (maxY <= 60) return 10;
    return 20;
  }

  /// Compute smart X-axis ceiling: at least 60 months, up to child's current age + 6.
  double _computeMaxX() {
    final ageMonths = _ageMonths(DateTime.now());
    const minCeiling = 60.0;
    if (ageMonths <= minCeiling) return minCeiling;
    return _ceilTo(ageMonths + 6, 12);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final gridColor = isDark ? Colors.white12 : Colors.black12;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final whoRef = isGirl ? _whoWeightP50Girls : _whoWeightP50Boys;
    final maxX = _computeMaxX();

    // WHO reference spots (monthly 0-60)
    final refSpots = [
      for (var i = 0; i < whoRef.length; i++) FlSpot(i.toDouble(), whoRef[i]),
    ];

    // User data spots — only entries with weight; X clamped to maxX
    final userSpots = entries.where((e) => e.weightKg != null).map((e) {
      final months = _ageMonths(e.date).clamp(0.0, maxX);
      return FlSpot(months, e.weightKg!);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

    if (userSpots.isEmpty && entries.isEmpty) {
      return _buildEmpty(context, primary);
    }

    final maxY = _computeMaxY(userSpots);
    final yInterval = _yInterval(maxY);
    final xInterval = maxX <= 60 ? 6.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 24, 8),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (v, meta) {
                  // Hide the max label to avoid overlap with top edge
                  if (v == maxY) return const SizedBox.shrink();
                  return Text(
                    l10n.healthChartAxisKg('${v.toInt()}'),
                    style: AppTypography.fromContext(context, fontSize: 10, color: labelColor),
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
                  style: AppTypography.fromContext(context, fontSize: 10, color: labelColor),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            // WHO reference curve (only up to 60 months)
            LineChartBarData(
              spots: refSpots,
              isCurved: true,
              color: AppColors.smaltBlue.withValues(alpha: 0.5),
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              dashArray: [6, 4],
            ),
            // User's data
            if (userSpots.isNotEmpty)
              LineChartBarData(
                spots: userSpots,
                isCurved: true,
                color: primary,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 4,
                    color: primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: primary.withValues(alpha: 0.08),
                ),
              ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => isDark ? AppColors.surfaceDark : Colors.white,
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      l10n.healthChartTooltip(
                        s.y.toStringAsFixed(1),
                        s.x.toStringAsFixed(0),
                      ),
                      AppTypography.fromContext(
                        context,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.onSurfaceLight,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color primary) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.show_chart_rounded,
          size: 48,
          color: primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.healthChartEmptyHint,
          textAlign: TextAlign.center,
          style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
        ),
      ],
    ),
  );
  }
}
