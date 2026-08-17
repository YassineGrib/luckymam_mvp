import 'package:flutter/material.dart';

/// A single event slot within an album template — filled either by
/// attaching an existing capsule or creating a new one.
class AlbumEventSlot {
  final String id;
  final String titleFr;
  final String titleAr;
  final String titleEn;
  final String descriptionFr;
  final String descriptionEn;
  final IconData icon;
  final int order;

  const AlbumEventSlot({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.icon,
    required this.order,
  });

  String getTitle(String locale) {
    if (locale == 'ar') return titleAr;
    if (locale == 'en') return titleEn;
    return titleFr;
  }

  String getDescription(String locale) {
    if (locale == 'ar') {
      // Return description or title if description translations aren't stored
      // Since titleAr is provided, we map it to Arabic description
      // But we can fallback to French description or dynamically map it if needed.
      return descriptionFr; // fallback
    }
    if (locale == 'en') return descriptionEn;
    return descriptionFr;
  }
}

/// A predefined album model: a themed set of life events a mother fills in
/// one by one, either with an existing capsule or a newly captured one.
class AlbumTemplate {
  final String id;
  final String titleFr;
  final String titleAr;
  final String titleEn;
  final String subtitleFr;
  final String subtitleEn;
  final IconData icon;
  final List<Color> gradientColors;
  final List<AlbumEventSlot> slots;

  const AlbumTemplate({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleFr,
    required this.subtitleEn,
    required this.icon,
    required this.gradientColors,
    required this.slots,
  });

  int get slotCount => slots.length;

  String getTitle(String locale) {
    if (locale == 'ar') return titleAr;
    if (locale == 'en') return titleEn;
    return titleFr;
  }

  String getSubtitle(String locale) {
    if (locale == 'ar') {
      // fallback or mapping if subtitleAr not present (currently only subtitleFr is stored)
      // let's return Arabic subtitles mapped here or custom fallback
      switch (id) {
        case 'tpl_birth':
          return 'اللحظات الأولى للطفل';
        case 'tpl_first_year':
          return 'مراحل النمو الكبرى في العام الأول';
        case 'tpl_traditions':
          return 'الطقوس العائلية والدينية';
        default:
          return subtitleFr;
      }
    }
    if (locale == 'en') return subtitleEn;
    return subtitleFr;
  }
}
