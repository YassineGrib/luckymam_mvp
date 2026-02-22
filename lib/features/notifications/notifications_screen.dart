import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';

// ─── Preferences keys ────────────────────────────────────────────────
const _kVaccineKey = 'notif_vaccine';
const _kMilestoneKey = 'notif_milestone';
const _kCycleKey = 'notif_cycle';

// ─── Provider ────────────────────────────────────────────────────────

/// Holds the on/off state for each notification channel.
class NotificationPrefs {
  const NotificationPrefs({
    this.vaccine = true,
    this.milestone = true,
    this.cycle = true,
  });

  final bool vaccine;
  final bool milestone;
  final bool cycle;

  NotificationPrefs copyWith({bool? vaccine, bool? milestone, bool? cycle}) =>
      NotificationPrefs(
        vaccine: vaccine ?? this.vaccine,
        milestone: milestone ?? this.milestone,
        cycle: cycle ?? this.cycle,
      );
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPrefs(
      vaccine: prefs.getBool(_kVaccineKey) ?? true,
      milestone: prefs.getBool(_kMilestoneKey) ?? true,
      cycle: prefs.getBool(_kCycleKey) ?? true,
    );
  }

  Future<void> setVaccine(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVaccineKey, value);
    if (!value)
      await NotificationService().cancelNotificationsByChannel('vaccine');
    state = state.copyWith(vaccine: value);
  }

  Future<void> setMilestone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMilestoneKey, value);
    if (!value)
      await NotificationService().cancelNotificationsByChannel('milestone');
    state = state.copyWith(milestone: value);
  }

  Future<void> setCycle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCycleKey, value);
    if (!value) {
      final ns = NotificationService();
      await ns.cancelNotification(cycleNextPeriodId);
      await ns.cancelNotification(cycleOvulationId);
    }
    state = state.copyWith(cycle: value);
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
      (_) => NotificationPrefsNotifier(),
    );

// ─── Screen ──────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Header banner ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rappels intelligents',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gérez vos rappels personnalisés',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Cards ────────────────────────────────────────────────
          _NotifCard(
            cardColor: cardColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
            icon: Icons.vaccines_rounded,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: Colors.green,
            title: 'Rappels Vaccination',
            subtitle: '2 jours avant la date du vaccin, à 09h00',
            value: prefs.vaccine,
            onChanged: notifier.setVaccine,
            activeColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _NotifCard(
            cardColor: cardColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
            icon: Icons.star_rounded,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: Colors.orange,
            title: 'Jalons de Développement',
            subtitle: '7 jours avant chaque étape clé, à 09h00',
            value: prefs.milestone,
            onChanged: notifier.setMilestone,
            activeColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          _NotifCard(
            cardColor: cardColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
            icon: Icons.favorite_rounded,
            iconBg: const Color(0xFFF8E8FF),
            iconColor: Colors.deepPurpleAccent,
            title: 'Cycle Féminin',
            subtitle: 'Règles dans 2 jours • Phase ovulatoire — à 08h00',
            value: prefs.cycle,
            onChanged: notifier.setCycle,
            activeColor: Colors.deepPurpleAccent,
          ),

          const SizedBox(height: 32),

          // ── Info note ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Les rappels sont planifiés automatiquement. '
                    'Ils s\'adaptent à vos données personnelles et celles de votre enfant.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: secondaryColor,
                      height: 1.5,
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
}

// ─── Notification Card ────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.cardColor,
    required this.textColor,
    required this.secondaryColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final Color cardColor;
  final Color textColor;
  final Color secondaryColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final Future<void> Function(bool) onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: secondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }
}
