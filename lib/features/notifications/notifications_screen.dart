import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/extensions/l10n_extension.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/fcm_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../capsules/screens/create_capsule_screen.dart';
import '../memory_book/screens/album_template_picker_screen.dart';
import '../profile/providers/profile_providers.dart';
import 'models/app_notification.dart';
import 'providers/notifications_providers.dart';

// ─── Preferences keys ────────────────────────────────────────────────
const _kVaccineKey = 'notif_vaccine';
const _kMilestoneKey = 'notif_milestone';
const _kCycleKey = 'notif_cycle';

// ─── Preferences Provider ────────────────────────────────────────────

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
    if (!value) {
      await NotificationService().cancelNotificationsByChannel('vaccine');
    }
    state = state.copyWith(vaccine: value);
  }

  Future<void> setMilestone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMilestoneKey, value);
    if (!value) {
      await NotificationService().cancelNotificationsByChannel('milestone');
    }
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

// ─── Filter Category Enum ────────────────────────────────────────────

enum _FilterCategory {
  all,
  vaccines,
  memories,
  milestones;

  String label(String lang) {
    switch (this) {
      case _FilterCategory.all:
        return lang == 'ar' ? 'الكل' : (lang == 'fr' ? 'Tous' : 'All');
      case _FilterCategory.vaccines:
        return lang == 'ar'
            ? '🩺 اللقاحات والصحة'
            : (lang == 'fr' ? '🩺 Santé & Vaccins' : '🩺 Health & Vaccines');
      case _FilterCategory.memories:
        return lang == 'ar'
            ? '👑 الألبوم والذكريات'
            : (lang == 'fr' ? '👑 Livre & Souvenirs' : '👑 Albums & Memories');
      case _FilterCategory.milestones:
        return lang == 'ar'
            ? '⭐ معالم النمو والنصائح'
            : (lang == 'fr' ? '⭐ Jalons & Conseils' : '⭐ Milestones & Tips');
    }
  }

  bool matches(AppNotification notif) {
    switch (this) {
      case _FilterCategory.all:
        return true;
      case _FilterCategory.vaccines:
        return notif.type == NotificationType.vaccine;
      case _FilterCategory.memories:
        return notif.type == NotificationType.album ||
            notif.type == NotificationType.capsule ||
            notif.type == NotificationType.order;
      case _FilterCategory.milestones:
        return notif.type == NotificationType.milestone ||
            notif.type == NotificationType.system ||
            notif.type == NotificationType.cycle;
    }
  }
}

// ─── Flagship Notifications Screen ───────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _FilterCategory _selectedFilter = _FilterCategory.all;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final actions = ref.read(notificationActionsProvider);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient soft top glow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF5252).withValues(
                        alpha: isDark ? 0.16 : 0.08,
                      ),
                      const Color(0xFFFF8F00).withValues(
                        alpha: isDark ? 0.08 : 0.03,
                      ),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── 1. Luxury Interactive Top Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Frosted Squircle Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
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
                              width: 1,
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
                            isRtl
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: textColor,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'ar'
                                  ? 'صندوق التنبيهات'
                                  : (lang == 'fr'
                                      ? 'Notifications'
                                      : 'Notifications'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              unreadCount > 0
                                  ? (lang == 'ar'
                                      ? '$unreadCount تنبيهات جديدة غير مقروءة'
                                      : (lang == 'fr'
                                          ? '$unreadCount non lues'
                                          : '$unreadCount unread'))
                                  : (lang == 'ar'
                                      ? 'جميع التنبيهات مقروءة ومحدثة'
                                      : (lang == 'fr'
                                          ? 'Tout est à jour'
                                          : 'All caught up')),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: unreadCount > 0
                                    ? const Color(0xFFFF5252)
                                    : secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions: Mark All as Read
                      if (unreadCount > 0)
                        IconButton(
                          tooltip: lang == 'ar'
                              ? 'تحديد الكل كمقروء'
                              : (lang == 'fr'
                                  ? 'Tout marquer comme lu'
                                  : 'Mark all as read'),
                          icon: const Icon(
                            Icons.done_all_rounded,
                            size: 22,
                            color: Color(0xFFFF5252),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            actions.markAllAsRead();
                          },
                        ),

                      // Settings Sheet Trigger
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showSettingsSheet(context, isDark, lang);
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
                              width: 1,
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
                            Icons.tune_rounded,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── 2. Content List with Hero & Filters ──
                Expanded(
                  child: notificationsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF5252),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_off_rounded,
                                color: Color(0xFFFF5252),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              lang == 'ar'
                                  ? 'حدث خطأ في تحميل التنبيهات'
                                  : (lang == 'fr'
                                      ? 'Erreur de chargement des notifications'
                                      : 'Failed to load notifications'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang == 'ar'
                                  ? 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.'
                                  : (lang == 'fr'
                                      ? 'Impossible de joindre le serveur. Veuillez vérifier votre connexion.'
                                      : 'Unable to reach the server. Please check your internet connection.'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: secondaryColor,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref.invalidate(notificationsStreamProvider);
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(
                                lang == 'ar'
                                    ? 'إعادة المحاولة'
                                    : (lang == 'fr' ? 'Réessayer' : 'Retry'),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5252),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (notifications) {
                      final filtered = notifications
                          .where((n) => _selectedFilter.matches(n))
                          .toList();

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // ── Hero Section (Home Bento Aesthetic) ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenPaddingH,
                                vertical: 6,
                              ),
                              child: _NotificationsHeroCard(
                                unreadCount: unreadCount,
                                totalCount: notifications.length,
                                isDark: isDark,
                                isRtl: isRtl,
                                lang: lang,
                                onSendTest: () async {
                                  HapticFeedback.mediumImpact();
                                  await FcmService.instance
                                      .sendTestLocalNotification(
                                    title: lang == 'ar'
                                        ? 'تنبيه تجريبي: صحة طفلكِ أولاً 🩺'
                                        : (lang == 'fr'
                                            ? 'Alerte test : Santé de bébé 🩺'
                                            : 'Test Alert: Baby\'s Health First 🩺'),
                                    body: lang == 'ar'
                                        ? 'تم تأكيد وصول الإشعار السحابي بنجاح إلى هاتفكِ!'
                                        : (lang == 'fr'
                                            ? 'Notification push reçue avec succès sur votre appareil !'
                                            : 'Cloud notification received successfully on your device!'),
                                    type: NotificationType.vaccine,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          lang == 'ar'
                                              ? 'تم إرسال إشعار تجريبي بنجاح!'
                                              : (lang == 'fr'
                                                  ? 'Notification test envoyée !'
                                                  : 'Test notification sent successfully!'),
                                        ),
                                        backgroundColor:
                                            const Color(0xFF00C853),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 12)),

                          // ── Category Filter Pills ──
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 42,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenPaddingH,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _FilterCategory.values.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final filter =
                                      _FilterCategory.values[index];
                                  final isSelected =
                                      _selectedFilter == filter;
                                  return _FilterChipWidget(
                                    label: filter.label(lang),
                                    isSelected: isSelected,
                                    isDark: isDark,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _selectedFilter = filter;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 16)),

                          // ── Notification Items List ──
                          if (filtered.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyNotificationsView(
                                isDark: isDark,
                                lang: lang,
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screenPaddingH,
                                0,
                                AppSpacing.screenPaddingH,
                                40,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final notif = filtered[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _NotificationCard(
                                        notification: notif,
                                        isDark: isDark,
                                        isRtl: isRtl,
                                        lang: lang,
                                        onTap: () =>
                                            _handleNotificationTap(notif),
                                        onDismiss: () {
                                          HapticFeedback.lightImpact();
                                          actions
                                              .deleteNotification(notif.id);
                                        },
                                      ),
                                    );
                                  },
                                  childCount: filtered.length,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notif) {
    HapticFeedback.lightImpact();
    // Mark as read
    if (!notif.isRead) {
      ref.read(notificationActionsProvider).markAsRead(notif.id);
    }

    // Deep Link Navigation
    switch (notif.type) {
      case NotificationType.album:
      case NotificationType.order:
        final children = ref.read(childrenProvider).valueOrNull ?? [];
        final child = children.isNotEmpty ? children.first : null;
        if (child != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AlbumTemplatePickerScreen(
                childId: child.id,
                childName: child.name,
              ),
            ),
          );
        }
        break;

      case NotificationType.capsule:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CreateCapsuleScreen(),
          ),
        );
        break;

      case NotificationType.vaccine:
      case NotificationType.milestone:
      case NotificationType.cycle:
      case NotificationType.system:
        // Already marked as read, pop back or let user view details
        break;
    }
  }

  void _showSettingsSheet(BuildContext context, bool isDark, String lang) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationSettingsSheet(
        isDark: isDark,
        lang: lang,
      ),
    );
  }
}

// ─── Hero Section Card ───────────────────────────────────────────────

class _NotificationsHeroCard extends StatelessWidget {
  const _NotificationsHeroCard({
    required this.unreadCount,
    required this.totalCount,
    required this.isDark,
    required this.isRtl,
    required this.lang,
    required this.onSendTest,
  });

  final int unreadCount;
  final int totalCount;
  final bool isDark;
  final bool isRtl;
  final String lang;
  final VoidCallback onSendTest;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF5252);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C1E26), const Color(0xFF24161F)]
              : [const Color(0xFFFFF0F3), const Color(0xFFFFF7F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? coral.withValues(alpha: 0.3)
              : coral.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: coral.withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Floating 3D-like Watermark Bell Icon
            Positioned(
              right: isRtl ? null : -15,
              left: isRtl ? -15 : null,
              bottom: -15,
              child: IgnorePointer(
                child: Icon(
                  Icons.notifications_active_rounded,
                  size: 130,
                  color: coral.withValues(alpha: isDark ? 0.08 : 0.06),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Unread Status Badge + Test Push Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: coral.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pulsing Dot
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: unreadCount > 0
                                    ? coral
                                    : const Color(0xFF00C853),
                                boxShadow: [
                                  BoxShadow(
                                    color: (unreadCount > 0
                                            ? coral
                                            : const Color(0xFF00C853))
                                        .withValues(alpha: 0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              unreadCount > 0
                                  ? (lang == 'ar'
                                      ? '$unreadCount تنبيهات جديدة'
                                      : (lang == 'fr'
                                          ? '$unreadCount nouvelles'
                                          : '$unreadCount new'))
                                  : (lang == 'ar'
                                      ? 'محدث بالكامل'
                                      : (lang == 'fr'
                                          ? 'À jour'
                                          : 'Up to date')),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: coral,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick Test Trigger Pill
                      GestureDetector(
                        onTap: onSendTest,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE8E0E4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 13,
                                color: Color(0xFFFFB300),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                lang == 'ar'
                                    ? 'تجربة إشعار'
                                    : (lang == 'fr'
                                        ? 'Test push'
                                        : 'Test Push'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF24160E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Headline
                  Text(
                    lang == 'ar'
                        ? 'تنبيهاتكِ الذكية والدافئة'
                        : (lang == 'fr'
                            ? 'Vos alertes bienveillantes'
                            : 'Smart Maternal Alerts'),
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF22161A),
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Supportive description
                  Text(
                    lang == 'ar'
                        ? 'متابعة مواعيد التطعيمات، تخليد الذكريات، وتحديثات طفلكِ لحظة بلحظة.'
                        : (lang == 'fr'
                            ? 'Rappels de santé, capsules souvenirs et moments précieux en temps réel.'
                            : 'Vaccine reminders, memory capsules, and child growth updates in real-time.'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF755B64),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Filter Chip ────────────────────────────────────────────

class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF5252);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? coral
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? coral
                : (isDark ? Colors.white10 : const Color(0xFFE8E0E4)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: coral.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? Colors.white70
                      : const Color(0xFF332029)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.isRtl,
    required this.lang,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final bool isDark;
  final bool isRtl;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark
        ? (notification.isRead
            ? const Color(0xFF1E1A22)
            : const Color(0xFF261D26))
        : (notification.isRead
            ? Colors.white
            : const Color(0xFFFFF9FA));

    final accentColor = notification.color;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? Colors.white10 : const Color(0xFFEBE3E8))
                  : accentColor.withValues(alpha: 0.35),
              width: notification.isRead ? 1 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.20 : 0.03,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.lightBgColor(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  notification.icon,
                  size: 22,
                  color: accentColor,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Category tag + Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.getCategoryTitle(lang),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          notification.timeAgo(lang),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    // Body
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Unread Glow Dot
              if (!notification.isRead) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty Notifications View ────────────────────────────────────────

class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView({
    required this.isDark,
    required this.lang,
  });

  final bool isDark;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5252).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 34,
                color: Color(0xFFFF5252),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lang == 'ar'
                  ? 'صندوق التنبيهات هادئ ومريح ✨'
                  : (lang == 'fr'
                      ? 'Aucune notification ✨'
                      : 'No notifications here ✨'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.onSurfaceLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lang == 'ar'
                  ? 'ستصلكِ هنا كل التذكيرات الهامة بصحة طفلكِ واللحظات الجميلة في وقتها المناسب.'
                  : (lang == 'fr'
                      ? 'Toutes les alertes importantes sur la santé et les souvenirs de votre enfant apparaîtront ici.'
                      : 'All important health reminders and sweet moments will appear right here.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Smart Reminders Settings Bottom Sheet ───────────────────────────

class _NotificationSettingsSheet extends ConsumerWidget {
  const _NotificationSettingsSheet({
    required this.isDark,
    required this.lang,
  });

  final bool isDark;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    final cardBg = isDark ? const Color(0xFF241D28) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A22) : const Color(0xFFFAFAFA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationsSmartReminders,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.notificationsSmartRemindersSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 1. Vaccine Reminder Toggle
          _ToggleItemCard(
            cardBg: cardBg,
            textColor: textColor,
            secondaryColor: secondaryColor,
            icon: Icons.vaccines_rounded,
            iconColor: const Color(0xFF00B0FF),
            title: l10n.notificationsVaccineTitle,
            subtitle: l10n.notificationsVaccineSubtitle,
            value: prefs.vaccine,
            onChanged: (v) async {
              await notifier.setVaccine(v);
              AnalyticsService().logEvent('notif_prefs_updated',
                  parameters: {'channel': 'vaccine', 'enabled': v});
            },
          ),

          const SizedBox(height: 10),

          // 2. Milestone Reminder Toggle
          _ToggleItemCard(
            cardBg: cardBg,
            textColor: textColor,
            secondaryColor: secondaryColor,
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFF7C4DFF),
            title: l10n.notificationsMilestoneTitle,
            subtitle: l10n.notificationsMilestoneSubtitle,
            value: prefs.milestone,
            onChanged: (v) async {
              await notifier.setMilestone(v);
              AnalyticsService().logEvent('notif_prefs_updated',
                  parameters: {'channel': 'milestone', 'enabled': v});
            },
          ),

          const SizedBox(height: 10),

          // 3. Mother Cycle Toggle
          _ToggleItemCard(
            cardBg: cardBg,
            textColor: textColor,
            secondaryColor: secondaryColor,
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFE91E63),
            title: l10n.notificationsCycleTitle,
            subtitle: l10n.notificationsCycleSubtitle,
            value: prefs.cycle,
            onChanged: (v) async {
              await notifier.setCycle(v);
              AnalyticsService().logEvent('notif_prefs_updated',
                  parameters: {'channel': 'cycle', 'enabled': v});
            },
          ),

          const SizedBox(height: 20),

          // System notification settings button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                AnalyticsService().logEvent('notif_shortcut_opened');
                try {
                  await const MethodChannel('luckymam/settings')
                      .invokeMethod('openNotificationSettings');
                } catch (e) {
                  debugPrint('openNotificationSettings: $e');
                }
              },
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: Text(
                l10n.notificationsSystemSettings,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItemCard extends StatelessWidget {
  const _ToggleItemCard({
    required this.cardBg,
    required this.textColor,
    required this.secondaryColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Color cardBg;
  final Color textColor;
  final Color secondaryColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? iconColor.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: iconColor,
            activeTrackColor: iconColor.withValues(alpha: 0.5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
