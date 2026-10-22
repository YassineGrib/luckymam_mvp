import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/l10n_extension.dart';

/// Clean bottom chat input bar with send button and typing listener.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isThinking,
    this.onTypingChanged,
  });

  final Function(String) onSend;
  final bool isThinking;
  final Function(bool)? onTypingChanged;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _textController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() => _canSend = hasText);
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || widget.isThinking) return;
    _textController.clear();
    widget.onSend(text);
    widget.onTypingChanged?.call(false);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final barBg = isDark ? const Color(0xFF1E1A26) : Colors.white;
    final inputBg = isDark ? const Color(0xFF2B2536) : const Color(0xFFF5F3F8);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1B20);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 24,
      ),
      decoration: BoxDecoration(
        color: barBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  enabled: !widget.isThinking,
                  style: TextStyle(fontSize: 14.5, color: textColor),
                  decoration: InputDecoration(
                    hintText: widget.isThinking
                        ? l10n.assistantThinking
                        : l10n.assistantInputHint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _canSend && !widget.isThinking
                    ? AppColors.primaryLight
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08)),
              ),
              child: IconButton(
                icon: widget.isThinking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.arrow_upward_rounded, size: 22),
                color: Colors.white,
                onPressed: _canSend && !widget.isThinking ? _handleSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
