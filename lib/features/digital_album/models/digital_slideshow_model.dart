/// A single slide in a digital album slideshow.
class DigitalSlide {
  const DigitalSlide({
    required this.id,
    required this.photoUrl,
    required this.title,
    this.date,
    this.order = 0,
  });

  final String id;
  final String photoUrl;
  final String title;
  final DateTime? date;
  final int order;

  DigitalSlide copyWith({
    String? id,
    String? photoUrl,
    String? title,
    DateTime? date,
    int? order,
  }) {
    return DigitalSlide(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      title: title ?? this.title,
      date: date ?? this.date,
      order: order ?? this.order,
    );
  }
}

/// A complete digital album slideshow configuration for a child.
/// Complies with LM-DIG-001 (EPIC 7) specifications:
/// - Minimum 3 photos, maximum 12 photos
/// - Default cadence: 3.5 seconds per photo
class DigitalSlideshow {
  const DigitalSlideshow({
    required this.childId,
    required this.childName,
    required this.title,
    required this.slides,
    this.durationPerSlide = const Duration(milliseconds: 3500),
  });

  final String childId;
  final String childName;
  final String title;
  final List<DigitalSlide> slides;
  final Duration durationPerSlide;

  bool get isValidCount => slides.length >= minPhotos && slides.length <= maxPhotos;

  static const int minPhotos = 3;
  static const int maxPhotos = 12;
}

