import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../models/assistant_models.dart';
import 'assistant_cards.dart';

/// Single chat message bubble supporting user, assistant, error states, and cards.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onCardAction,
  });

  final AssistantMessage message;
  final VoidCallback? onCardAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.role == AssistantRole.user;
    final l10n = context.l10n;

    final userBg = isDark
        ? AppColors.primaryLight.withValues(alpha: 0.35)
        : AppColors.primaryLight.withValues(alpha: 0.15);
    final assistantBg = isDark ? const Color(0xFF241F2D) : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xFF1D1B20);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    // Resolve error text if applicable
    String displayText = message.text;
    if (message.isError) {
      switch (message.text) {
        case 'assistantErrorQuota':
          displayText = l10n.assistantErrorQuota;
          break;
        case 'assistantErrorBusy':
          displayText = l10n.assistantErrorBusy;
          break;
        case 'assistantErrorNetwork':
          displayText = l10n.assistantErrorNetwork;
          break;
        default:
          displayText = l10n.assistantErrorGeneric;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.primaryLight,
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isError
                    ? (isDark ? const Color(0xFF3E1B22) : const Color(0xFFFFF1F2))
                    : (isUser ? userBg : assistantBg),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: message.isError
                      ? Colors.red.withValues(alpha: 0.3)
                      : borderColor,
                  width: 1,
                ),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.20)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                      color: message.isError ? Colors.red : textColor,
                    ),
                  ),
                  if (message.cards.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...message.cards.map(
                      (card) => AssistantCardView(
                        card: card,
                        onAction: onCardAction,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
