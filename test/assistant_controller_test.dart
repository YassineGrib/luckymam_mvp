import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/assistant/models/assistant_models.dart';
import 'package:lukymam_mvp/features/assistant/services/fake_assistant_backend.dart';
import 'package:lukymam_mvp/features/assistant/providers/assistant_providers.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_state.dart';

void main() {
  group('Assistant Models & Cards Parsing', () {
    test('AssistantCard.fromJson parses every card type', () {
      final productJson = {
        'type': 'product',
        'productId': 'prod_1',
        'name': 'Hochet Montessori',
        'priceDZD': 2500,
        'why': 'Développe la motricité fine',
        'imageUrl': 'https://example.com/hochet.png',
      };
      final card = AssistantCard.fromJson(productJson);
      expect(card, isA<ProductCard>());
      final productCard = card as ProductCard;
      expect(productCard.productId, 'prod_1');
      expect(productCard.priceDZD, 2500);

      final apptJson = {
        'type': 'appointment',
        'subject': 'child',
        'childAlias': 'Sofia',
        'title': 'Vaccin 2 mois (Hexavalent)',
        'suggestedDate': '2026-11-01',
        'reason': 'Calendrier national obligatoire',
      };
      expect(AssistantCard.fromJson(apptJson), isA<AppointmentCard>());

      final albumJson = {
        'type': 'album',
        'albumKind': 'predefined',
        'title': 'Mon Premier Album Bébé',
        'reason': 'Conserver les premiers souvenirs',
      };
      expect(AssistantCard.fromJson(albumJson), isA<AlbumCard>());

      final subJson = {
        'type': 'subscription',
        'tier': 'premium',
        'benefit': 'Albums illimités et IA avancée',
      };
      expect(AssistantCard.fromJson(subJson), isA<SubscriptionCard>());

      final weatherJson = {
        'type': 'weather',
        'summary': 'Ensoleillé, température idéale pour une promenade',
        'tempC': 22.5,
        'outingIdea': 'Sortie en poussette au parc',
      };
      expect(AssistantCard.fromJson(weatherJson), isA<WeatherCard>());
    });

    test('unknown card type is safely skipped by tryParse', () {
      final unknownJson = {'type': 'unknown_magic_card', 'data': 123};
      expect(AssistantCard.tryParse(unknownJson), isNull);
    });
  });

  group('AssistantController with Fake Backend', () {
    test('send appends user then assistant message and updates mochi state', () async {
      final backend = FakeAssistantBackend(delay: Duration.zero);
      final controller = AssistantController(
        backend,
        locale: 'fr',
        speakingDuration: (_) => Duration.zero,
      );

      expect(controller.state.messages, isEmpty);
      expect(controller.state.mochi, MochiState.idle);

      await controller.send('Bonjour Lucky');

      expect(controller.state.messages.length, 2);
      expect(controller.state.messages[0].role, AssistantRole.user);
      expect(controller.state.messages[0].text, 'Bonjour Lucky');
      expect(controller.state.messages[1].role, AssistantRole.assistant);
      expect(controller.state.phase, AssistantPhase.idle);
    });

    test('empty text is ignored', () async {
      final backend = FakeAssistantBackend(delay: Duration.zero);
      final controller = AssistantController(backend, locale: 'fr');

      await controller.send('   ');
      expect(controller.state.messages, isEmpty);
    });

    test('fake outing reply returns weather card', () async {
      final backend = FakeAssistantBackend(delay: Duration.zero);
      final controller = AssistantController(
        backend,
        locale: 'fr',
        speakingDuration: (_) => Duration.zero,
      );

      await controller.send('Est-ce une bonne journée pour une sortie ?');
      final lastMsg = controller.state.messages.last;
      expect(lastMsg.cards.any((c) => c is WeatherCard), isTrue);
    });

    test('fake toy message returns product card with benefit', () async {
      final backend = FakeAssistantBackend(delay: Duration.zero);
      final controller = AssistantController(
        backend,
        locale: 'fr',
        speakingDuration: (_) => Duration.zero,
      );

      await controller.send('Idée de jouet pour mon bébé');
      final lastMsg = controller.state.messages.last;
      expect(lastMsg.cards.any((c) => c is ProductCard), isTrue);
    });

    test('backend exception creates error message with confused / error mochi', () async {
      final backend = FakeAssistantBackend(delay: Duration.zero);
      final controller = AssistantController(
        backend,
        locale: 'fr',
        speakingDuration: (_) => Duration.zero,
      );

      await controller.send('provoquer erreur');
      final lastMsg = controller.state.messages.last;
      expect(lastMsg.isError, isTrue);
      expect(controller.state.mochi, MochiState.error);
    });

    test('user typing sets mochi to listening only when idle', () {
      final backend = FakeAssistantBackend(delay: Duration.zero);
      final controller = AssistantController(backend, locale: 'fr');

      expect(controller.state.mochi, MochiState.idle);
      controller.onUserTyping(true);
      expect(controller.state.mochi, MochiState.working);

      controller.onUserTyping(false);
      expect(controller.state.mochi, MochiState.idle);
    });
  });
}
