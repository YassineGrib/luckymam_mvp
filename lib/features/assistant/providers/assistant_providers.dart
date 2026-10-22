import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../avatar/mochi_state.dart';
import '../models/assistant_models.dart';
import '../services/assistant_backend.dart';
import '../services/fake_assistant_backend.dart';
import '../services/gemini_assistant_backend.dart';
import '../services/gemini_direct_backend.dart';

/// Conversation phase of the assistant.
enum AssistantPhase {
  idle,
  thinking,
  speaking,
}

/// State of the assistant chat session.
class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.phase = AssistantPhase.idle,
    this.mochi = MochiState.idle,
    this.isUserTyping = false,
  });

  final List<AssistantMessage> messages;
  final AssistantPhase phase;
  final MochiState mochi;
  final bool isUserTyping;

  AssistantState copyWith({
    List<AssistantMessage>? messages,
    AssistantPhase? phase,
    MochiState? mochi,
    bool? isUserTyping,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      phase: phase ?? this.phase,
      mochi: mochi ?? this.mochi,
      isUserTyping: isUserTyping ?? this.isUserTyping,
    );
  }
}

/// Controller managing messages, avatar states, and backend communication.
class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(
    this._backend, {
    required this.locale,
    Duration Function(String)? speakingDuration,
  })  : _speakingDuration = speakingDuration ?? _defaultSpeakingDuration,
        super(const AssistantState());

  final AssistantBackend _backend;
  final String locale;
  final Duration Function(String) _speakingDuration;

  static Duration _defaultSpeakingDuration(String text) {
    // ~30ms per character, between 600ms and 3500ms
    final ms = (text.length * 30).clamp(600, 3500);
    return Duration(milliseconds: ms);
  }

  Timer? _greetTimer;

  void greet({Duration duration = const Duration(milliseconds: 1200)}) {
    _greetTimer?.cancel();
    state = state.copyWith(mochi: MochiState.approval);
    if (duration == Duration.zero) {
      if (mounted && state.phase == AssistantPhase.idle) {
        state = state.copyWith(mochi: MochiState.idle);
      }
      return;
    }
    _greetTimer = Timer(duration, () {
      if (mounted && state.phase == AssistantPhase.idle) {
        state = state.copyWith(mochi: MochiState.idle);
      }
    });
  }

  @override
  void dispose() {
    _greetTimer?.cancel();
    super.dispose();
  }

  void onUserTyping(bool typing) {
    if (state.phase != AssistantPhase.idle) return;
    state = state.copyWith(
      isUserTyping: typing,
      mochi: typing ? MochiState.working : MochiState.idle,
    );
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.phase == AssistantPhase.thinking) return;

    final userMessage = AssistantMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_u',
      role: AssistantRole.user,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      phase: AssistantPhase.thinking,
      mochi: MochiState.thinking,
      isUserTyping: false,
    );

    try {
      final reply = await _backend.send(
        history: state.messages,
        message: trimmed,
        locale: locale,
      );

      final assistantMessage = AssistantMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_a',
        role: AssistantRole.assistant,
        text: reply.text,
        cards: reply.cards,
        createdAt: DateTime.now(),
      );

      final nextMochi = _mapMoodToMochi(reply.mood);
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        phase: AssistantPhase.speaking,
        mochi: nextMochi,
      );

      // Speaking duration before relaxing back to idle
      final dur = _speakingDuration(reply.text);
      if (dur > Duration.zero) {
        await Future<void>.delayed(dur);
      }
      if (mounted) {
        state = state.copyWith(
          phase: AssistantPhase.idle,
          mochi: MochiState.idle,
        );
      }
    } on AssistantException catch (e) {
      final errorMessage = AssistantMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_err',
        role: AssistantRole.assistant,
        text: _errorKeyFor(e.kind),
        createdAt: DateTime.now(),
        isError: true,
      );

      final errorMochi = e.kind == AssistantErrorKind.quota
          ? MochiState.ratelimit
          : MochiState.error;

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        phase: AssistantPhase.idle,
        mochi: errorMochi,
      );
    } catch (e) {
      final errorMessage = AssistantMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_err',
        role: AssistantRole.assistant,
        text: 'assistantErrorGeneric',
        createdAt: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        phase: AssistantPhase.idle,
        mochi: MochiState.error,
      );
    }
  }

  MochiState _mapMoodToMochi(AssistantMood mood) {
    switch (mood) {
      case AssistantMood.neutral:
        return MochiState.idle;
      case AssistantMood.gentle:
        return MochiState.gentle;
      case AssistantMood.proud:
        return MochiState.finished;
      case AssistantMood.love:
        return MochiState.approval;
      case AssistantMood.question:
        return MochiState.question;
      case AssistantMood.thinking:
        return MochiState.thinking;
    }
  }

  String _errorKeyFor(AssistantErrorKind kind) {
    switch (kind) {
      case AssistantErrorKind.quota:
        return 'assistantErrorQuota';
      case AssistantErrorKind.unavailable:
        return 'assistantErrorBusy';
      case AssistantErrorKind.network:
        return 'assistantErrorNetwork';
      case AssistantErrorKind.unauthenticated:
      case AssistantErrorKind.unknown:
        return 'assistantErrorGeneric';
    }
  }
}

/// Provider for Assistant Backend.
final assistantBackendProvider = Provider<AssistantBackend>((ref) {
  const isFake = bool.fromEnvironment('ASSISTANT_FAKE', defaultValue: false);
  if (isFake) {
    return FakeAssistantBackend();
  }
  const isCallable = bool.fromEnvironment('ASSISTANT_CALLABLE', defaultValue: false);
  if (isCallable) {
    return GeminiAssistantBackend();
  }
  // Default to GeminiDirectBackend using the Google AI Studio key from docs/ai.md
  return GeminiDirectBackend();
});

/// Auto-disposed StateNotifierProvider for AssistantController.
final assistantControllerProvider =
    StateNotifierProvider.autoDispose<AssistantController, AssistantState>((ref) {
  final backend = ref.watch(assistantBackendProvider);
  final locale = ref.watch(localeProvider).languageCode;
  return AssistantController(backend, locale: locale);
});
