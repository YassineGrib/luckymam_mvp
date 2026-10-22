/// Message sender role.
enum AssistantRole {
  user,
  assistant,
}

/// Emotional tone returned or derived for the assistant response.
enum AssistantMood {
  neutral,
  gentle,
  proud,
  love,
  question,
  thinking,
}

/// Error kinds for assistant failures.
enum AssistantErrorKind {
  quota,
  unavailable,
  network,
  unauthenticated,
  unknown,
}

/// Custom exception for Assistant Backend failures.
class AssistantException implements Exception {
  const AssistantException({
    required this.kind,
    this.details,
  });

  final AssistantErrorKind kind;
  final String? details;

  @override
  String toString() => 'AssistantException($kind, details: $details)';
}

/// Sealed base class for recommendation cards embedded in chat responses.
sealed class AssistantCard {
  const AssistantCard();

  factory AssistantCard.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'product':
        return ProductCard.fromJson(json);
      case 'appointment':
        return AppointmentCard.fromJson(json);
      case 'album':
        return AlbumCard.fromJson(json);
      case 'subscription':
        return SubscriptionCard.fromJson(json);
      case 'weather':
        return WeatherCard.fromJson(json);
      default:
        throw FormatException('Unknown assistant card type: $type');
    }
  }

  static AssistantCard? tryParse(Map<String, dynamic> json) {
    try {
      return AssistantCard.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson();
}

/// Product recommendation card.
class ProductCard extends AssistantCard {
  const ProductCard({
    required this.productId,
    required this.name,
    required this.priceDZD,
    required this.why,
    this.imageUrl,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceDZD: (json['priceDZD'] as num?)?.toInt() ?? 0,
      why: json['why'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String productId;
  final String name;
  final int priceDZD;
  final String why;
  final String? imageUrl;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'product',
        'productId': productId,
        'name': name,
        'priceDZD': priceDZD,
        'why': why,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

/// Medical / Vaccine / Doctor appointment recommendation card.
class AppointmentCard extends AssistantCard {
  const AppointmentCard({
    required this.subject,
    this.childAlias,
    required this.title,
    this.suggestedDate,
    required this.reason,
  });

  factory AppointmentCard.fromJson(Map<String, dynamic> json) {
    return AppointmentCard(
      subject: json['subject'] as String? ?? 'child',
      childAlias: json['childAlias'] as String?,
      title: json['title'] as String? ?? '',
      suggestedDate: json['suggestedDate'] as String?,
      reason: json['reason'] as String? ?? '',
    );
  }

  final String subject; // 'child' | 'mother'
  final String? childAlias;
  final String title;
  final String? suggestedDate;
  final String reason;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'appointment',
        'subject': subject,
        if (childAlias != null) 'childAlias': childAlias,
        'title': title,
        if (suggestedDate != null) 'suggestedDate': suggestedDate,
        'reason': reason,
      };
}

/// Memory album creation recommendation card.
class AlbumCard extends AssistantCard {
  const AlbumCard({
    required this.albumKind,
    required this.title,
    required this.reason,
  });

  factory AlbumCard.fromJson(Map<String, dynamic> json) {
    return AlbumCard(
      albumKind: json['albumKind'] as String? ?? 'standard',
      title: json['title'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  final String albumKind; // 'predefined' | 'standard'
  final String title;
  final String reason;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'album',
        'albumKind': albumKind,
        'title': title,
        'reason': reason,
      };
}

/// Plan upgrade recommendation card.
class SubscriptionCard extends AssistantCard {
  const SubscriptionCard({
    required this.tier,
    required this.benefit,
  });

  factory SubscriptionCard.fromJson(Map<String, dynamic> json) {
    return SubscriptionCard(
      tier: json['tier'] as String? ?? 'premium',
      benefit: json['benefit'] as String? ?? '',
    );
  }

  final String tier; // 'premium' | 'vip'
  final String benefit;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'subscription',
        'tier': tier,
        'benefit': benefit,
      };
}

/// Weather & Outing advice card.
class WeatherCard extends AssistantCard {
  const WeatherCard({
    required this.summary,
    required this.tempC,
    required this.outingIdea,
  });

  factory WeatherCard.fromJson(Map<String, dynamic> json) {
    return WeatherCard(
      summary: json['summary'] as String? ?? '',
      tempC: (json['tempC'] as num?)?.toDouble() ?? 20.0,
      outingIdea: json['outingIdea'] as String? ?? '',
    );
  }

  final String summary;
  final double tempC;
  final String outingIdea;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'weather',
        'summary': summary,
        'tempC': tempC,
        'outingIdea': outingIdea,
      };
}

/// Single chat message.
class AssistantMessage {
  const AssistantMessage({
    required this.id,
    required this.role,
    required this.text,
    this.cards = const [],
    required this.createdAt,
    this.isError = false,
  });

  final String id;
  final AssistantRole role;
  final String text;
  final List<AssistantCard> cards;
  final DateTime createdAt;
  final bool isError;
}

/// Reply packet returned by the AssistantBackend.
class AssistantReply {
  const AssistantReply({
    required this.text,
    this.cards = const [],
    this.mood = AssistantMood.neutral,
  });

  final String text;
  final List<AssistantCard> cards;
  final AssistantMood mood;
}
