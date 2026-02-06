import 'package:flutter/material.dart';

/// Model for chat messages (use the one from domain)
class ChatMessageUI {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessageUI({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

/// Widget que renderiza mensajes de chat con estilo dark theme
class MessageBubbleWidget extends StatelessWidget {
  final ChatMessageUI message;
  final VoidCallback? onLongPress;

  const MessageBubbleWidget({Key? key, required this.message, this.onLongPress})
    : super(key: key);

  bool get _isUserMessage => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Align(
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
            color: _isUserMessage
                ? const Color(0xFF238636)
                : const Color(0xFF30363D),
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
                      ? const Color(0xFFE6EDF3)
                      : const Color(0xFFC9D1D9),
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
                    color: Color(0xFF6E7681), // GitHub dark muted
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUserBubbleColor() {
    return const Color(
      0xFF1F6FEB,
    ).withOpacity(0.15); // GitHub blue with opacity
  }

  Color _getAssistantBubbleColor() {
    return const Color(0xFF161B22); // GitHub dark surface
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
