import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_state.dart';
import 'package:lukymam_mvp/features/assistant/models/assistant_models.dart';
import 'package:lukymam_mvp/features/assistant/providers/assistant_providers.dart';
import 'package:lukymam_mvp/features/assistant/services/gemini_assistant_backend.dart';

void main() {
  group('GeminiAssistantBackend', () {
    test('parses reply and every card type', () async {
      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          return {
            'reply': 'Voici mes conseils !',
            'mood': 'proud',
            'cards': [
              {
                'type': 'product',
                'productId': 'p1',
                'name': 'Hochet',
                'priceDZD': 1200,
                'why': 'Favorise la prise en main',
                'imageUrl': 'https://example.com/h.jpg',
              },
              {
                'type': 'appointment',
                'subject': 'child',
                'childAlias': 'enfant 1',
                'title': 'Vaccin 3 mois',
                'suggestedDate': '2026-11-01',
                'reason': 'Calendrier vaccinal national',
              },
              {
                'type': 'album',
                'albumKind': 'predefined',
                'title': 'Mon premier sourire',
                'reason': 'Bébé a 2 mois',
              },
              {
                'type': 'subscription',
                'tier': 'vip',
                'benefit': 'Livraison gratuite 58 wilayas',
              },
              {
                'type': 'weather',
                'summary': 'Ensoleillé',
                'tempC': 21.5,
                'outingIdea': 'Sortie au parc recommandée',
              },
            ],
          };
        },
      );

      final reply = await backend.send(
        history: [],
        message: 'Bonjour',
        locale: 'fr',
      );

      expect(reply.text, 'Voici mes conseils !');
      expect(reply.mood, AssistantMood.proud);
      expect(reply.cards.length, 5);
      expect(reply.cards[0], isA<ProductCard>());
      expect((reply.cards[0] as ProductCard).productId, 'p1');
      expect(reply.cards[1], isA<AppointmentCard>());
      expect(reply.cards[2], isA<AlbumCard>());
      expect(reply.cards[3], isA<SubscriptionCard>());
      expect(reply.cards[4], isA<WeatherCard>());
      expect((reply.cards[4] as WeatherCard).tempC, 21.5);
    });

    test('skips unknown cards', () async {
      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          return {
            'reply': 'Test',
            'cards': [
              {'type': 'unknown_alien_type', 'foo': 'bar'},
              {
                'type': 'album',
                'albumKind': 'standard',
                'title': 'Souvenir',
                'reason': 'R',
              },
            ],
          };
        },
      );

      final reply = await backend.send(
        history: [],
        message: 'Hello',
        locale: 'fr',
      );

      expect(reply.cards.length, 1);
      expect(reply.cards[0], isA<AlbumCard>());
    });

    test('unknown mood becomes neutral', () async {
      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          return {
            'reply': 'Normal text',
            'mood': 'surprised_alien',
          };
        },
      );

      final reply = await backend.send(
        history: [],
        message: 'Hello',
        locale: 'fr',
      );

      expect(reply.mood, AssistantMood.neutral);
    });

    test('sends history without errors and the locale', () async {
      Map<String, dynamic>? receivedPayload;

      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          receivedPayload = payload;
          return {'reply': 'OK'};
        },
      );

      final history = [
        AssistantMessage(
          id: '1',
          role: AssistantRole.user,
          text: 'Msg 1',
          createdAt: DateTime.now(),
        ),
        AssistantMessage(
          id: '2',
          role: AssistantRole.assistant,
          text: 'Erreur',
          createdAt: DateTime.now(),
          isError: true,
        ),
        AssistantMessage(
          id: '3',
          role: AssistantRole.assistant,
          text: 'Reply 1',
          createdAt: DateTime.now(),
        ),
      ];

      await backend.send(
        history: history,
        message: 'Msg 2',
        locale: 'ar',
      );

      expect(receivedPayload, isNotNull);
      expect(receivedPayload!['locale'], 'ar');
      expect(receivedPayload!['message'], 'Msg 2');
      final hist = receivedPayload!['history'] as List;
      expect(hist.length, 2, reason: 'Error messages must be excluded');
      expect(hist[0]['text'], 'Msg 1');
      expect(hist[1]['text'], 'Reply 1');
    });

    test('network failure maps to network', () async {
      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          throw const SocketException('No internet');
        },
      );

      expect(
        () => backend.send(history: [], message: 'Hi', locale: 'fr'),
        throwsA(isA<AssistantException>().having(
          (e) => e.kind,
          'kind',
          AssistantErrorKind.network,
        )),
      );
    });

    test('unavailable maps to friendly message and error mochi', () async {
      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          throw FirebaseFunctionsException(
            code: 'unavailable',
            message: 'Gemini busy',
          );
        },
      );

      final controller = AssistantController(
        backend,
        locale: 'fr',
        speakingDuration: (_) => Duration.zero,
      );

      await controller.send('Hello');

      expect(controller.state.messages.length, 2);
      final errMsg = controller.state.messages[1];
      expect(errMsg.isError, true);
      expect(errMsg.text, 'assistantErrorBusy');
      expect(controller.state.mochi, MochiState.error);
    });

    test('resource-exhausted maps to quota error and ratelimit mochi', () async {
      final backend = GeminiAssistantBackend(
        invoke: (payload) async {
          throw FirebaseFunctionsException(
            code: 'resource-exhausted',
            message: 'Daily quota exceeded',
          );
        },
      );

      final controller = AssistantController(
        backend,
        locale: 'fr',
        speakingDuration: (_) => Duration.zero,
      );

      await controller.send('Hello');

      expect(controller.state.messages.length, 2);
      final errMsg = controller.state.messages[1];
      expect(errMsg.isError, true);
      expect(errMsg.text, 'assistantErrorQuota');
      expect(controller.state.mochi, MochiState.ratelimit);
    });
  });
}
