import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../avatar/assistant_character.dart';

const _kAssistantCharacterKey = 'assistant_character_preference';

/// StateNotifierProvider managing the user's selected AI Assistant Character.
/// Defaults to [AssistantCharacter.lueur].
final assistantCharacterProvider =
    StateNotifierProvider<AssistantCharacterNotifier, AssistantCharacter>(
  (ref) => AssistantCharacterNotifier(),
);

class AssistantCharacterNotifier extends StateNotifier<AssistantCharacter> {
  AssistantCharacterNotifier() : super(AssistantCharacter.lueur) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kAssistantCharacterKey);
      if (stored != null) {
        state = AssistantCharacter.fromString(stored);
      }
    } catch (_) {}
  }

  Future<void> setCharacter(AssistantCharacter character) async {
    state = character;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAssistantCharacterKey, character.name);
    } catch (_) {}
  }
}
