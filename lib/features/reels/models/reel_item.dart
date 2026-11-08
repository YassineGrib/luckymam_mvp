import 'legacy_reel_translations.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Category for educational reels
enum ReelCategory {
  vaccins,
  grossessehta,
  grossessediabete,
  soutienEnfants,
  soinsQuotidiens,
  nutrition,
}

extension ReelCategoryExtension on ReelCategory {
  String get labelFr {
    switch (this) {
      case ReelCategory.vaccins:
        return 'Vaccins';
      case ReelCategory.grossessehta:
        return 'Grossesse & HTA';
      case ReelCategory.grossessediabete:
        return 'Grossesse & Diabète';
      case ReelCategory.soutienEnfants:
        return 'Soutenir ses enfants';
      case ReelCategory.soinsQuotidiens:
        return 'Soins quotidiens';
      case ReelCategory.nutrition:
        return 'Nutrition';
    }
  }

  String get shortLabel {
    switch (this) {
      case ReelCategory.vaccins:
        return 'Vaccins';
      case ReelCategory.grossessehta:
        return 'Grossesse & HTA';
      case ReelCategory.grossessediabete:
        return 'Grossesse & Diabète';
      case ReelCategory.soutienEnfants:
        return 'Soutien';
      case ReelCategory.soinsQuotidiens:
        return 'Soins';
      case ReelCategory.nutrition:
        return 'Nutrition';
    }
  }

  IconData get icon {
    switch (this) {
      case ReelCategory.vaccins:
        return Icons.medical_services_rounded;
      case ReelCategory.grossessehta:
        return Icons.favorite_rounded;
      case ReelCategory.grossessediabete:
        return Icons.bloodtype_rounded;
      case ReelCategory.soutienEnfants:
        return Icons.family_restroom_rounded;
      case ReelCategory.soinsQuotidiens:
        return Icons.child_care_rounded;
      case ReelCategory.nutrition:
        return Icons.restaurant_rounded;
    }
  }

  String get emoji {
    switch (this) {
      case ReelCategory.vaccins:
        return '🔬';
      case ReelCategory.grossessehta:
        return '🫀';
      case ReelCategory.grossessediabete:
        return '🩸';
      case ReelCategory.soutienEnfants:
        return '👨‍👩‍👧';
      case ReelCategory.soinsQuotidiens:
        return '👶';
      case ReelCategory.nutrition:
        return '🥗';
    }
  }

  String shortLabelL10n(AppLocalizations l10n) {
    switch (this) {
      case ReelCategory.vaccins:
        return l10n.reelCategoryVaccins;
      case ReelCategory.grossessehta:
        return l10n.reelCategoryGrossesseHta;
      case ReelCategory.grossessediabete:
        return l10n.reelCategoryGrossesseDiabete;
      case ReelCategory.soutienEnfants:
        return l10n.reelCategorySoutien;
      case ReelCategory.soinsQuotidiens:
        return l10n.reelCategorySoins;
      case ReelCategory.nutrition:
        return l10n.reelCategoryNutrition;
    }
  }
}

/// Data model representing a single educational reel video.
class ReelItem {
  final String id;
  final String title;
  final String description;
  final Map<String, String> titles;
  final Map<String, String> descriptions;
  final String assetPath;
  final String author;
  final bool isFavorite;
  final int likeCount;
  final ReelCategory category;

  /// Vaccine codes this reel is relevant to (e.g. 'BCG', 'ROR'), used to
  /// filter reels opened from a specific vaccine's fiche. Empty for reels
  /// not tied to a specific vaccine.
  final List<String> vaccineTags;

  const ReelItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.category,
    this.titles = const {},
    this.descriptions = const {},
    this.author = 'Luckymam',
    this.isFavorite = false,
    this.likeCount = 0,
    this.vaccineTags = const [],
  });

  String titleFor(String language) =>
      titles[language] ?? legacyReelText(id, language, 'title') ?? title;
  String descriptionFor(String language) =>
      descriptions[language] ??
      legacyReelText(id, language, 'description') ??
      description;

  factory ReelItem.fromMap(String id, Map<String, dynamic> data) {
    String text(dynamic value, [String fallback = '']) =>
        value is String ? value : fallback;
    Map<String, String> localized(String field) {
      final result = <String, String>{};
      for (final lang in ['fr', 'en', 'ar']) {
        final suffix = '${lang[0].toUpperCase()}${lang.substring(1)}';
        final translations = data['translations'];
        final nested = translations is Map ? translations[lang] : null;
        final raw = data[field];
        final value = text(
          data['$field$suffix'],
          text(
            data['${field}_$lang'],
            text(
              nested is Map ? nested[field] : null,
              text(raw is Map ? raw[lang] : null),
            ),
          ),
        );
        if (value.trim().isNotEmpty) result[lang] = value;
      }
      return result;
    }

    final titles = localized('title');
    final descriptions = localized('description');
    final likes = data['likeCount'] ?? data['likes'];
    final creator = data['creator'];
    return ReelItem(
      id: id,
      title: text(
        data['title'],
        titles['fr'] ?? titles.values.firstOrNull ?? '',
      ),
      description: text(
        data['description'],
        descriptions['fr'] ?? descriptions.values.firstOrNull ?? '',
      ),
      titles: titles,
      descriptions: descriptions,
      assetPath: text(data['assetPath']),
      author: text(
        data['author'],
        text(creator is Map ? creator['name'] : null, 'Luckymam'),
      ),
      category: ReelCategory.values.firstWhere(
        (c) => c.name == (data['category'] ?? data['topic']),
        orElse: () => ReelCategory.vaccins,
      ),
      likeCount: likes is num ? likes.toInt() : int.tryParse('$likes') ?? 0,
      vaccineTags: data['vaccineTags'] is List
          ? (data['vaccineTags'] as List).whereType<String>().toList()
          : const [],
    );
  }

  ReelItem copyWith({
    String? id,
    String? title,
    String? description,
    String? assetPath,
    String? author,
    bool? isFavorite,
    int? likeCount,
    ReelCategory? category,
    List<String>? vaccineTags,
  }) {
    return ReelItem(
      titles: titles,
      descriptions: descriptions,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      author: author ?? this.author,
      isFavorite: isFavorite ?? this.isFavorite,
      likeCount: likeCount ?? this.likeCount,
      category: category ?? this.category,
      vaccineTags: vaccineTags ?? this.vaccineTags,
    );
  }
}
