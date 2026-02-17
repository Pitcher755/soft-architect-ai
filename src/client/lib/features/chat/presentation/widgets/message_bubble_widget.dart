// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

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
/// - Mensajes del usuario: burbuja alineada a la derecha con botón editar
/// - Mensajes del asistente: burbuja alineada a la izquierda con Markdown y botones de acción
class MessageBubbleWidget extends StatelessWidget {
  const MessageBubbleWidget({
    required this.message,
    super.key,
    this.onLongPress,
    this.messageController,
    this.userName,
  });
  final ChatMessageUI message;
  final VoidCallback? onLongPress;
  final TextEditingController? messageController;
  final String? userName;

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
                  // Message content with edit button (user) or markdown (AI)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _isUserMessage
                            ? SelectableText(
                                message.content,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              )
                            : MarkdownBody(
                                data: message.content,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                  code: const TextStyle(
                                    backgroundColor: AppColors.surfaceBg,
                                    color: AppColors.primary,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: AppColors.surfaceBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                      ),
                      // Edit button for user messages
                      if (_isUserMessage && messageController != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          color: AppColors.textMuted,
                          iconSize: 16,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            messageController!.text = message.content;
                          },
                          tooltip: 'Editar mensaje',
                        ),
                      // Show blinking cursor only for streaming AI messages
                      if (!_isUserMessage && message.isStreaming)
                        const _BlinkingCursor(),
                    ],
                  ),

                  // Action buttons for assistant messages
                  if (!_isUserMessage && !message.isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            icon: Icons.copy,
                            tooltip: 'Copiar al portapapeles',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: message.content),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.check_circle_outline,
                            tooltip: 'Validar y guardar documento',
                            onPressed: () {
                              // TODO: Implement validate and save functionality
                            },
                          ),
                        ],
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
            backgroundColor: _isUserMessage
                ? AppColors.dirContext
                : AppColors.dirArchitecture,
            child: Icon(
              _isUserMessage ? Icons.person : Icons.smart_toy,
              size: 14,
              color: Colors.white,
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

/// Small action button for assistant messages.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon),
    iconSize: 16,
    padding: const EdgeInsets.all(4),
    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    color: AppColors.textMuted,
    hoverColor: AppColors.primary.withValues(alpha: 0.1),
    onPressed: onPressed,
    tooltip: tooltip,
  );
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
