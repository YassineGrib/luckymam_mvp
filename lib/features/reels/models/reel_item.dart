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
        return '🔬 Vaccins';
      case ReelCategory.grossessehta:
        return '🫀 Grossesse & HTA';
      case ReelCategory.grossessediabete:
        return '🩸 Grossesse & Diabète';
      case ReelCategory.soutienEnfants:
        return '👨‍👩‍👧 Soutenir ses enfants';
      case ReelCategory.soinsQuotidiens:
        return '👶 Soins quotidiens';
      case ReelCategory.nutrition:
        return '🥗 Nutrition';
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
    this.author = 'Luckymam',
    this.isFavorite = false,
    this.likeCount = 0,
    this.vaccineTags = const [],
  });

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
