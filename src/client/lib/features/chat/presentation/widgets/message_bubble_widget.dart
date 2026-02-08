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
/// - Mensajes del usuario: burbuja alineada a la derecha
/// - Mensajes del asistente: burbuja alineada a la izquierda sin esquina superior izquierda
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
    child: Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: _isUserMessage ? 64 : 16,
        right: _isUserMessage ? 16 : 64,
      ),
      child: Stack(
        alignment: _isUserMessage ? Alignment.topRight : Alignment.topLeft,
        children: [
          // Message bubble
          Container(
            margin: EdgeInsets.only(
              top: 16,
              right: _isUserMessage ? 12 : 0,
              left: _isUserMessage ? 0 : 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isUserMessage
                  ? _getUserBubbleColor()
                  : _getAssistantBubbleColor(),
              borderRadius: _getBorderRadius(),
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

          // Avatar in top corner
          CircleAvatar(
            radius: 12,
            backgroundColor:
                _isUserMessage ? AppColors.dirContext : AppColors.dirArchitecture,
            child: Text(
              _isUserMessage ? 'U' : 'AI',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1117),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Color _getUserBubbleColor() => AppColors.primaryLight.withValues(alpha: 0.15);

  Color _getAssistantBubbleColor() =>
      AppColors.primaryDark.withValues(alpha: 0.15);

  /// Get border radius based on message role
  /// User: sin esquina superior derecha (0,0)
  /// AI: sin esquina superior izquierda (0,0)
  BorderRadius _getBorderRadius() {
    if (_isUserMessage) {
      // User message: sharp top-right, rounded others
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else {
      // AI message: sharp top-left, rounded others
      return const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
