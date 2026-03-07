import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../domain/entities/chat_stream_event.dart';
import '../../../../features/filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../../features/project_shell/core/services/file_system_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
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
       super(const ChatState(totalDocs: 24)); // 👈 TOTAL DOCS ACTUALIZADO A 24

  final ChatRepository _repository;
  final ChatRepository _mockRepository;
  final FileSystemService _fileSystemService;
  final Ref ref;

  /// Active stream subscription for current streaming operation.
  /// Used to cancel streaming when changing projects or disposing notifier.
  StreamSubscription<ChatStreamEvent>? _activeStreamSubscription;

  /// Project ID of the currently active stream.
  /// Used to verify chunks belong to the correct project.
  String? _activeStreamProjectId;

  /// Sets the project path for document saving.
  Future<void> setProjectPath(String path) async {
    await _cancelActiveStream();

    state = ChatState.initial().copyWith(
      projectPath: path,
      isLoading: true,
      totalDocs: 24,
    );
    final projectId = UuidGenerator.fromString(path);

    // ignore: avoid_print
    print('📂 Loading history for project: $path (ID: $projectId)');

    try {
      debugPrint('🔍 Fetching chat history from DB...');
      final history = await _repository.getChatHistory(projectId);
      debugPrint('📖 Loaded ${history.length} messages from DB');

      state = state.copyWith(messages: history, isLoading: false);
    } on Exception catch (e, stackTrace) {
      debugPrint('🔥 Stack trace: $stackTrace');
      // ignore: avoid_print
      print('❌ Failed to load chat history: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load chat history: $e',
      );
    }
  }

  /// Sends a user message and streams the AI response using SSE.
  Future<void> sendMessageStream(
    String message, {
    bool isHidden = false,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    await _cancelActiveStream();

    try {
      state = state.clearError();

      final userMessage = ChatMessage(
        id: generateId(),
        role: MessageRole.user,
        content: message,
        timestamp: DateTime.now().toIso8601String(),
        metadata: isHidden ? {'hidden': true} : null,
      );

      final updatedMessages = isHidden
          ? state.messages
          : [...state.messages, userMessage];
      state = state.copyWith(messages: updatedMessages, isStreaming: true);

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

      final streamBuffer = StringBuffer();

      final projectPath = state.projectPath;
      if (projectPath == null) {
        throw ProjectContextError(
          'No project context initialized. Call setProjectPath() first.',
        );
      }

      final isGuideProject = projectPath.startsWith('mock://');
      final repository = isGuideProject ? _mockRepository : _repository;
      final projectId = UuidGenerator.fromString(projectPath);

      if (!isGuideProject) {
        try {
          debugPrint(
            '💾 Attempting to save user message: '
            '${userMessage.id} for project: $projectId',
          );
          await _repository.saveMessage(projectId, userMessage);
        } on Exception catch (e, stackTrace) {
          debugPrint('🔥 Failed to save user message: $e\n$stackTrace');
          state = state.copyWith(
            hasError: true,
            errorMessage: 'Warning: Your message was not saved: $e',
          );
        }
      }

      _activeStreamProjectId = projectId;

      // 🎯 PASAMOS EL DOC_TYPE ACTUAL A LA REQUEST
      final currentDocType = _getDocTypeForCurrentIndex();

      // 🎯 LEEMOS EL NOMBRE DEL USUARIO DE FORMA REACTIVA DESDE LOS AJUSTES
      final currentUserName = ref.read(userNameProvider);

      final stream = repository.sendMessageStream(
        message,
        projectId,
        docType: currentDocType,
        userName: currentUserName,
      );

      _activeStreamSubscription = stream.listen(
        (event) {
          if (_activeStreamProjectId != projectId) {
            return;
          }

          if (event is TokenEvent) {
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
            // 🎯 SOLUCIÓN: Si el backend envía un string vacío, nos quedamos
            // con todo lo que hemos ido acumulando en el streamBuffer.
            final fullResponse = (event.fullResponse.isEmpty)
                ? streamBuffer.toString()
                : event.fullResponse;

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

            DocumentProposal? proposal;
            if (!isHidden) {
              proposal = DocumentProposal(
                id: generateId(),
                docType: currentDocType,
                content: fullResponse,
                metadata: {'doc_index': state.currentDocIndex},
                validationState: ValidationState.pending,
              );
            }

            state = state.copyWith(
              messages: finalMessages,
              currentProposal: isHidden ? state.currentProposal : proposal,
              isStreaming: false,
            );

            if (!isGuideProject) {
              _repository.saveMessage(projectId, completedAssistant).catchError(
                (e) {
                  debugPrint('❌ Failed to save assistant message: $e');
                },
              );
            }
          } else if (event is ErrorEvent) {
            state = state.copyWith(
              isStreaming: false,
              hasError: true,
              errorMessage: event.error,
            );
          }
        },
        onError: (error) {
          debugPrint('❌ Stream error: $error');
          state = state.copyWith(
            isStreaming: false,
            hasError: true,
            errorMessage: error.toString(),
          );
          _activeStreamSubscription = null;
          _activeStreamProjectId = null;
        },
        onDone: () {
          debugPrint('✅ Stream completed');
          _activeStreamSubscription = null;
          _activeStreamProjectId = null;
        },
        cancelOnError: true,
      );

      final subscriptionToAwait = _activeStreamSubscription;
      await subscriptionToAwait?.asFuture();
    } on ProjectContextError catch (e) {
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
  /// Saves to filesystem with intelligent path detection based
  /// on the 24-step workflow.
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

      if (messageId != null) {
        final message = state.messages.firstWhere(
          (m) => m.id == messageId,
          orElse: () => throw Exception('Message not found'),
        );
        content = message.content;

        // 🎯 LÓGICA BLINDADA: Usamos el estado interno
        docType = _getDocTypeForCurrentIndex();
      } else {
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

      final relativePath = _getFilePathForDocType(docType, content);

      debugPrint('📝 Validating document: $docType');
      debugPrint('📂 Target path: $projectPath/$relativePath');

      await _fileSystemService.saveDocument(
        projectPath: projectPath,
        relativePath: relativePath,
        content: content,
      );

      debugPrint('✅ Document saved successfully');

      final newValidatedIds = {...state.validatedMessageIds};
      if (messageId != null) {
        newValidatedIds.add(messageId);
      }

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

      ref.read(fileSystemNotifierProvider.notifier).refresh();

      final shouldAdvanceWorkflow =
          messageId == null && state.currentProposal != null;
      final savedDocumentPath = relativePath;

      state = state.copyWith(
        validatedMessageIds: newValidatedIds,
        clearProposal: messageId == null,
      );

      if (shouldAdvanceWorkflow) {
        // Incrementamos el índice
        state = state.copyWith(currentDocIndex: state.currentDocIndex + 1);

        if (state.currentDocIndex <= state.totalDocs) {
          debugPrint('🤖 Sending silent validation message to backend');
          final nextDocType = _getDocTypeForCurrentIndex();

          await sendMessageStream(
            'He validado y guardado el documento en '
            '$savedDocumentPath. Por favor, genera ahora la propuesta '
            'técnica y el documento para el paso: $nextDocType.',
            isHidden: true,
          );
        } else {
          debugPrint('🎉 All documents completed!');
          addSystemMessage(
            '🎉 **¡Felicidades!** Has completado el Master Workflow. '
            'Todos los documentos están generados y guardados en tu proyecto.',
          );
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

  /// Maps current doc index to document type according to the
  /// 24-step MASTER WORKFLOW.
  String _getDocTypeForCurrentIndex() {
    final docTypes = [
      'PROJECT_MANIFESTO',
      'DOMAIN_LANGUAGE',
      'USER_JOURNEY_MAP',
      'REQUIREMENTS_MASTER',
      'USER_STORIES_MASTER',
      'SECURITY_PRIVACY_POLICY',
      'COMPLIANCE_MATRIX',
      'TECH_STACK_DECISION',
      'DATA_MODEL_SCHEMA',
      'API_INTERFACE_CONTRACT',
      'PROJECT_STRUCTURE_MAP',
      'SECURITY_THREAT_MODEL',
      'ARCH_DECISION_RECORDS',
      'DESIGN_SYSTEM',
      'UI_WIREFRAMES_FLOW',
      'ACCESSIBILITY_GUIDE',
      'ROADMAP_PHASES',
      'DEPLOYMENT_INFRASTRUCTURE',
      'CI_CD_PIPELINE',
      'TESTING_STRATEGY',
      'RULES',
      'CONTRIBUTING',
      'AGENTS',
      'README',
    ];

    final index = (state.currentDocIndex - 1).clamp(0, docTypes.length - 1);
    return docTypes[index];
  }

  /// Maps doc type to section folder (Matches Python Backend)
  String _getSectionForDocType(String docType) {
    if ([
      'PROJECT_MANIFESTO',
      'DOMAIN_LANGUAGE',
      'USER_JOURNEY_MAP',
    ].contains(docType)) {
      return '10-CONTEXT';
    }
    if ([
      'REQUIREMENTS_MASTER',
      'USER_STORIES_MASTER',
      'SECURITY_PRIVACY_POLICY',
      'COMPLIANCE_MATRIX',
    ].contains(docType)) {
      return '20-REQUIREMENTS';
    }
    if ([
      'TECH_STACK_DECISION',
      'DATA_MODEL_SCHEMA',
      'API_INTERFACE_CONTRACT',
      'PROJECT_STRUCTURE_MAP',
      'SECURITY_THREAT_MODEL',
      'ARCH_DECISION_RECORDS',
    ].contains(docType)) {
      return '30-ARCHITECTURE';
    }
    if ([
      'DESIGN_SYSTEM',
      'UI_WIREFRAMES_FLOW',
      'ACCESSIBILITY_GUIDE',
    ].contains(docType)) {
      return '35-UX_UI';
    }
    if ([
      'ROADMAP_PHASES',
      'DEPLOYMENT_INFRASTRUCTURE',
      'CI_CD_PIPELINE',
      'TESTING_STRATEGY',
    ].contains(docType)) {
      return '40-PLANNING';
    }
    return '';
  }

  /// Returns the correct file path for a document type.
  String _getFilePathForDocType(String docType, String content) {
    if (['RULES', 'CONTRIBUTING', 'AGENTS', 'README'].contains(docType) ||
        docType.contains('README') ||
        content.toUpperCase().startsWith('# README')) {
      return '$docType.md';
    }

    final section = _getSectionForDocType(docType);
    final extension = docType == 'USER_STORIES_MASTER' ? '.json' : '.md';
    return 'context/$section/$docType$extension';
  }

  void rejectProposal() {
    state = state.copyWith(clearProposal: true);
  }

  Future<void> regenerateProposal() async {
    if (state.messages.isEmpty) {
      return;
    }
    final lastUserMessage = state.messages
        .lastWhere(
          (msg) => msg.role == MessageRole.user,
          orElse: () => state.messages.first,
        )
        .content;
    state = state.copyWith(clearProposal: true);
    await sendMessageStream('Regenera el documento: $lastUserMessage');
  }

  void clearError() {
    state = state.clearError();
  }

  void resetForNewProject({int totalDocs = 24}) {
    state = ChatState(totalDocs: totalDocs);
  }

  Future<void> retryLastMessage() async {
    if (state.messages.length < 2) {
      return;
    }
    final lastUserMessage = state.messages
        .lastWhere((msg) => msg.role == MessageRole.user)
        .content;
    state = state.clearError();
    await sendMessageStream(lastUserMessage);
  }

  void addSystemMessage(String content) {
    final systemMessage = ChatMessage(
      id: generateId(),
      role: MessageRole.system,
      content: content,
      timestamp: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(messages: [...state.messages, systemMessage]);
  }

  Future<void> _cancelActiveStream() async {
    if (_activeStreamSubscription != null) {
      await _activeStreamSubscription!.cancel();
      _activeStreamSubscription = null;
      _activeStreamProjectId = null;
      if (state.isStreaming) {
        state = state.copyWith(isStreaming: false);
      }
    }
  }

  @override
  void dispose() {
    _activeStreamSubscription?.cancel();
    _activeStreamSubscription = null;
    _activeStreamProjectId = null;
    super.dispose();
  }
}

class _MockChatRepository implements ChatRepository {
  @override
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) async* {
    yield 'Mock';
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId, {
    String? docType, // 👈 AÑADIDO AL MOCK
    String? userName,
  }) async* {
    yield const TokenEvent(token: 'Mock');
    yield const TokenEvent(token: ' response');
    yield const DoneEvent(fullResponse: 'Mock response');
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {}

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async => [];

  @override
  Future<void> saveMessage(String projectId, ChatMessage message) async {}

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
