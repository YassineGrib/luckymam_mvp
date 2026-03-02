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

  const ReelItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.category,
    this.author = 'Luckymam',
    this.isFavorite = false,
    this.likeCount = 0,
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
    );
  }
}
