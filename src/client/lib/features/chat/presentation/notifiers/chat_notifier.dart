import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';
import 'streaming_state.dart';

/// Simple UUID generator for demo purposes
String generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

/// Notifier for chat state management using state machine pattern.
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier({
    required ChatRepository repository,
  })  : _repository = repository,
        super(
          const ChatState(),
        );

  /// Sends a user message and initiates document generation streaming.
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Clear any previous errors
      state = state.clearError();

      // Add user message to chat
      final userMessage = ChatMessage(
        id: generateId(),
        role: MessageRole.user,
        content: message,
        timestamp: DateTime.now().toIso8601String(),
      );

      final updatedMessages = [...state.messages, userMessage];
      state = state.copyWith(
        messages: updatedMessages,
        isStreaming: true,
      );

      // Create assistant message placeholder
      final assistantMessage = ChatMessage(
        id: generateId(),
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now().toIso8601String(),
        isStreaming: true,
      );

      final messagesWithAssistant = [
        ...updatedMessages,
        assistantMessage,
      ];

      // Stream tokens from repository
      final context = {
        'project_context': {},
        'chat_history': updatedMessages,
      };

      var streamedContent = '';
      final stream = _repository.generateDocument(
        'PROJECT_MANIFESTO', // TODO: Make dynamic based on current doc
        message,
        context,
      );

      await for (final token in stream) {
        streamedContent += token;

        // Update assistant message with streamed content
        final updatedAssistant = assistantMessage.copyWith(
          content: streamedContent,
          isStreaming: true,
        );

        final newMessages = [
          ...messagesWithAssistant.sublist(0, messagesWithAssistant.length - 1),
          updatedAssistant,
        ];

        state = state.copyWith(
          messages: newMessages,
          isStreaming: true,
        );
      }

      // Mark streaming as complete and create proposal
      final completedAssistant = assistantMessage.copyWith(
        content: streamedContent,
        isStreaming: false,
      );

      final finalMessages = [
        ...messagesWithAssistant.sublist(0, messagesWithAssistant.length - 1),
        completedAssistant,
      ];

      final proposal = DocumentProposal(
        id: generateId(),
        docType: 'PROJECT_MANIFESTO',
        content: streamedContent,
        metadata: {'source': 'llm_stream'},
        validationState: ValidationState.pending,
      );

      state = state.copyWith(
        messages: finalMessages,
        currentProposal: proposal,
        isStreaming: false,
      );
    } catch (e) {
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Validates the current proposal and advances to the next document.
  Future<void> validateProposal() async {
    if (state.currentProposal == null) return;

    try {
      final validatedProposal = state.currentProposal!.copyWith(
        validationState: ValidationState.validated,
      );

      await _repository.saveProposal(validatedProposal);

      // Advance to next document
      state = state.copyWith(
        currentProposal: null,
        currentDocIndex: state.currentDocIndex + 1,
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to save proposal: ${e.toString()}',
      );
    }
  }

  /// Rejects the current proposal without advancing.
  void rejectProposal() {
    state = state.copyWith(currentProposal: null);
  }

  /// Regenerates the current document proposal.
  Future<void> regenerateProposal() async {
    if (state.messages.isEmpty) return;

    // Get the last user message
    final lastUserMessage = state.messages
        .lastWhere(
          (msg) => msg.role == MessageRole.user,
          orElse: () => state.messages.first,
        )
        .content;

    // Clear current proposal and re-stream
    state = state.copyWith(currentProposal: null);
    await sendMessage(lastUserMessage);
  }

  /// Resets chat state for a new project.
  void resetForNewProject({int totalDocs = 25}) {
    state = ChatState(totalDocs: totalDocs);
  }

  /// Handles stream errors with retry logic.
  Future<void> retryLastMessage() async {
    if (state.messages.length < 2) return;

    final lastUserMessage = state.messages
        .lastWhere((msg) => msg.role == MessageRole.user)
        .content;

    // Remove error state and retry
    state = state.clearError();
    await sendMessage(lastUserMessage);
  }
}

// Providers for dependency injection
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  throw UnimplementedError('ChatRepository must be provided in main.dart');
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    repository: ref.watch(chatRepositoryProvider),
  );
});
