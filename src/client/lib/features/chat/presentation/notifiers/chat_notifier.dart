import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../features/filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../../features/project_shell/core/services/file_system_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';
import 'streaming_state.dart';

/// Simple UUID generator for demo purposes
String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

/// Notifier for chat state management using state machine pattern.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier({
    required ChatRepository repository,
    required FileSystemService fileSystemService,
    required this.ref,
  }) : _repository = repository,
       _fileSystemService = fileSystemService,
       super(const ChatState());

  final ChatRepository _repository;
  final FileSystemService _fileSystemService;
  final Ref ref;

  /// Sets the project path for document saving.
  void setProjectPath(String path) {
    state = state.copyWith(projectPath: path);
  }

  /// Sends a user message and initiates document generation streaming.
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return;
    }

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
      state = state.copyWith(messages: updatedMessages, isStreaming: true);

      // Create assistant message placeholder
      final assistantMessage = ChatMessage(
        id: generateId(),
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now().toIso8601String(),
        isStreaming: true,
      );

      final messagesWithAssistant = [...updatedMessages, assistantMessage];

      // Get document type and context
      final docType = _getDocTypeForCurrentIndex();
      final context = {
        'project_context': {},
        'chat_history': updatedMessages,
        'current_doc_index': state.currentDocIndex,
        'doc_type': docType,
      };

      final streamBuffer = StringBuffer();
      final stream = _repository.generateDocument(docType, message, context);

      await for (final token in stream) {
        streamBuffer.write(token);

        // Update assistant message with streamed content
        final updatedAssistant = assistantMessage.copyWith(
          content: streamBuffer.toString(),
          isStreaming: true,
        );

        final newMessages = [
          ...messagesWithAssistant.sublist(0, messagesWithAssistant.length - 1),
          updatedAssistant,
        ];

        state = state.copyWith(messages: newMessages, isStreaming: true);
      }

      // Mark streaming as complete and create proposal
      final completedAssistant = assistantMessage.copyWith(
        content: streamBuffer.toString(),
        isStreaming: false,
      );

      final finalMessages = [
        ...messagesWithAssistant.sublist(0, messagesWithAssistant.length - 1),
        completedAssistant,
      ];

      final proposal = DocumentProposal(
        id: generateId(),
        docType: docType,
        content: streamBuffer.toString(),
        metadata: {'doc_index': state.currentDocIndex},
        validationState: ValidationState.pending,
      );

      state = state.copyWith(
        messages: finalMessages,
        currentProposal: proposal,
        isStreaming: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Validates the current proposal, saves to filesystem, and advances.
  Future<void> validateProposal() async {
    if (state.currentProposal == null || state.projectPath == null) {
      return;
    }

    try {
      final proposal = state.currentProposal!;

      // Calculate file path
      final section = _getSectionForDocType(proposal.docType);
      final fileName = '${proposal.docType}.md';
      final relativePath = '$section/$fileName';

      // Save to disk via FileSystemService
      await _fileSystemService.saveDocument(
        projectPath: state.projectPath!,
        relativePath: relativePath,
        content: proposal.content,
      );

      // ✅ Trigger file tree refresh (2️⃣ criterion: auto-update tree)
      ref.read(fileSystemNotifierProvider.notifier).refresh();

      // Update proposal state to validated
      // Note: validatedProposal can be used for logging or future audit trail
      // ignore: unused_local_variable
      final validatedProposal = proposal.copyWith(
        validationState: ValidationState.validated,
      );

      // Advance to next document
      state = state.copyWith(
        currentDocIndex: state.currentDocIndex + 1,
        clearProposal: true,
      );

      // Trigger next question automatically if not complete
      if (state.currentDocIndex <= state.totalDocs) {
        await _triggerNextQuestion();
      }
    } on Exception catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Error al guardar documento: $e',
      );
    }
  }

  /// Rejects the current proposal without advancing.
  void rejectProposal() {
    state = state.copyWith(clearProposal: true);
  }

  /// Regenerates the current document proposal.
  Future<void> regenerateProposal() async {
    if (state.messages.isEmpty) {
      return;
    }

    // Get the last user message
    final lastUserMessage = state.messages
        .lastWhere(
          (msg) => msg.role == MessageRole.user,
          orElse: () => state.messages.first,
        )
        .content;

    // Clear current proposal and re-stream
    state = state.copyWith(clearProposal: true);
    await sendMessage('Regenera el documento: $lastUserMessage');
  }

  /// Resets chat state for a new project.
  /// Clears any error state.
  void clearError() {
    state = state.clearError();
  }

  /// Resets chat state for a new project.
  void resetForNewProject({int totalDocs = 25}) {
    state = ChatState(totalDocs: totalDocs);
  }

  /// Handles stream errors with retry logic.
  Future<void> retryLastMessage() async {
    if (state.messages.length < 2) {
      return;
    }

    final lastUserMessage = state.messages
        .lastWhere((msg) => msg.role == MessageRole.user)
        .content;

    // Remove error state and retry
    state = state.clearError();
    await sendMessage(lastUserMessage);
  }

  /// Triggers the next question automatically based on doc type.
  Future<void> _triggerNextQuestion() async {
    final nextDocType = _getDocTypeForCurrentIndex();
    final question = _getQuestionForDocType(nextDocType);

    final systemMessage = ChatMessage(
      id: generateId(),
      role: MessageRole.system,
      content: question,
      timestamp: DateTime.now().toIso8601String(),
    );

    state = state.copyWith(messages: [...state.messages, systemMessage]);
  }

  /// Maps current doc index to document type.
  String _getDocTypeForCurrentIndex() {
    final docTypes = [
      'PROJECT_MANIFESTO',
      'VISION_PROMISE',
      'USER_JOURNEY',
      'EXECUTIVE_SUMMARY',
      'FUNCTIONAL_REQUIREMENTS',
      'TECHNICAL_REQUIREMENTS',
      'ACCESSIBILITY_CHECKLIST',
      'DEFINITION_OF_READY',
      'DOCUMENTATION_STANDARDS',
      'ARCHITECTURE_OVERVIEW',
      'DATABASE_SCHEMA',
      'API_SPECIFICATION',
      'SECURITY_HARDENING_POLICY',
      'INFRASTRUCTURE_SETUP',
      'CI_CD_PIPELINE',
      'DEPLOYMENT_STRATEGY',
      'MONITORING_OBSERVABILITY',
      'DISASTER_RECOVERY',
      'ROADMAP_PHASE_1',
      'ROADMAP_PHASE_2',
      'ROADMAP_PHASE_3',
      'ROADMAP_PHASE_4',
      'ROADMAP_PHASE_5',
      'SUCCESS_METRICS',
      'COMMUNICATION_PLAN',
    ];

    final index = (state.currentDocIndex - 1).clamp(0, docTypes.length - 1);
    return docTypes[index];
  }

  /// Maps doc type to section folder.
  String _getSectionForDocType(String docType) {
    if (docType.startsWith('PROJECT_') ||
        docType.startsWith('VISION_') ||
        docType.startsWith('USER_') ||
        docType.startsWith('EXECUTIVE_')) {
      return '10-CONTEXT';
    } else if (docType.contains('REQUIREMENTS') ||
        docType.contains('ACCESSIBILITY') ||
        docType.contains('DEFINITION') ||
        docType.contains('DOCUMENTATION')) {
      return '20-REQUIREMENTS_AND_SPEC';
    } else if (docType.startsWith('ARCHITECTURE') ||
        docType.startsWith('DATABASE') ||
        docType.startsWith('API') ||
        docType.startsWith('SECURITY') ||
        docType.startsWith('INFRASTRUCTURE') ||
        docType.startsWith('CI_') ||
        docType.startsWith('DEPLOYMENT') ||
        docType.startsWith('MONITORING') ||
        docType.startsWith('DISASTER')) {
      return '30-ARCHITECTURE';
    } else if (docType.startsWith('ROADMAP') ||
        docType.startsWith('SUCCESS') ||
        docType.startsWith('COMMUNICATION')) {
      return '40-ROADMAP';
    }

    return '10-CONTEXT';
  }

  /// Generates contextual question for next document.
  String _getQuestionForDocType(String docType) {
    switch (docType) {
      case 'PROJECT_MANIFESTO':
        return '¿Cuál es el propósito y valores principales del proyecto?';
      case 'VISION_PROMISE':
        return '¿Cuál es la visión y promesa al usuario final?';
      case 'USER_JOURNEY':
        return '¿Cuál es el viaje del usuario a través del producto?';
      case 'FUNCTIONAL_REQUIREMENTS':
        return '¿Cuáles son los requisitos funcionales detallados?';
      case 'TECHNICAL_REQUIREMENTS':
        return '¿Cuáles son los requisitos técnicos y constraints?';
      case 'ARCHITECTURE_OVERVIEW':
        return '¿Cuál es la arquitectura técnica del sistema?';
      default:
        return 'Proporciona información sobre: $docType';
    }
  }
}

/// Mock implementation of ChatRepository for development.
/// This allows the app to run without a backend service.
/// Replace with actual implementation during backend integration.
class _MockChatRepository implements ChatRepository {
  @override
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) async* {
    // Simulate document generation with streaming tokens
    final tokens = [
      '# ',
      docType,
      '\n\n',
      'Generated for user input: ',
      userInput,
      '\n\n',
      'This is a mock response. ',
      'The actual implementation will connect to the backend RAG system.',
    ];

    for (final token in tokens) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield token;
    }
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    // Mock implementation - does nothing
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async {
    // Mock implementation - returns empty list
    return [];
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    // Mock implementation - does nothing
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // Return a mock implementation for development
  // In production, this will be provided via override in main.dart
  return _MockChatRepository();
});

final fileSystemServiceProvider = Provider<FileSystemService>((ref) {
  // Return a mock implementation for desktop
  // In production, this will be provided via override in main.dart
  return FileSystemServiceImpl();
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    repository: ref.watch(chatRepositoryProvider),
    fileSystemService: ref.watch(fileSystemServiceProvider),
    ref: ref,
  ),
);
