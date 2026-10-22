import '../models/assistant_models.dart';

/// Abstract contract for Assistant Chat Backends.
/// Can be fulfilled by a Fake backend for unit testing, a direct Gemini REST client,
/// or a secure Firebase Cloud Function.
abstract class AssistantBackend {
  Future<AssistantReply> send({
    required List<AssistantMessage> history,
    required String message,
    required String locale,
  });
}
