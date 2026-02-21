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

  /// Create ChatMessage from JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    role: MessageRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => MessageRole.user,
    ),
    content: json['content'] as String,
    timestamp: json['timestamp'] as String,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  final String id;
  final MessageRole role;
  final String content;
  final String timestamp;
  final bool isStreaming;
  final Map<String, dynamic>? metadata;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isComplete => !isStreaming;

  /// Returns true if this message should not be displayed in the UI.
  ///
  /// Hidden messages are typically used for system prompts that need to be
  /// sent to the LLM but shouldn't appear in the chat history visible to users.
  ///
  /// Example:
  /// ```dart
  /// final hiddenMessage = ChatMessage(
  ///   id: 'msg-1',
  ///   role: MessageRole.user,
  ///   content: 'Internal prompt for next step',
  ///   timestamp: DateTime.now().toIso8601String(),
  ///   metadata: {'hidden': true},
  /// );
  /// assert(hiddenMessage.isHidden == true);
  /// ```
  bool get isHidden => metadata?['hidden'] == true;

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

  /// Convert ChatMessage to JSON for persistence.
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'content': content,
    'timestamp': timestamp,
    'metadata': metadata,
  };
}

enum MessageRole { user, assistant, system }
