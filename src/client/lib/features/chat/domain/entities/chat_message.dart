/// Represents a single message in the chat.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.metadata,
  });

  final String id;
  final MessageRole role;
  final String content;
  final String timestamp;
  final bool isStreaming;
  final Map<String, dynamic>? metadata;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isComplete => !isStreaming;

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    String? timestamp,
    bool? isStreaming,
    Map<String, dynamic>? metadata,
  }) => ChatMessage(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
    isStreaming: isStreaming ?? this.isStreaming,
    metadata: metadata ?? this.metadata,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => id.hashCode ^ role.hashCode ^ content.hashCode;
}

enum MessageRole { user, assistant, system }
