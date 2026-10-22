import 'dart:async';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/assistant_models.dart';
import 'assistant_backend.dart';

typedef CallableInvoker = Future<Map<String, dynamic>> Function(Map<String, dynamic> payload);

/// Implementation of [AssistantBackend] talking to the `aiChat` Cloud Function.
class GeminiAssistantBackend implements AssistantBackend {
  GeminiAssistantBackend({CallableInvoker? invoke})
      : _invoke = invoke ?? _defaultInvoker;

  final CallableInvoker _invoke;

  static Future<Map<String, dynamic>> _defaultInvoker(Map<String, dynamic> payload) async {
    final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('aiChat', options: HttpsCallableOptions(timeout: const Duration(seconds: 65)));
    final result = await callable.call<Map<String, dynamic>>(payload);
    return Map<String, dynamic>.from(result.data);
  }

  @override
  Future<AssistantReply> send({
    required List<AssistantMessage> history,
    required String message,
    required String locale,
  }) async {
    final mappedHistory = history
        .where((m) => !m.isError)
        .map((m) => {
              'role': m.role == AssistantRole.assistant ? 'assistant' : 'user',
              'text': m.text,
            })
        .toList();

    try {
      final res = await _invoke({
        'message': message,
        'locale': locale,
        'history': mappedHistory,
      });

      final replyText = res['reply'] as String? ?? '';
      final rawCards = res['cards'] as List<dynamic>? ?? const [];
      final cards = <AssistantCard>[];
      for (final raw in rawCards) {
        if (raw is Map) {
          final card = AssistantCard.tryParse(Map<String, dynamic>.from(raw));
          if (card != null) {
            cards.add(card);
          }
        }
      }

      final moodStr = res['mood'] as String?;
      final mood = _parseMood(moodStr);

      return AssistantReply(
        text: replyText,
        cards: cards,
        mood: mood,
      );
    } on FirebaseFunctionsException catch (e) {
      throw _mapFirebaseFunctionsException(e);
    } catch (e) {
      if (e is AssistantException) rethrow;
      if (e is SocketException || e is TimeoutException) {
        throw const AssistantException(kind: AssistantErrorKind.network);
      }
      throw const AssistantException(kind: AssistantErrorKind.unknown);
    }
  }

  static AssistantMood _parseMood(String? moodStr) {
    switch (moodStr) {
      case 'gentle':
        return AssistantMood.gentle;
      case 'proud':
        return AssistantMood.proud;
      case 'love':
        return AssistantMood.love;
      case 'question':
        return AssistantMood.question;
      case 'thinking':
        return AssistantMood.thinking;
      case 'neutral':
      default:
        return AssistantMood.neutral;
    }
  }

  static AssistantException _mapFirebaseFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'resource-exhausted':
        return const AssistantException(kind: AssistantErrorKind.quota);
      case 'unavailable':
      case 'deadline-exceeded':
        return const AssistantException(kind: AssistantErrorKind.unavailable);
      case 'unauthenticated':
        return const AssistantException(kind: AssistantErrorKind.unauthenticated);
      case 'unknown':
        final msg = e.message?.toLowerCase() ?? '';
        if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
          return const AssistantException(kind: AssistantErrorKind.network);
        }
        return const AssistantException(kind: AssistantErrorKind.unknown);
      default:
        return const AssistantException(kind: AssistantErrorKind.unknown);
    }
  }
}
