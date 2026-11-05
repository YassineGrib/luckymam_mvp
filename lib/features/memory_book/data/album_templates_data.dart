import 'package:flutter/material.dart';

import '../models/album_template.dart';

/// Predefined album templates offered to mothers.
/// Static content in V1 — extensible via CMS/back-office later.
const List<AlbumTemplate> albumTemplates = [
  // ── Modèle 1 Officiel : Album de Naissance (6 photos) ───────────
  AlbumTemplate(
    id: 'tpl_birth',
    titleFr: 'Album de Naissance (6 photos)',
    titleAr: 'ألبوم الولادة (٦ صور)',
    titleEn: 'Birth Album (6 photos)',
    subtitleFr: 'Les tout premiers instants de bébé réunis dans un album',
    subtitleEn: "Baby's very first moments captured together",
    icon: Icons.child_care_rounded,
    gradientColors: [Color(0xFFFF6F91), Color(0xFFFF9A76)],
    isLaunchModel: true,
    isComingSoon: false,
    isSinglePortraitPhoto: false,
    startingPriceDa: 1980,
    supportedFormats: ['A5', 'A4'],
    slots: [
      AlbumEventSlot(
        id: 'birth_first_cry',
        titleFr: 'Premier cri',
        titleAr: 'أول صرخة',
        titleEn: 'First cry',
        descriptionFr: 'Le tout premier instant de bébé dans le monde.',
        descriptionEn: "Baby's very first moment in the world.",
        icon: Icons.favorite_rounded,
        order: 1,
      ),
      AlbumEventSlot(
        id: 'birth_first_feed',
        titleFr: 'Première mise au sein',
        titleAr: 'أول رضاعة',
        titleEn: 'First breastfeed',
        descriptionFr: 'Le premier lien nourricier entre maman et bébé.',
        descriptionEn: 'The first nurturing bond between mother and baby.',
        icon: Icons.child_friendly_rounded,
        order: 2,
      ),
      AlbumEventSlot(
        id: 'birth_bracelet',
        titleFr: 'Bracelet de naissance',
        titleAr: 'سوار الولادة',
        titleEn: 'Birth bracelet',
        descriptionFr: 'Le bracelet d\'identification de la maternité.',
        descriptionEn: 'The hospital identification band.',
        icon: Icons.watch_rounded,
        order: 3,
      ),
      AlbumEventSlot(
        id: 'birth_first_bath',
        titleFr: 'Premier bain',
        titleAr: 'أول حمام',
        titleEn: 'First bath',
        descriptionFr: 'Le premier bain de bébé, tout en douceur.',
        descriptionEn: "Baby's very first bath, gently done.",
        icon: Icons.bathtub_rounded,
        order: 4,
      ),
      AlbumEventSlot(
        id: 'birth_home',
        titleFr: 'Retour à la maison',
        titleAr: 'العودة إلى البيت',
        titleEn: 'Homecoming',
        descriptionFr: 'L\'arrivée de bébé dans son nouveau foyer.',
        descriptionEn: "Baby's arrival at their new home.",
        icon: Icons.home_rounded,
        order: 5,
      ),
      AlbumEventSlot(
        id: 'birth_vaccine',
        titleFr: 'Vaccin de naissance',
        titleAr: 'لقاح الولادة',
        titleEn: 'Birth vaccine',
        descriptionFr: 'Le carnet de santé mis à jour dès le premier jour.',
        descriptionEn: 'Health record updated from day one.',
        icon: Icons.vaccines_rounded,
        order: 6,
      ),
    ],
  ),

  // ── Modèle 2 Officiel : Portrait Souvenir (1 photo portrait) ────
  AlbumTemplate(
    id: 'tpl_portrait_1',
    titleFr: 'Portrait Souvenir (1 photo)',
    titleAr: 'صورة تذكارية (صورة واحدة)',
    titleEn: 'Keepsake Portrait (1 photo)',
    subtitleFr: 'Un portrait unique en grand format pour sublimer un souvenir fort',
    subtitleEn: 'A unique large portrait print celebrating a special memory',
    icon: Icons.portrait_rounded,
    gradientColors: [Color(0xFFE85A71), Color(0xFFFFB085)],
    isLaunchModel: true,
    isComingSoon: false,
    isSinglePortraitPhoto: true,
    startingPriceDa: 440,
    supportedFormats: ['A5', 'A4', 'A3'],
    slots: [
      AlbumEventSlot(
        id: 'portrait_main',
        titleFr: 'Photo portrait souvenir',
        titleAr: 'صورة البورتريه التذكارية',
        titleEn: 'Keepsake portrait photo',
        descriptionFr: 'Votre photo préférée sublimée en tirage portrait haute qualité.',
        descriptionEn: 'Your favorite photo enhanced in high-quality portrait print.',
        icon: Icons.photo_camera_rounded,
        order: 1,
      ),
    ],
  ),

  // ── Thème à Venir : Première Année ──────────────────────────────
  AlbumTemplate(
    id: 'tpl_first_year',
    titleFr: 'Première Année',
    titleAr: 'السنة الأولى',
    titleEn: 'First Year',
    subtitleFr: 'Les grandes étapes de la première année',
    subtitleEn: 'Milestones of the first year',
    icon: Icons.auto_awesome_rounded,
    gradientColors: [Color(0xFF0284C7), Color(0xFF38BDF8)], // Soft ocean blue (Purple ban compliant)
    isLaunchModel: false,
    isComingSoon: true,
    startingPriceDa: 1980,
    supportedFormats: ['A5', 'A4'],
    slots: [
      AlbumEventSlot(
        id: 'year_first_smile',
        titleFr: 'Premier sourire',
        titleAr: 'أول ابتسامة',
        titleEn: 'First smile',
        descriptionFr: 'Le premier sourire social de bébé.',
        descriptionEn: "Baby's first social smile.",
        icon: Icons.mood_rounded,
        order: 1,
      ),
      AlbumEventSlot(
        id: 'year_first_tooth',
        titleFr: 'Premières dents',
        titleAr: 'أول أسنان',
        titleEn: 'First teeth',
        descriptionFr: 'La première petite dent qui pointe.',
        descriptionEn: 'The first little tooth coming through.',
        icon: Icons.sentiment_satisfied_alt_rounded,
        order: 2,
      ),
      AlbumEventSlot(
        id: 'year_first_steps',
        titleFr: 'Premiers pas',
        titleAr: 'الخطوات الأولى',
        titleEn: 'First steps',
        descriptionFr: 'Les premiers pas de bébé, seul(e).',
        descriptionEn: "Baby's first steps, all alone.",
        icon: Icons.directions_walk_rounded,
        order: 3,
      ),
      AlbumEventSlot(
        id: 'year_first_words',
        titleFr: 'Premiers mots',
        titleAr: 'الكلمات الأولى',
        titleEn: 'First words',
        descriptionFr: '« Maman » ou « Papa » — le premier mot.',
        descriptionEn: '« Mama » or « Papa » — the first word.',
        icon: Icons.record_voice_over_rounded,
        order: 4,
      ),
      AlbumEventSlot(
        id: 'year_birthday',
        titleFr: '1er anniversaire',
        titleAr: 'عيد الميلاد الأول',
        titleEn: 'First birthday',
        descriptionFr: 'La grande fête du premier anniversaire.',
        descriptionEn: 'The big celebration of the first birthday.',
        icon: Icons.cake_rounded,
        order: 5,
      ),
    ],
  ),

  // ── Thème à Venir : Aqiqa & Traditions ──────────────────────────
  AlbumTemplate(
    id: 'tpl_traditions',
    titleFr: 'Aqiqa & Traditions',
    titleAr: 'العقيقة والتقاليد',
    titleEn: 'Aqiqa & Traditions',
    subtitleFr: 'Les rites familiaux et religieux',
    subtitleEn: 'Family and religious rituals',
    icon: Icons.mosque_rounded,
    gradientColors: [Color(0xFF00BFA5), Color(0xFF64DD17)],
    isLaunchModel: false,
    isComingSoon: true,
    startingPriceDa: 1210,
    supportedFormats: ['A5', 'A4'],
    slots: [
      AlbumEventSlot(
        id: 'trad_aqiqa',
        titleFr: 'Aqiqa',
        titleAr: 'العقيقة',
        titleEn: 'Aqiqa',
        descriptionFr: 'La tonte du premier cheveu et le repas familial.',
        descriptionEn: 'First hair trim and family meal.',
        icon: Icons.content_cut_rounded,
        order: 1,
      ),
      AlbumEventSlot(
        id: 'trad_circumcision',
        titleFr: 'Circoncision',
        titleAr: 'الختان',
        titleEn: 'Circumcision',
        descriptionFr: 'Le jour de fête en famille.',
        descriptionEn: 'A celebratory day with the family.',
        icon: Icons.celebration_rounded,
        order: 2,
      ),
      AlbumEventSlot(
        id: 'trad_first_eid',
        titleFr: 'Premier Aïd',
        titleAr: 'أول عيد',
        titleEn: 'First Eid',
        descriptionFr: 'La première grande fête religieuse de bébé.',
        descriptionEn: "Baby's first major religious holiday.",
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
