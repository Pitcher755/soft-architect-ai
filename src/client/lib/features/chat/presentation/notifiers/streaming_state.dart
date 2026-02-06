import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';

/// State class for ChatNotifier.
class ChatState {
  const ChatState({
    this.messages = const [],
    this.currentProposal,
    this.currentDocIndex = 1,
    this.totalDocs = 25,
    this.isStreaming = false,
    this.hasError = false,
    this.errorMessage,
    this.projectPath,
  });
  final List<ChatMessage> messages;
  final DocumentProposal? currentProposal;
  final int currentDocIndex;
  final int totalDocs;
  final bool isStreaming;
  final bool hasError;
  final String? errorMessage;
  final String? projectPath;

  /// Returns progress as "Doc X/25"
  String get progressText => 'Doc $currentDocIndex/$totalDocs';

  /// Returns true if all documents have been completed
  bool get isComplete => currentDocIndex > totalDocs;

  /// Creates a copy of this state with specified fields replaced
  ChatState copyWith({
    List<ChatMessage>? messages,
    DocumentProposal? currentProposal,
    int? currentDocIndex,
    int? totalDocs,
    bool? isStreaming,
    bool? hasError,
    String? errorMessage,
    String? projectPath,
    bool clearProposal = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    currentProposal: clearProposal
        ? null
        : (currentProposal ?? this.currentProposal),
    currentDocIndex: currentDocIndex ?? this.currentDocIndex,
    totalDocs: totalDocs ?? this.totalDocs,
    isStreaming: isStreaming ?? this.isStreaming,
    hasError: hasError ?? this.hasError,
    errorMessage: errorMessage ?? this.errorMessage,
    projectPath: projectPath ?? this.projectPath,
  );

  /// Clears error state
  ChatState clearError() => copyWith(hasError: false);

  /// Returns a new state with cleared messages (for new project)
  ChatState reset() => ChatState(totalDocs: totalDocs);
}
