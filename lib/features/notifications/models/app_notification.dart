import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Notification categories for LuckyMam
enum NotificationType {
  vaccine,
  capsule,
  album,
  milestone,
  cycle,
  order,
  system;

  static NotificationType fromString(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Rich notification data model representing inbox alerts in LuckyMam.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic> payload;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.payload = const {},
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? payload,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final timestamp = data['createdAt'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      createdAt: date,
      type: NotificationType.fromString(data['type']),
      isRead: data['isRead'] ?? false,
      payload: Map<String, dynamic>.from(data['payload'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type.name,
      'isRead': isRead,
      'payload': payload,
    };
  }

  // ─── Visual Tokens & Aesthetics ───

  IconData get icon {
    switch (type) {
      case NotificationType.vaccine:
        return Icons.vaccines_rounded;
      case NotificationType.capsule:
        return Icons.photo_library_rounded;
      case NotificationType.album:
        return Icons.auto_stories_rounded;
      case NotificationType.milestone:
        return Icons.stars_rounded;
      case NotificationType.cycle:
        return Icons.favorite_rounded;
      case NotificationType.order:
        return Icons.local_shipping_rounded;
      case NotificationType.system:
        return Icons.notifications_active_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.vaccine:
        return const Color(0xFF00B0FF); // Medical vibrant cyan-blue
      case NotificationType.capsule:
        return const Color(0xFFFF5252); // Memory rose/coral
      case NotificationType.album:
        return const Color(0xFFFF9100); // VIP Amber gold
      case NotificationType.milestone:
        return const Color(0xFF7C4DFF); // Milestone deep violet
      case NotificationType.cycle:
        return const Color(0xFFE91E63); // Cycle feminine pink
      case NotificationType.order:
        return const Color(0xFF00C853); // Print/Order Emerald green
      case NotificationType.system:
        return const Color(0xFFFF8F00); // Warm sunshine
    }
  }

  Color lightBgColor(bool isDark) {
    if (isDark) {
      return color.withValues(alpha: 0.16);
    }
    return color.withValues(alpha: 0.10);
  }

  String getCategoryTitle(String lang) {
    switch (type) {
      case NotificationType.vaccine:
        return lang == 'ar' ? 'اللقاحات والصحة' : (lang == 'fr' ? 'Santé & Vaccins' : 'Health & Vaccines');
      case NotificationType.capsule:
        return lang == 'ar' ? 'كبسولة ذكريات' : (lang == 'fr' ? 'Capsule Souvenir' : 'Memory Capsule');
      case NotificationType.album:
        return lang == 'ar' ? 'ألبوم الذكريات' : (lang == 'fr' ? 'Livre Photo' : 'Photobook');
      case NotificationType.milestone:
        return lang == 'ar' ? 'معلم تطور' : (lang == 'fr' ? 'Étape Clé' : 'Milestone');
      case NotificationType.cycle:
        return lang == 'ar' ? 'دورة الأم' : (lang == 'fr' ? 'Cycle Féminin' : 'Cycle');
      case NotificationType.order:
        return lang == 'ar' ? 'الطباعة والشحن' : (lang == 'fr' ? 'Impression' : 'Print & Order');
      case NotificationType.system:
        return lang == 'ar' ? 'تنبيه النظام' : (lang == 'fr' ? 'Système' : 'System');
    }
  }

  String timeAgo(String lang) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return lang == 'ar' ? 'الآن' : (lang == 'fr' ? 'À l\'instant' : 'Just now');
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return lang == 'ar' ? 'منذ $m د' : (lang == 'fr' ? 'Il y a $m min' : '${m}m ago');
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return lang == 'ar' ? 'منذ $h س' : (lang == 'fr' ? 'Il y a $h h' : '${h}h ago');
    }
    if (diff.inDays == 1) {
      return lang == 'ar' ? 'أمس' : (lang == 'fr' ? 'Hier' : 'Yesterday');
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return lang == 'ar' ? 'منذ $d أيام' : (lang == 'fr' ? 'Il y a $d j' : '${d}d ago');
    }
    return '${createdAt.day}/${createdAt.month}';
  }
}
