import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../domain/entities/chat_stream_event.dart';
import '../../../../features/filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../../features/project_shell/core/services/file_system_service.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';
import 'streaming_state.dart';

/// Custom exception for missing project context
class ProjectContextError implements Exception {
  ProjectContextError(this.message);
  final String message;

  @override
  String toString() => 'ProjectContextError: $message';
}

/// Generate unique ID using UUID v4 (ensures collision-free IDs)
String generateId() => UuidGenerator.v4();

/// Configuration flags for development/production switches
const String _backendBaseUrl = String.fromEnvironment(
  'BACKEND_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
const String _backendApiKey = String.fromEnvironment(
  'BACKEND_API_KEY',
  defaultValue: 'dev_test_key_12345', // Valid dev API key (10+ chars)
);

/// Notifier for chat state management using state machine pattern.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier({
    required ChatRepository repository,
    required ChatRepository mockRepository,
    required FileSystemService fileSystemService,
    required this.ref,
  }) : _repository = repository,
       _mockRepository = mockRepository,
       _fileSystemService = fileSystemService,
       super(const ChatState());

  final ChatRepository _repository;
  final ChatRepository _mockRepository;
  final FileSystemService _fileSystemService;
  final Ref ref;

  /// Sets the project path for document saving.
  ///
  /// ✅ CRITICAL FIX: ALWAYS resets state and loads history from SQLite.
  ///
  /// This prevents chat state pollution between projects by:
  /// 1. Resetting ALL state fields to initial values
  /// 2. Loading persisted history for the specific project
  /// 3. Never showing "ghost messages" from previous project
  ///
  /// Example:
  /// ```dart
  /// await chatNotifier.setProjectPath('/home/user/project-a');
  /// // State is now clean with only project-a messages
  ///
  /// await chatNotifier.setProjectPath('/home/user/project-b');
  /// // State is now clean with only project-b messages
  /// ```
  Future<void> setProjectPath(String path) async {
    // ✅ STEP 1: ALWAYS reset state first (prevents pollution)
    state = ChatState.initial().copyWith(projectPath: path, isLoading: true);

    // ✅ STEP 2: Generate deterministic UUID for this project
    final projectId = UuidGenerator.fromString(path);

    // ignore: avoid_print
    print('📂 Loading history for project: $path (ID: $projectId)');

    // ✅ STEP 3: Load chat history from SQLite
    try {
      debugPrint('🔍 Fetching chat history from DB...');
      final history = await _repository.getChatHistory(projectId);
      debugPrint('📖 Loaded ${history.length} messages from DB');

      // ✅ STEP 4: Update state with loaded messages
      state = state.copyWith(messages: history, isLoading: false);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stackTrace) {
      debugPrint('🔥 Stack trace: $stackTrace');
      // On error, keep empty state but log the issue
      // ignore: avoid_print
      print('❌ Failed to load chat history: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load chat history: $e',
      );
    }
  }

  /// **DEPRECATED:** Use [sendMessageStream] instead.
  ///
  /// This method uses the unimplemented `generateDocument()` which throws
  /// UnimplementedError. Use [sendMessageStream] for proper SSE streaming.
  @Deprecated('Use sendMessageStream() instead. This method calls '
      'generateDocument() which is not implemented.')
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return;
    }

    try {
      // ✅ CRITICAL: Guard against missing project context
      final projectPath = state.projectPath;
      if (projectPath == null) {
        throw ProjectContextError(
          'No project context initialized. Call setProjectPath() first.',
        );
      }

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
    } on ProjectContextError catch (e) {
      // ✅ Show user-friendly error for missing context
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: 'Error: ${e.message}',
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sends a user message and streams the AI response using SSE.
  /// This method implements progressive token rendering with ChatStreamEvent.
  Future<void> sendMessageStream(String message) async {
    if (message.trim().isEmpty) {
      return;
    }

    try {
      // Clear any previous errors
      state = state.clearError();

      // 1️⃣ Add user message immediately
      final userMessage = ChatMessage(
        id: generateId(),
        role: MessageRole.user,
        content: message,
        timestamp: DateTime.now().toIso8601String(),
      );

      final updatedMessages = [...state.messages, userMessage];
      state = state.copyWith(messages: updatedMessages, isStreaming: true);

      // 2️⃣ Add empty AI message with isStreaming=true
      final assistantMessage = ChatMessage(
        id: generateId(),
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now().toIso8601String(),
        isStreaming: true,
      );

      final messagesWithAssistant = [...updatedMessages, assistantMessage];
      state = state.copyWith(
        messages: messagesWithAssistant,
        isStreaming: true,
      );

      // 3️⃣ Stream tokens from repository
      final streamBuffer = StringBuffer();

      // ✅ CRITICAL: Guard against missing project context
      final projectPath = state.projectPath;
      if (projectPath == null) {
        throw ProjectContextError(
          'No project context initialized. Call setProjectPath() first.',
        );
      }

      // Use mock repository for guide project (offline mode)
      final isGuideProject = projectPath.startsWith('mock://');
      final repository = isGuideProject ? _mockRepository : _repository;

      // Generate deterministic UUID from project path
      final projectId = UuidGenerator.fromString(projectPath);

      // Save user message to persistence (after variables defined)
      if (!isGuideProject) {
        try {
          debugPrint(
            '💾 Attempting to save user message: ${userMessage.id} '
            'for project: $projectId',
          );
          await _repository.saveMessage(projectId, userMessage);
          debugPrint('✅ User message saved successfully');
          // ignore: avoid_catches_without_on_clauses
        } catch (e, stackTrace) {
          debugPrint('🔥 Failed to save user message: $e');
          debugPrint('🔥 Stack trace: $stackTrace');
          // Show error to user
          state = state.copyWith(
            hasError: true,
            errorMessage: 'Warning: Your message was not saved: $e',
          );
        }
      }

      final stream = repository.sendMessageStream(message, projectId);

      await for (final event in stream) {
        if (event is TokenEvent) {
          // 4️⃣ Append token to AI message
          streamBuffer.write(event.token);

          final updatedAssistant = assistantMessage.copyWith(
            content: streamBuffer.toString(),
            isStreaming: true,
          );

          final newMessages = [
            ...messagesWithAssistant.sublist(
              0,
              messagesWithAssistant.length - 1,
            ),
            updatedAssistant,
          ];

          state = state.copyWith(messages: newMessages, isStreaming: true);
        } else if (event is DoneEvent) {
          // 5️⃣ Mark message complete on DoneEvent
          final fullResponse = event.fullResponse;

          final completedAssistant = assistantMessage.copyWith(
            content: fullResponse,
            isStreaming: false,
          );

          final finalMessages = [
            ...messagesWithAssistant.sublist(
              0,
              messagesWithAssistant.length - 1,
            ),
            completedAssistant,
          ];

          state = state.copyWith(messages: finalMessages, isStreaming: false);

          // Save assistant message to persistence
          if (!isGuideProject) {
            try {
              await _repository.saveMessage(projectId, completedAssistant);
              debugPrint(
                '💾 Assistant message saved to DB: ${completedAssistant.id}',
              );
              // ignore: avoid_catches_without_on_clauses
            } catch (e) {
              debugPrint('❌ Failed to save assistant message: $e');
              // Show error to user
              state = state.copyWith(
                hasError: true,
                errorMessage: 'Warning: Message not saved to history: $e',
              );
            }
          }
        } else if (event is ErrorEvent) {
          // 6️⃣ Handle ErrorEvent
          state = state.copyWith(
            isStreaming: false,
            hasError: true,
            errorMessage: event.error,
          );
          return;
        }
      }
    } on ProjectContextError catch (e) {
      // ✅ Show user-friendly error for missing context
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: 'Error: ${e.message}',
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Validates the current proposal OR a specific message by ID.
  /// Saves to filesystem with intelligent path detection.
  ///
  /// Special cases:
  /// - README.md → Root of project
  /// - Other docs → Organized by section folders
  Future<void> validateProposal([String? messageId]) async {
    final projectPath = state.projectPath;

    if (projectPath == null) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'No project context for saving document',
      );
      return;
    }

    try {
      String content;
      String docType;

      // If messageId provided, validate that specific message
      if (messageId != null) {
        final message = state.messages.firstWhere(
          (m) => m.id == messageId,
          orElse: () => throw Exception('Message not found'),
        );
        content = message.content;
        // Detect doc type from content (first H1 header)
        docType = _detectDocTypeFromContent(content);
      } else {
        // Validate current proposal
        final proposal = state.currentProposal;
        if (proposal == null) {
          state = state.copyWith(
            hasError: true,
            errorMessage: 'No proposal to validate',
          );
          return;
        }
        content = proposal.content;
        docType = proposal.docType;
      }

      // Calculate file path with intelligent detection
      final relativePath = _getFilePathForDocType(docType, content);

      debugPrint('📝 Validating document: $docType');
      debugPrint('📂 Target path: $projectPath/$relativePath');

      // Save to disk via FileSystemService (replaces existing file)
      await _fileSystemService.saveDocument(
        projectPath: projectPath,
        relativePath: relativePath,
        content: content,
      );

      debugPrint('✅ Document saved successfully');

      // Mark message as validated
      final newValidatedIds = {...state.validatedMessageIds};
      if (messageId != null) {
        newValidatedIds.add(messageId);
      }

      // Save proposal to database
      if (messageId != null) {
        final proposal = DocumentProposal(
          id: messageId,
          docType: docType,
          content: content,
          metadata: {'file_path': relativePath},
          validationState: ValidationState.validated,
        );
        await _repository.saveProposal(proposal);
      }

      // Trigger file tree refresh
      ref.read(fileSystemNotifierProvider.notifier).refresh();
      debugPrint('🔄 File tree refresh triggered');

      // Check if we should advance workflow BEFORE clearing proposal
      final shouldAdvanceWorkflow =
          messageId == null && state.currentProposal != null;

      // Update state
      state = state.copyWith(
        validatedMessageIds: newValidatedIds,
        clearProposal: messageId == null, // Only clear if validating proposal
      );

      // Advance workflow only if validating proposal (not individual messages)
      if (shouldAdvanceWorkflow) {
        state = state.copyWith(currentDocIndex: state.currentDocIndex + 1);

        // Trigger next question if not complete
        if (!state.isComplete) {
          await _triggerNextQuestion();
          debugPrint('🎯 Next question triggered');
        } else {
          debugPrint('🎉 All documents completed!');
        }
      }
    } on Exception catch (e) {
      debugPrint('❌ Error validating document: $e');
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to save document: $e',
      );
    }
  }

  /// Detects document type from content (first H1 header)
  String _detectDocTypeFromContent(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.startsWith('# ')) {
        final title = line.substring(2).trim();
        // Convert "Project Manifesto" → "PROJECT_MANIFESTO"
        return title.toUpperCase().replaceAll(' ', '_');
      }
    }
    return 'DOCUMENT';
  }

  /// Returns the correct file path for a document type.
  /// Handles special cases like README.md in root.
  String _getFilePathForDocType(String docType, String content) {
    // Special case: README always goes to root
    if (docType.contains('README') ||
        content.toUpperCase().startsWith('# README')) {
      return 'README.md';
    }

    // Get section folder
    final section = _getSectionForDocType(docType);

    // Convert doc type to filename
    // "PROJECT_MANIFESTO" → "PROJECT_MANIFESTO.md"
    final fileName = '${docType.toUpperCase()}.md';

    return '$section/$fileName';
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
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId,
  ) async* {
    // Mock implementation - simulate streaming response
    yield const TokenEvent(token: 'Mock');
    yield const TokenEvent(token: ' response');
    yield const DoneEvent(fullResponse: 'Mock response');
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    // Mock implementation - does nothing
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async => [];

  @override
  Future<void> saveMessage(String projectId, ChatMessage message) async {
    // Mock implementation - does nothing
  }

  @override
  Future<void> clearChatHistory(String projectId) async {}
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(baseUrl: _backendBaseUrl, apiKey: _backendApiKey),
);

final mockChatRepositoryProvider = Provider<ChatRepository>(
  (ref) => _MockChatRepository(),
);

final fileSystemServiceProvider = Provider<FileSystemService>(
  (ref) => FileSystemServiceImpl(),
);

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    repository: ref.watch(chatRepositoryProvider),
    mockRepository: ref.watch(mockChatRepositoryProvider),
    fileSystemService: ref.watch(fileSystemServiceProvider),
    ref: ref,
  ),
);
