import 'package:flutter/material.dart';

import '../models/album_template.dart';

/// Predefined album templates offered to mothers.
/// Static content in V1 — extensible via CMS/back-office later.
const List<AlbumTemplate> albumTemplates = [
  AlbumTemplate(
    id: 'tpl_birth',
    titleFr: 'Album de Naissance',
    titleAr: 'ألبوم الولادة',
    subtitleFr: 'Les tout premiers instants de bébé',
    icon: Icons.child_care_rounded,
    gradientColors: [Color(0xFFFF6F91), Color(0xFFFF9A76)],
    slots: [
      AlbumEventSlot(
        id: 'birth_first_cry',
        titleFr: 'Premier cri',
        titleAr: 'أول صرخة',
        descriptionFr: 'Le tout premier instant de bébé dans le monde.',
        icon: Icons.favorite_rounded,
        order: 1,
      ),
      AlbumEventSlot(
        id: 'birth_first_feed',
        titleFr: 'Première mise au sein',
        titleAr: 'أول رضاعة',
        descriptionFr: 'Le premier lien nourricier entre maman et bébé.',
        icon: Icons.child_friendly_rounded,
        order: 2,
      ),
      AlbumEventSlot(
        id: 'birth_bracelet',
        titleFr: 'Bracelet de naissance',
        titleAr: 'سوار الولادة',
        descriptionFr: 'Le bracelet d\'identification de la maternité.',
        icon: Icons.watch_rounded,
        order: 3,
      ),
      AlbumEventSlot(
        id: 'birth_first_bath',
        titleFr: 'Premier bain',
        titleAr: 'أول حمام',
        descriptionFr: 'Le premier bain de bébé, tout en douceur.',
        icon: Icons.bathtub_rounded,
        order: 4,
      ),
      AlbumEventSlot(
        id: 'birth_home',
        titleFr: 'Retour à la maison',
        titleAr: 'العودة إلى البيت',
        descriptionFr: 'L\'arrivée de bébé dans son nouveau foyer.',
        icon: Icons.home_rounded,
        order: 5,
      ),
      AlbumEventSlot(
        id: 'birth_vaccine',
        titleFr: 'Vaccin de naissance',
        titleAr: 'لقاح الولادة',
        descriptionFr: 'Le carnet de santé mis à jour dès le premier jour.',
        icon: Icons.vaccines_rounded,
        order: 6,
      ),
    ],
  ),
  AlbumTemplate(
    id: 'tpl_first_year',
    titleFr: 'Première Année',
    titleAr: 'السنة الأولى',
    subtitleFr: 'Les grandes étapes de la première année',
    icon: Icons.auto_awesome_rounded,
    gradientColors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    slots: [
      AlbumEventSlot(
        id: 'year_first_smile',
        titleFr: 'Premier sourire',
        titleAr: 'أول ابتسامة',
        descriptionFr: 'Le premier sourire social de bébé.',
        icon: Icons.mood_rounded,
        order: 1,
      ),
      AlbumEventSlot(
        id: 'year_first_tooth',
        titleFr: 'Premières dents',
        titleAr: 'أول أسنان',
        descriptionFr: 'La première petite dent qui pointe.',
        icon: Icons.sentiment_satisfied_alt_rounded,
        order: 2,
      ),
      AlbumEventSlot(
        id: 'year_first_steps',
        titleFr: 'Premiers pas',
        titleAr: 'الخطوات الأولى',
        descriptionFr: 'Les premiers pas de bébé, seul(e).',
        icon: Icons.directions_walk_rounded,
        order: 3,
      ),
      AlbumEventSlot(
        id: 'year_first_words',
        titleFr: 'Premiers mots',
        titleAr: 'الكلمات الأولى',
        descriptionFr: '« Maman » ou « Papa » — le premier mot.',
        icon: Icons.record_voice_over_rounded,
        order: 4,
      ),
      AlbumEventSlot(
        id: 'year_birthday',
        titleFr: '1er anniversaire',
        titleAr: 'عيد الميلاد الأول',
        descriptionFr: 'La grande fête du premier anniversaire.',
        icon: Icons.cake_rounded,
        order: 5,
      ),
    ],
  ),
  AlbumTemplate(
    id: 'tpl_traditions',
    titleFr: 'Aqiqa & Traditions',
    titleAr: 'العقيقة والتقاليد',
    subtitleFr: 'Les rites familiaux et religieux',
    icon: Icons.mosque_rounded,
    gradientColors: [Color(0xFF00BFA5), Color(0xFF64DD17)],
    slots: [
      AlbumEventSlot(
        id: 'trad_aqiqa',
        titleFr: 'Aqiqa',
        titleAr: 'العقيقة',
        descriptionFr: 'La tonte du premier cheveu et le repas familial.',
        icon: Icons.content_cut_rounded,
        order: 1,
      ),
      AlbumEventSlot(
        id: 'trad_circumcision',
        titleFr: 'Circoncision',
        titleAr: 'الختان',
        descriptionFr: 'Le jour de fête en famille.',
        icon: Icons.celebration_rounded,
        order: 2,
      ),
      AlbumEventSlot(
        id: 'trad_first_eid',
        titleFr: 'Premier Aïd',
        titleAr: 'أول عيد',
        descriptionFr: 'La première grande fête religieuse de bébé.',
        icon: Icons.star_rounded,
        order: 3,
      ),
    ],
  ),
];

/// Lookup a template by its id.
AlbumTemplate? findAlbumTemplate(String templateId) {
  for (final t in albumTemplates) {
    if (t.id == templateId) return t;
  }
  return null;
}
