import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../avatar/mochi_avatar.dart';
import '../models/assistant_models.dart';
import '../providers/assistant_providers.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/suggestion_chips.dart';

/// Fullscreen AI Assistant chat interface featuring the animated Mochi companion.
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final state = ref.watch(assistantControllerProvider);
    final controller = ref.read(assistantControllerProvider.notifier);

    // Initial greeting message displayed locally
    final initialGreeting = AssistantMessage(
      id: 'msg_welcome',
      role: AssistantRole.assistant,
      text: l10n.assistantGreeting,
      createdAt: DateTime.now(),
    );

    final displayMessages = [initialGreeting, ...state.messages];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 320),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Top Header with Back button and Mochi Avatar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.assistantName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1D1B20),
                              ),
                            ),
                            Text(
                              l10n.assistantDisclaimer,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : const Color(0xFF6B6575),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Animated Mochi avatar preview in header
                      Hero(
                        tag: 'assistant_mochi_hero',
                        child: MochiAvatar(
                          state: state.mochi,
                          speaking: state.phase == AssistantPhase.speaking,
                          size: 56,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 0.5),

                // 2. Chat message list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: displayMessages.length,
                    itemBuilder: (context, index) {
                      final msg = displayMessages[index];
                      return MessageBubble(
                        message: msg,
                        onCardAction: () {},
                      );
                    },
                  ),
                ),

                // 3. Quick Suggestion Chips (when conversation is fresh)
                if (state.messages.length <= 1)
                  SuggestionChips(
                    onSuggestionSelected: (query) {
                      controller.send(query);
                      _scrollToBottom();
                    },
                  ),

                // 4. Input bar
                ChatInputBar(
                  isThinking: state.phase == AssistantPhase.thinking,
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
