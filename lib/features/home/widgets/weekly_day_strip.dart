import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../health/models/appointment.dart';
import '../../health/providers/health_providers.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../vaccines/models/vaccine.dart';
import '../../vaccines/providers/vaccine_providers.dart';
import '../tabs/vaccinations_tab.dart';

enum DayEventType {
  vaccine,
  appointment,
  pregnancy,
  cyclePeriod,
  cycleOvulation,
}

class DayEvent {
  final DayEventType type;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const DayEvent({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

/// 7-Day adaptive interactive health calendar strip.
/// Connects to real user status, children's upcoming vaccines, doctor visits,
/// pregnancy milestones, and cycle tracking with compact styling.
class WeeklyDayStrip extends ConsumerStatefulWidget {
  final ValueChanged<DateTime>? onDaySelected;

  const WeeklyDayStrip({super.key, this.onDaySelected});

  @override
  ConsumerState<WeeklyDayStrip> createState() => _WeeklyDayStripState();
}

class _WeeklyDayStripState extends ConsumerState<WeeklyDayStrip> {
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

    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    final status = profile?.status ?? UserStatus.mom;

    final childrenAsync = ref.watch(childrenProvider);
    final children = childrenAsync.valueOrNull ?? const [];

    final vaccineCalendarAsync = ref.watch(vaccineCalendarProvider);
    final vaccineCalendar = vaccineCalendarAsync.valueOrNull;

    // Collect child appointments if child available
    final appointmentsAsync = children.isNotEmpty
        ? ref.watch(appointmentsProvider(children.first.id)).valueOrNull ?? []
        : <Appointment>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Month & Year + Full Calendar Link ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat.yMMMM(locale).format(_selectedDate),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF372F41),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _openFullCalendar(context, status),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _viewCalendarText(locale),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // ─── 7 Day Capsules Row (Compact Height) ─────────────────────
          Row(
            children: _weekDays.map((day) {
              final isSelected = _isSameDay(day, _selectedDate);
              final isToday = _isSameDay(day, today);

              final events = _resolveEventsForDay(
                day: day,
                status: status,
                profile: profile,
                children: children,
                vaccineCalendar: vaccineCalendar,
                appointments: appointmentsAsync,
                locale: locale,
              );

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedDate = day);
                      widget.onDaySelected?.call(day);
                      _handleDayTap(
                        context: context,
                        day: day,
                        events: events,
                        status: status,
                        locale: locale,
                        isDark: isDark,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF161618))
                            : (isToday
                                ? (isDark
                                    ? const Color(0xFF2E2234)
                                    : const Color(0xFFFFF0F3))
                                : (isDark
                                    ? AppColors.surfaceDark
                                    : Colors.white.withValues(alpha: 0.85))),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isToday
                                  ? AppColors.primaryLight
                                      .withValues(alpha: 0.45)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.05))),
                          width: isToday && !isSelected ? 1.2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.16),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Day name abbreviation (LUN, MAR...)
                          Text(
                            _dayNameAbbr(day, locale),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFF161618)
                                      : Colors.white70)
                                  : (isDark
                                      ? Colors.white54
                                      : const Color(0xFF7E7687)),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Day number
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFF161618)
                                      : Colors.white)
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1E1B24)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Adaptive event indicator dot
                          if (events.isNotEmpty)
                            Container(
                              width: 4.5,
                              height: 4.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDark
                                        ? const Color(0xFF161618)
                                        : Colors.white)
                                    : events.first.color,
                              ),
                            )
                          else if (isToday)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDark
                                        ? const Color(0xFF161618)
                                        : Colors.white)
                                    : AppColors.primaryLight
                                        .withValues(alpha: 0.7),
                              ),
                            )
                          else
                            const SizedBox(width: 4.5, height: 4.5),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayNameAbbr(DateTime day, String locale) {
    final raw = DateFormat('E', locale).format(day).toUpperCase();
    return raw.length > 3 ? raw.substring(0, 3) : raw;
  }

  List<DayEvent> _resolveEventsForDay({
    required DateTime day,
    required UserStatus status,
    required UserProfile? profile,
    required List<Child> children,
    required VaccineCalendar? vaccineCalendar,
    required List<Appointment> appointments,
    required String locale,
  }) {
    final events = <DayEvent>[];

    // 1. Appointments (Doctor visits)
    for (final appt in appointments) {
      if (_isSameDay(appt.date, day)) {
        events.add(
          DayEvent(
            type: DayEventType.appointment,
            title: appt.doctorName.trim().isNotEmpty
                ? appt.doctorName
                : appt.type.getLabel(locale),
            subtitle: '${appt.type.getLabel(locale)} • ${children.first.name}',
            color: const Color(0xFF6366F1),
            icon: Icons.medical_services_rounded,
          ),
        );
      }
    }

    // 2. Child Vaccines (Mother state)
    if (status == UserStatus.mom &&
        children.isNotEmpty &&
        vaccineCalendar != null) {
      for (final child in children) {
        for (final group in vaccineCalendar.groups) {
          final expectedDate = group.getExpectedDate(child.birthDate);
          if (_isSameDay(expectedDate, day)) {
            events.add(
              DayEvent(
                type: DayEventType.vaccine,
                title: locale.startsWith('ar')
                    ? 'تلقيح: ${group.vaccineCodesLabel}'
                    : 'Vaccin: ${group.vaccineCodesLabel}',
                subtitle: '${child.name} • ${group.getAgeLabel(locale)}',
                color: const Color(0xFF0D9488),
                icon: Icons.vaccines_rounded,
              ),
            );
          }
        }
      }
    }

    // 3. Pregnancy Milestones (Pregnant state)
    if (status == UserStatus.pregnant && profile?.lastPregnancyDate != null) {
      final lmp = profile!.lastPregnancyDate!;
      final diffDays = day.difference(lmp).inDays;
      if (diffDays >= 0) {
        final week = diffDays ~/ 7;
        final dayInWeek = diffDays % 7;
        if (dayInWeek == 0 && week > 0 && week <= 42) {
          events.add(
            DayEvent(
              type: DayEventType.pregnancy,
              title: locale.startsWith('ar')
                  ? 'الأسبوع $week من الحمل'
                  : 'Semaine $week de grossesse',
              subtitle: locale.startsWith('ar')
                  ? 'محطة أسبوعية لتطور الجنين'
                  : 'Étape clé du développement fœtal',
              color: const Color(0xFFD97706),
              icon: Icons.pregnant_woman_rounded,
            ),
          );
        }
      }
    }

    // 4. Menstrual Cycle & Ovulation (Hope state)
    if (status == UserStatus.hope && profile?.cycleInfo.lastPeriodDate != null) {
      final lpd = profile!.cycleInfo.lastPeriodDate!;
      final cycleLen = profile.cycleInfo.cycleLength > 0
          ? profile.cycleInfo.cycleLength
          : 28;
      final periodDur = profile.cycleInfo.periodDuration > 0
          ? profile.cycleInfo.periodDuration
          : 5;
      final diffDays = day.difference(lpd).inDays;
      if (diffDays >= 0) {
        final dayInCycle = (diffDays % cycleLen) + 1;
        if (dayInCycle <= periodDur) {
          events.add(
            DayEvent(
              type: DayEventType.cyclePeriod,
              title: locale.startsWith('ar')
                  ? 'فترة الدورة الشهرية'
                  : 'Période des règles',
              subtitle: locale.startsWith('ar')
                  ? 'اليوم $dayInCycle من الدورة'
                  : 'Jour $dayInCycle du cycle',
              color: const Color(0xFFE11D48),
              icon: Icons.water_drop_rounded,
            ),
          );
        } else if (dayInCycle >= 12 && dayInCycle <= 16) {
          events.add(
            DayEvent(
              type: DayEventType.cycleOvulation,
              title: locale.startsWith('ar')
                  ? 'نافذة الخصوبة والإباضة'
                  : 'Période fertile & Ovulation',
              subtitle: locale.startsWith('ar')
                  ? 'فرصة مثالية لحدوث الحمل'
                  : 'Probabilité de conception élevée',
              color: const Color(0xFF8B5CF6),
              icon: Icons.auto_awesome_rounded,
            ),
          );
        }
      }
    }

    return events;
  }

  void _openFullCalendar(BuildContext context, UserStatus status) {
    if (status == UserStatus.mom) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const VaccinationsTab(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HealthHubScreen(),
        ),
      );
    }
  }

  void _handleDayTap({
    required BuildContext context,
    required DateTime day,
    required List<DayEvent> events,
    required UserStatus status,
    required String locale,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF221A28) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Title & Event Count badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.yMMMMEEEEd(locale).format(day),
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1D1B20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            events.isNotEmpty
                                ? '${events.length} ${_eventsLabel(events.length, locale)}'
                                : _calmDayLabel(locale),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: events.isNotEmpty
                                  ? AppColors.primaryLight
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFF1E9FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(status, locale),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF4A3E5D),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Event cards or empty message
                if (events.isNotEmpty) ...[
                  ...events.map((event) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF9F7FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: event.color.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: event.color.withValues(alpha: 0.14),
                            ),
                            child: Icon(event.icon, size: 17, color: event.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1D1B20),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event.subtitle,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF6B6375),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF9F7FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          size: 24,
                          color: AppColors.primaryLight.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _noEventsMessage(locale),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF5A5364),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Button to open full calendar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openFullCalendar(context, status);
                    },
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(_fullCalendarButtonLabel(status, locale)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.white : const Color(0xFF161618),
                      foregroundColor:
                          isDark ? const Color(0xFF161618) : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _viewCalendarText(String locale) {
    if (locale.startsWith('ar')) return 'عرض التقويم ›';
    if (locale.startsWith('en')) return 'Full calendar ›';
    return 'Calendrier complet ›';
  }

  String _eventsLabel(int count, String locale) {
    if (locale.startsWith('ar')) return count > 1 ? 'مواعيد وأحداث' : 'موعد';
    if (locale.startsWith('en')) {
      return count > 1 ? 'events scheduled' : 'event scheduled';
    }
    return count > 1 ? 'événements prévus' : 'événement prévu';
  }

  String _calmDayLabel(String locale) {
    if (locale.startsWith('ar')) return 'يوم هادئ - لا توجد مواعيد';
    if (locale.startsWith('en')) return 'Quiet day - no events';
    return 'Journée calme - aucun événement';
  }

  String _noEventsMessage(String locale) {
    if (locale.startsWith('ar')) {
      return 'لا توجد مواعيد أو تلقيحات مقررة لهذا اليوم. يمكنك مراجعة جدول التلقيحات والمواعيد الطبية الكاملة.';
    }
    if (locale.startsWith('en')) {
      return 'No appointments or vaccinations scheduled for today. You can check the full health & vaccine calendar.';
    }
    return 'Aucun rendez-vous ou vaccin prévu pour cette journée. Vous pouvez consulter le calendrier complet.';
  }

  String _statusLabel(UserStatus status, String locale) {
    switch (status) {
      case UserStatus.mom:
        if (locale.startsWith('ar')) return 'تلقيحات وصحة';
        if (locale.startsWith('en')) return 'Vaccines & Health';
        return 'Santé & Vaccins';
      case UserStatus.pregnant:
        if (locale.startsWith('ar')) return 'متابعة الحمل';
        if (locale.startsWith('en')) return 'Pregnancy';
        return 'Suivi Grossesse';
      case UserStatus.hope:
        if (locale.startsWith('ar')) return 'الدورة والخصوبة';
        if (locale.startsWith('en')) return 'Cycle & Fertility';
        return 'Cycle & Fertilité';
    }
  }

  String _fullCalendarButtonLabel(UserStatus status, String locale) {
    if (status == UserStatus.mom) {
      if (locale.startsWith('ar')) return 'فتح جدول التلقيحات الكامل';
      if (locale.startsWith('en')) return 'Open full vaccine calendar';
      return 'Ouvrir le carnet de vaccination';
    } else {
      if (locale.startsWith('ar')) return 'فتح مركز المتابعة الصحية';
      if (locale.startsWith('en')) return 'Open health tracking hub';
      return 'Consulter le suivi santé';
    }
  }
}

