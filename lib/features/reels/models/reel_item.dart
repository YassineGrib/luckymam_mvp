/// Data model representing a single educational reel video.
class ReelItem {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final String author;
  final bool isFavorite;
  final int likeCount;

  const ReelItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
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
  }) {
    return ReelItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      author: author ?? this.author,
      isFavorite: isFavorite ?? this.isFavorite,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
