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
    this.isLoading = false,
    this.validatedMessageIds = const {},
  });

  /// ✅ NEW: Factory constructor for initial clean state
  ///
  /// Use this when switching projects to ensure no state pollution.
  factory ChatState.initial() => const ChatState();
  final List<ChatMessage> messages;
  final DocumentProposal? currentProposal;
  final int currentDocIndex;
  final int totalDocs;
  final bool isStreaming;
  final bool hasError;
  final String? errorMessage;
  final String? projectPath;
  final bool isLoading;

  /// Set of message IDs that have been validated (saved to disk)
  final Set<String> validatedMessageIds;

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
    bool? isLoading,
    bool clearProposal = false,
    bool clearErrorMessage = false,
    Set<String>? validatedMessageIds,
  }) => ChatState(
    messages: messages ?? this.messages,
    currentProposal: clearProposal
        ? null
        : (currentProposal ?? this.currentProposal),
    currentDocIndex: currentDocIndex ?? this.currentDocIndex,
    totalDocs: totalDocs ?? this.totalDocs,
    isStreaming: isStreaming ?? this.isStreaming,
    hasError: hasError ?? this.hasError,
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
    projectPath: projectPath ?? this.projectPath,
    isLoading: isLoading ?? this.isLoading,
    validatedMessageIds: validatedMessageIds ?? this.validatedMessageIds,
  );

  /// Clears error state
  ChatState clearError() => copyWith(hasError: false, clearErrorMessage: true);

  /// Returns a new state with cleared messages (for new project)
  ChatState reset() => ChatState(totalDocs: totalDocs);
}
