import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assistant_models.dart';
import 'assistant_backend.dart';

/// Direct Gemini REST backend calling the Google Generative Language API.
/// Incorporates immediate medical emergency detection (Red Flags) and
/// maternal safety guardrails.
class GeminiDirectBackend implements AssistantBackend {
  GeminiDirectBackend({
    this.apiKey = 'AQ.Ab8RN6JvumK4zJjp79adjnlYk4KvvjW26e0nlJp31NUKcGAVLg',
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const List<String> _models = [
    'gemini-flash-lite-latest',
    'gemini-flash-latest',
  ];

  static String _endpointFor(String model) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

  @override
  Future<AssistantReply> send({
    required List<AssistantMessage> history,
    required String message,
    required String locale,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return const AssistantReply(text: '');
    }

    // 1. Medical Emergency / Red Flag Check (Instant escalation without model call)
    final redFlagReply = _checkRedFlags(trimmed, locale);
    if (redFlagReply != null) {
      return redFlagReply;
    }

    // 2. Build Gemini contents payload with history
    final contents = <Map<String, dynamic>>[];

    // Add recent history (up to last 10 non-error messages)
    final validHistory = history.where((m) => !m.isError).toList();
    final startIdx = validHistory.length > 10 ? validHistory.length - 10 : 0;
    for (int i = startIdx; i < validHistory.length; i++) {
      final msg = validHistory[i];
      contents.add({
        'role': msg.role == AssistantRole.user ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': trimmed}
      ],
    });

    final isArabic = locale.startsWith('ar');
    final systemPrompt = isArabic
        ? '''أنتِ "لاكي" (Lucky)، رفيقة ومساعدة الأمهات الحنونة والذكية في تطبيق LuckyMam.
تعليمات أسلوب الكلام الصارمة (طبيعي وبشري 100%):
- تحدثي بنبرة إنسانية دافئة وبسيطة جداً كأم حكيمة أو أخصائية حنونة تتحدث مباشرة إلى الأم.
- ممنوع منعاً باتاً استخدام علامات النجوم (* أو **) أو الكلمات العريضة (bold).
- ممنوع منعاً باتاً استخدام القوائم النقطية (- أو * أو •) أو التعدادات الرقمية الآلية.
- ممنوع استخدام العناوين أو الرموز الروبوتية.
- لا تضعي إيموجيز بكثرة، اكتفي بإيموجي لطيف واحد على الأكثر أو بدون إيموجيز.
- اكتبي في فقرة واحدة أو فقرتين قصيرتين ومترابطتين بانسيابية شفهية طبيعية جداً.
- مجالكِ: صحة الأم، نمو الأطفال الرضع، النوم، التغذية، تنظيم الأنشطة والذكريات.
- قواعد الأمان الطبي: لا تقدمين تشخيصات طبية نهائية وتنصحين دائماً بلطف بمراجعة الطبيب عند الشك.
- الطول: مختصر ومفيد، في حدود 40 إلى 70 كلمة فقط.'''
        : '''Tu es "Lucky", la compagne intelligente, douce et bienveillante des mamans dans l'application LuckyMam.
Directives impératives de style (100% naturel et humain) :
- Réponds avec une voix humaine, chaleureuse, naturelle et fluide, comme une amie bienveillante ou une sage-femme attentionnée qui parle directement à la maman.
- INTERDICTION FORMELLE d'utiliser des astérisques (* ou **), du gras markdown, ou des titres (###).
- INTERDICTION FORMELLE d'utiliser des listes à puces (- ou * ou •) ou des énumérations robotiques.
- Ne mets pas d'emojis en abondance, un seul emoji doux au maximum ou aucun.
- Écris des phrases fluides et directes en 1 ou 2 courts paragraphes naturels.
- Domaine : maternité, développement de bébé, sommeil, allaitement, sorties, souvenirs.
- Sécurité médicale : ne pose jamais de diagnostic formel et rappelle avec douceur de consulter un pédiatre en cas de doute.
- Longueur : concise et réconfortante, entre 40 et 70 mots.''';

    final body = jsonEncode({
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ],
      },
      'generationConfig': {
        'temperature': 0.65,
        'maxOutputTokens': 600,
      },
    });

    Exception? lastError;

    for (final model in _models) {
      try {
        final response = await _client
            .post(
              Uri.parse(_endpointFor(model)),
              headers: {
                'Content-Type': 'application/json',
                'X-goog-api-key': apiKey,
              },
              body: body,
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final first = candidates[0] as Map<String, dynamic>;
            final content = first['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final rawReply = parts[0]['text'] as String? ?? '';
              final replyText = _cleanOutputText(rawReply);
              final mood = _deriveMood(replyText);
              final cards = _deriveContextCards(trimmed, replyText, locale);
              return AssistantReply(
                text: replyText,
                cards: cards,
                mood: mood,
              );
            }
          }
          continue;
        } else if (response.statusCode == 429) {
          lastError = const AssistantException(
            kind: AssistantErrorKind.quota,
            details: 'Rate limit exceeded',
          );
          continue;
        } else {
          lastError = AssistantException(
            kind: AssistantErrorKind.unavailable,
            details: 'HTTP ${response.statusCode}: ${response.body}',
          );
          continue;
        }
      } catch (e) {
        lastError = AssistantException(
          kind: AssistantErrorKind.network,
          details: e.toString(),
        );
        continue;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    throw const AssistantException(kind: AssistantErrorKind.unavailable);
  }

  /// Emergency detection for symptoms requiring immediate medical evaluation.
  AssistantReply? _checkRedFlags(String text, String locale) {
    final lower = text.toLowerCase();
    final isAr = locale.startsWith('ar');

    final hasBleeding = lower.contains('saignement') ||
        lower.contains('sang abondant') ||
        lower.contains('نزيف') ||
        lower.contains('دم كثير');
    final hasNoMovement = lower.contains('ne bouge plus') ||
        lower.contains('pas de mouvement') ||
        lower.contains('حركة الجنين') ||
        lower.contains('توقف الحركة');
    final hasNewbornFever = (lower.contains('fièvre') || lower.contains('حرارة') || lower.contains('حمى')) &&
        (lower.contains('nouveau-né') || lower.contains('bébé') || lower.contains('رضيع'));
    final hasBreathingIssue = lower.contains('respire pas') ||
        lower.contains('étouffement') ||
        lower.contains('ضيق تنفس') ||
        lower.contains('اختناق');

    if (hasBleeding || hasNoMovement || hasNewbornFever || hasBreathingIssue) {
      final msg = isAr
          ? '⚠️ تنبيه طبي هام: هذه الأعراض تتطلب فحصاً طبياً فورياً من الطبيب أو التوجه إلى قسم الطوارئ (14 أو 15) في أسرع وقت. سلامتكِ وسلامة طفلك هي الأولوية القصوى.'
          : '⚠️ Alerte médicale : ce symptôme nécessite un avis médical urgent. Contacte immédiatement ton médecin ou rends-toi aux urgences (14 / 15). Prends bien soin de toi et de ton bébé.';
      return AssistantReply(
        text: msg,
        cards: const [],
        mood: AssistantMood.gentle,
      );
    }
    return null;
  }

  AssistantMood _deriveMood(String text) {
    if (text.trim().endsWith('?')) return AssistantMood.question;
    final lower = text.toLowerCase();
    if (lower.contains('félicitation') ||
        lower.contains('bravo') ||
        lower.contains('أحسنت') ||
        lower.contains('مبارك')) {
      return AssistantMood.proud;
    }
    if (lower.contains('courage') ||
        lower.contains('repos') ||
        lower.contains('اطمئني') ||
        lower.contains('راحة')) {
      return AssistantMood.gentle;
    }
    return AssistantMood.neutral;
  }

  List<AssistantCard> _deriveContextCards(
    String userQuery,
    String replyText,
    String locale,
  ) {
    final lower = '$userQuery $replyText'.toLowerCase();
    final cards = <AssistantCard>[];

    // Vaccine / Medical appointment
    if (lower.contains('vaccin') || lower.contains('لقاح')) {
      cards.add(
        const AppointmentCard(
          subject: 'child',
          childAlias: 'Bébé',
          title: 'Calendrier des vaccins',
          suggestedDate: 'Consulter le carnet',
          reason: 'Vérification des rappels recommandés',
        ),
      );
    }

    // Outing / Weather
    if (lower.contains('promenade') ||
        lower.contains('sortie') ||
        lower.contains('météo') ||
        lower.contains('نزهة') ||
        lower.contains('طقس')) {
      cards.add(
        const WeatherCard(
          summary: 'Température clémente • Ciel calme',
          tempC: 22.0,
          outingIdea: 'Promenade de 30 minutes au soleil doux',
        ),
      );
    }

    return cards;
  }

  /// Sanitizes raw LLM output to produce natural, human, continuous conversational text
  /// free from markdown asterisks, robotic bullet dashes, and headers.
  static String _cleanOutputText(String raw) {
    var text = raw.trim();
    // Strip markdown bold and italic formatting asterisks (** and *)
    text = text.replaceAll('**', '').replaceAll('*', '');
    // Strip markdown header syntax (###, ##, #)
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    // Strip bullet dashes, bullet points or list markers (- , * , • ) at line beginnings
    text = text.replaceAll(RegExp(r'^[ \t]*[\-\•\–\—]\s+', multiLine: true), '');
    // Replace numbered lists like "1. ", "2. " with natural flow
    text = text.replaceAll(RegExp(r'^[ \t]*\d+[\.\)]\s+', multiLine: true), '');
    // Remove excessive newlines (max 2 consecutive newlines)
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }
}
