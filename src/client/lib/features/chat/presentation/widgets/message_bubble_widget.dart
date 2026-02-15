// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Model for chat messages (use the one from domain)
class ChatMessageUI {
  ChatMessageUI({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
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
                  // Message content with blinking cursor if streaming
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: SelectableText(
                          message.content,
                          style: TextStyle(
                            color: _isUserMessage
                                ? AppColors.textMain
                                : AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      // Show blinking cursor only for streaming AI messages
                      if (!_isUserMessage && message.isStreaming)
                        const _BlinkingCursor(),
                    ],
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
            backgroundColor: _isUserMessage
                ? AppColors.dirContext
                : AppColors.dirArchitecture,
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

/// Animated blinking cursor widget for streaming messages.
/// Uses FadeTransition with AnimationController for smooth 60 FPS animation.
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530), // Standard cursor blink rate
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _animation,
    child: Container(
      width: 2,
      height: 16,
      margin: const EdgeInsets.only(left: 2, top: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  );
}
