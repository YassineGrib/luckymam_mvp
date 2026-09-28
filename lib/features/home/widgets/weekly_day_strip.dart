import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

/// 7-Day interactive capsule strip inspired by modern boutique mobile apps.
/// Displays the current week as vertical pill capsules with active day highlight,
/// status dots, and smooth haptic/tactile feedback on press.
class WeeklyDayStrip extends StatefulWidget {
  final ValueChanged<DateTime>? onDaySelected;

  const WeeklyDayStrip({super.key, this.onDaySelected});

  @override
  State<WeeklyDayStrip> createState() => _WeeklyDayStripState();
}

class _WeeklyDayStripState extends State<WeeklyDayStrip> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _weekDays = _generateCurrentWeek(now);
  }

  List<DateTime> _generateCurrentWeek(DateTime anchor) {
    // Start with Monday of the current week (or Sunday)
    final weekday = anchor.weekday; // 1 = Monday, 7 = Sunday
    final monday = anchor.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) {
      final d = monday.add(Duration(days: index));
      return DateTime(d.year, d.month, d.day);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _weekDays.map((day) {
          final isSelected = _isSameDay(day, _selectedDate);
          final isToday = _isSameDay(day, today);
          final dayName = DateFormat('E', locale).format(day);
          final dayNumber = DateFormat('d', locale).format(day);

          return _DayPill(
            dayName: dayName,
            dayNumber: dayNumber,
            isSelected: isSelected,
            isToday: isToday,
            isDark: isDark,
            onTap: () {
              setState(() => _selectedDate = day);
              widget.onDaySelected?.call(day);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final String dayName;
  final String dayNumber;
  final bool isSelected;
  final bool isToday;
  final bool isDark;
  final VoidCallback onTap;

  const _DayPill({
    required this.dayName,
    required this.dayNumber,
    required this.isSelected,
    required this.isToday,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? Colors.white : const Color(0xFF161618);
    final activeText = isDark ? const Color(0xFF161618) : Colors.white;

    final inactiveBg = isDark
        ? AppColors.surfaceDark
        : Colors.white.withValues(alpha: 0.85);
    final inactiveText = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF161618);
    final subText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status dot indicator
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : Colors.white)
                    : (isToday ? AppColors.primaryLight : Colors.transparent),
              ),
            ),
            const SizedBox(height: 6),
            // Day name (e.g. Lun / Wed / الأربعاء)
            Text(
              dayName.length > 3 ? dayName.substring(0, 3) : dayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeText.withValues(alpha: 0.8) : subText,
              ),
            ),
            const SizedBox(height: 4),
            // Day number (e.g. 25)
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? activeText : inactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
