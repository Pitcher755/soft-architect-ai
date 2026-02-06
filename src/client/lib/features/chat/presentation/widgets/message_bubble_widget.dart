import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Model for chat messages (use the one from domain)
class ChatMessageUI {
  ChatMessageUI({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
}

/// Widget que renderiza mensajes de chat con estilo dark theme
class MessageBubbleWidget extends StatelessWidget {
  const MessageBubbleWidget({
    required this.message,
    super.key,
    this.onLongPress,
  });
  final ChatMessageUI message;
  final VoidCallback? onLongPress;

  bool get _isUserMessage => message.role == 'user';

  @override
  Widget build(BuildContext context) => Align(
    alignment: _isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: _isUserMessage ? 64 : 16,
        right: _isUserMessage ? 16 : 64,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isUserMessage
            ? _getUserBubbleColor()
            : _getAssistantBubbleColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isUserMessage ? AppColors.success : AppColors.border,
          width: 0.5,
        ),
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: _isUserMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message content
            SelectableText(
              message.content,
              style: TextStyle(
                color: _isUserMessage
                    ? AppColors.textMain
                    : AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _formatTime(message.timestamp),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Color _getUserBubbleColor() => AppColors.primaryLight.withValues(alpha: 0.15);

  Color _getAssistantBubbleColor() => AppColors.sidebarBg;

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
