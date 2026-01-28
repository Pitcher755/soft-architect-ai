/// Domain entities for the Chat feature.
/// Pure Dart objects with no framework dependencies.

/// Represents a chat message in the conversation.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  /// Unique identifier for the message.
  final String id;

  /// Role of the sender: 'user', 'assistant', or 'system'.
  final String role;

  /// The message content (plain text or markdown).
  final String content;

  /// When the message was created.
  final DateTime timestamp;

  /// Create a copy with optional field updates.
  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() => 'ChatMessage(id: $id, role: $role, timestamp: $timestamp)';
}

/// Represents a chat session.
class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get messageCount => messages.length;

  @override
  String toString() => 'ChatSession(id: $id, title: $title, messageCount: $messageCount)';
}
