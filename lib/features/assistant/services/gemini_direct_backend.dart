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

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

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
        ? '''أنتِ "لاكي" (Lucky)، رفيقة الأمومة ومساعدة الأمهات الحنونة والذكية في تطبيق LuckyMam.
- تجيبين بلغة عربية فصحى دافئة وبسيطة ومطمئنة.
- مجالكِ: صحة الأم، نمو الأطفال الرضع، النوم، التغذية، تنظيم الأنشطة والذكريات.
- قواعد الأمان الطبي: لا تقدمين تشخيصات طبية نهائية ولا تغيرين مواعيد الأدوية؛ تنصحين دائماً باستشارة طبيب الأطفال أو الطبيب المتابع عند الشك.
- أسلوب الإجابة: مختصر، عملي، لا يتجاوز 100 كلمة، بنبرة لطيفة مشجعة.'''
        : '''Tu es "Lucky", la compagne intelligente, douce et bienveillante des mamans dans l'application LuckyMam.
- Tu réponds en français simple, chaleureux et empathique.
- Ton domaine : maternité, développement de bébé, sommeil, allaitement, sorties, souvenirs et bien-être maternel.
- Règle de sécurité médicale : tu ne poses jamais de diagnostic médical et tu rappelles avec bienveillance de consulter un médecin ou pédiatre en cas de doute.
- Style : concis, pratique, moins de 100 mots, encourageant et rassurant.''';

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

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'X-goog-api-key': apiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final first = candidates[0] as Map<String, dynamic>;
          final content = first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final replyText = parts[0]['text'] as String? ?? '';
            final mood = _deriveMood(replyText);
            final cards = _deriveContextCards(trimmed, replyText, locale);
            return AssistantReply(
              text: replyText.trim(),
              cards: cards,
              mood: mood,
            );
          }
        }
        throw const AssistantException(
          kind: AssistantErrorKind.unavailable,
          details: 'Empty response from model',
        );
      } else if (response.statusCode == 429) {
        throw const AssistantException(
          kind: AssistantErrorKind.quota,
          details: 'Rate limit exceeded',
        );
      } else {
        throw AssistantException(
          kind: AssistantErrorKind.unavailable,
          details: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on AssistantException {
      rethrow;
    } catch (e) {
      throw AssistantException(
        kind: AssistantErrorKind.network,
        details: e.toString(),
      );
    }
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
}
