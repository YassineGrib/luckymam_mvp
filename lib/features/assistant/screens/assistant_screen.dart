import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../avatar/mochi_avatar.dart';
import '../avatar/mochi_state.dart';
import '../models/assistant_models.dart';
import '../providers/assistant_character_provider.dart';
import '../providers/assistant_providers.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/suggestion_chips.dart';

/// Redesigned AI Assistant screen featuring a large, animated Hero character
/// and a focused Single-Turn Q&A flow (سؤال وجواب).
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assistantControllerProvider.notifier).greet();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final state = ref.watch(assistantControllerProvider);
    final controller = ref.read(assistantControllerProvider.notifier);

    // Initial greeting message
    final initialGreeting = AssistantMessage(
      id: 'msg_welcome',
      role: AssistantRole.assistant,
      text: l10n.assistantGreeting,
      createdAt: DateTime.now(),
    );

    // Identify active Single-Turn Q&A
    AssistantMessage? lastUserMsg;
    AssistantMessage? lastAssistantMsg;

    for (int i = state.messages.length - 1; i >= 0; i--) {
      final m = state.messages[i];
      if (lastUserMsg == null && m.role == AssistantRole.user) {
        lastUserMsg = m;
        break;
      }
    }

    if (lastUserMsg != null) {
      final userIdx = state.messages.indexOf(lastUserMsg);
      for (int i = userIdx + 1; i < state.messages.length; i++) {
        final m = state.messages[i];
        if (m.role == AssistantRole.assistant) {
          lastAssistantMsg = m;
          break;
        }
      }
    }

    final hasActiveTurn = lastUserMsg != null;
    final isThinking = state.phase == AssistantPhase.thinking;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Top Navigation Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.assistantName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1D1B20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isArabic ? 'متصلة' : 'En ligne',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              l10n.assistantDisclaimer,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF6B6575),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (hasActiveTurn)
                        IconButton(
                          tooltip: isArabic ? 'سؤال جديد' : 'Nouvelle question',
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () {
                            controller.greet();
                          },
                        ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 0.5),

                // 2. Main Content Area with Large Hero Character + Q&A
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Prominent Animated Hero Avatar
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            padding: EdgeInsets.symmetric(
                              vertical: hasActiveTurn ? 8 : 20,
                            ),
                            child: Hero(
                              tag: 'assistant_mochi_hero',
                              child: MochiAvatar(
                                size: hasActiveTurn ? 96 : 136,
                                character: ref.watch(assistantCharacterProvider),
                                state: isThinking
                                    ? MochiState.thinking
                                    : state.mochi,
                                speaking: state.phase == AssistantPhase.speaking,
                              ),
                            ),
                          ),
                        ),

                        // Thinking status indicator
                        if (isThinking)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isArabic
                                      ? 'لاكي تفكّر في إجابتكِ...'
                                      : 'Lucky prépare votre réponse...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF6B6575),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Q&A Presentation (سؤال وجواب)
                        if (!hasActiveTurn) ...[
                          // Welcome greeting bubble
                          MessageBubble(
                            message: initialGreeting,
                            onCardAction: () {},
                          ),
                        ] else ...[
                          // 1. User Question
                          MessageBubble(
                            message: lastUserMsg,
                            onCardAction: () {},
                          ),
                          const SizedBox(height: 8),

                          // 2. Lucky's Answer
                          if (lastAssistantMsg != null) ...[
                            MessageBubble(
                              message: lastAssistantMsg,
                              onCardAction: () {},
                            ),
                            const SizedBox(height: 12),
                            // Quick New Question Pill
                            Center(
                              child: TextButton.icon(
                                onPressed: () => controller.greet(),
                                icon: const Icon(Icons.add_comment_outlined,
                                    size: 16),
                                label: Text(
                                  isArabic
                                      ? 'طرح سؤال آخر'
                                      : 'Poser une autre question',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // 3. Quick Suggestions docked above the Input Bar
                if (!hasActiveTurn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SuggestionChips(
                      onSuggestionSelected: (query) {
                        controller.send(query);
                        _scrollToBottom();
                      },
                    ),
                  ),

                // 4. Input Bar at Bottom
                ChatInputBar(
                  isThinking: isThinking,
                  onTypingChanged: (isTyping) {
                    controller.onUserTyping(isTyping);
                  },
                  onSend: (text) {
                    controller.send(text);
                    _scrollToBottom();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
