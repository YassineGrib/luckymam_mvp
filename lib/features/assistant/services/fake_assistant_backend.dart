import '../models/assistant_models.dart';
import 'assistant_backend.dart';

/// Scripted fake backend for offline demos and widget/unit tests.
class FakeAssistantBackend implements AssistantBackend {
  FakeAssistantBackend({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;

  @override
  Future<AssistantReply> send({
    required List<AssistantMessage> history,
    required String message,
    required String locale,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final lower = message.toLowerCase();

    // Trigger error test
    if (lower.contains('erreur') || lower.contains('error')) {
      throw const AssistantException(
        kind: AssistantErrorKind.unavailable,
        details: 'Simulated backend error',
      );
    }

    // Appointment / Vaccine
    if (lower.contains('vaccin') ||
        lower.contains('rendez-vous') ||
        lower.contains('لقاح') ||
        lower.contains('طبيب')) {
      return AssistantReply(
        text: locale.startsWith('ar')
            ? 'تذكير بموعد اللقاح القادم لطفلك حسب الدفتر الصحي الوطني الجزائري.'
            : 'Voici le prochain vaccin recommandé selon le calendrier vaccinal national.',
        mood: AssistantMood.neutral,
        cards: const [
          AppointmentCard(
            subject: 'child',
            childAlias: 'Sofia',
            title: 'Vaccin 2 mois (Hexavalent + Pneumo)',
            suggestedDate: '2026-11-01',
            reason: 'Protection précoce contre 6 maladies obligatoires',
          ),
        ],
      );
    }

    // Product / Gift / Toy
    if (lower.contains('jouet') ||
        lower.contains('cadeau') ||
        lower.contains('toy') ||
        lower.contains('لعبة') ||
        lower.contains('هدية')) {
      return AssistantReply(
        text: locale.startsWith('ar')
            ? 'إليك لعبة مونتيسوري رائعة لتنمية الذكاء والحواس لدى طفلك.'
            : 'Voici une idée de jouet idéale pour stimuler la motricité de ton enfant.',
        mood: AssistantMood.proud,
        cards: const [
          ProductCard(
            productId: 'hochet_bois_01',
            name: 'Hochet sensoriel en bois naturel',
            priceDZD: 2200,
            why: 'Stimule la préhension volontaire et le développement sensoriel',
          ),
        ],
      );
    }

    // Album
    if (lower.contains('album') ||
        lower.contains('souvenir') ||
        lower.contains('صور') ||
        lower.contains('ألبوم')) {
      return AssistantReply(
        text: locale.startsWith('ar')
            ? 'يمكنك طباعة أجمل ذكريات ومراحل نمو طفلك في ألبوم ورقي فاخر.'
            : 'Créer un album photo souvenir de la première année de ton bébé est un cadeau précieux.',
        mood: AssistantMood.love,
        cards: const [
          AlbumCard(
            albumKind: 'predefined',
            title: 'Mon Premier Livre de Bébé',
            reason: 'Conservez chaque étape clé de sa première année',
          ),
        ],
      );
    }

    // Outing / Weather
    if (lower.contains('sortie') ||
        lower.contains('promenade') ||
        lower.contains('outing') ||
        lower.contains('نزهة') ||
        lower.contains('مطر')) {
      return AssistantReply(
        text: locale.startsWith('ar')
            ? 'الطقس اليوم معتدل ومناسب جداً لنزهة قصيرة مع طفلك في الهواء الطلق.'
            : 'Le temps est doux et très agréable pour une promenade en poussette aujourd’hui.',
        mood: AssistantMood.gentle,
        cards: const [
          WeatherCard(
            summary: '21°C • Ciel dégagé • Vent faible',
            tempC: 21.0,
            outingIdea: 'Balade d’environ 30 minutes avant 11h ou en fin d’après-midi',
          ),
        ],
      );
    }

    // Subscription
    if (lower.contains('abonnement') ||
        lower.contains('premium') ||
        lower.contains('vip') ||
        lower.contains('اشتراك')) {
      return AssistantReply(
        text: locale.startsWith('ar')
            ? 'اكتشفي باقات LuckyMam Premium لحفظ ذكريات لا محدودة وتوصيات مخصصة.'
            : 'Découvre les avantages LuckyMam Premium pour immortaliser tous tes souvenirs.',
        mood: AssistantMood.proud,
        cards: const [
          SubscriptionCard(
            tier: 'premium',
            benefit: 'Albums souvenirs illimités + Réponses prioritaires de l’assistante',
          ),
        ],
      );
    }

    // Default friendly response
    return AssistantReply(
      text: locale.startsWith('ar')
          ? 'أهلاً بك! أنا لاكي، رفيقتك في رحلة الأمومة وتربية طفلك. كيف أستطيع مساعدتك اليوم؟'
          : 'Bonjour ! Je suis Lucky, ton assistante maternité. Comment puis-je t’accompagner aujourd’hui ?',
      mood: AssistantMood.neutral,
    );
  }
}
