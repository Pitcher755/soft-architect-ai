import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../domain/entities/chat_stream_event.dart';
import '../../../../features/filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../../features/project_shell/core/services/file_system_service.dart';
import '../../../../features/project_shell/infrastructure/services/project_progress_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';
import 'streaming_state.dart';

/// Custom exception thrown when project context is missing or invalid.
///
/// This error indicates that an operation requiring project context
/// was attempted without a valid project path being set.
class ProjectContextError implements Exception {
  ProjectContextError(this.message);
  final String message;
  @override
  String toString() => 'ProjectContextError: $message';
}

/// Generates a unique identifier using UUID v4.
///
/// Returns a string representation of a randomly generated UUID.
String generateId() => UuidGenerator.v4();

const String _backendBaseUrl = String.fromEnvironment(
  'BACKEND_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
const String _backendApiKey = String.fromEnvironment(
  'BACKEND_API_KEY',
  defaultValue: 'dev_test_key_12345',
);

/// Manages chat state and orchestrates AI-powered document generation workflow.
///
/// This notifier handles:
/// - Message streaming from AI backend
/// - Document validation and workflow progression
/// - Project context management
/// - Chat history persistence
///
/// The workflow progresses through 24 mandatory documents following the
/// Master Workflow 0-100 structure.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier({
    required ChatRepository repository,
    required ChatRepository mockRepository,
    required FileSystemService fileSystemService,
    required this.ref,
  }) : _repository = repository,
       _mockRepository = mockRepository,
       _fileSystemService = fileSystemService,
       super(const ChatState(totalDocs: 24));

  final ChatRepository _repository;
  final ChatRepository _mockRepository;
  final FileSystemService _fileSystemService;
  final Ref ref;

  StreamSubscription<ChatStreamEvent>? _activeStreamSubscription;
  String? _activeStreamProjectId;
  bool _isValidating = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. INITIALIZATION & STATE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  /// Initializes a new project session and loads chat history.
  ///
  /// Cancels any active streams, resets state, and loads workflow progress
  /// from the project's `.softarchitect/status.json` file.
  ///
  /// [path] - Absolute path to the project directory.
  Future<void> setProjectPath(String path) async {
    await _cancelActiveStream();

    state = ChatState.initial().copyWith(
      projectPath: path,
      isLoading: true,
      totalDocs: 24,
    );

    final projectId = UuidGenerator.fromString(path);

    try {
      final history = await _repository.getChatHistory(projectId);

      final visibleHistory = history.where((msg) {
        final isHidden = msg.metadata?['hidden'] == true;
        return !isHidden;
      }).toList();

      var savedIndex = 1;

      if (!path.startsWith('mock://')) {
        final progress = await ProjectProgressService.loadProgress(path);
        savedIndex = (progress?.documentosCreados ?? 0) + 1;
      }

      state = state.copyWith(
        messages: visibleHistory,
        isLoading: false,
        currentDocIndex: savedIndex,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load chat history: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. CORE CHAT & STREAMING LOGIC
  // ═══════════════════════════════════════════════════════════════════════════
  /// Sends a message to the AI backend and streams the response.
  ///
  /// Creates user and assistant messages, streams tokens from the backend,
  /// and generates a [DocumentProposal] when complete.
  ///
  /// [message] - The user's input text.
  /// [isHidden] - If true, the message is not added to visible chat history
  /// (used for silent validation workflows).
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
        throw ProjectContextError('No project context');
      }

      final isGuideProject = projectPath.startsWith('mock://');
      final repository = isGuideProject ? _mockRepository : _repository;
      final projectId = UuidGenerator.fromString(projectPath);

      if (!isGuideProject) {
        await _repository
            .saveMessage(projectId, userMessage)
            .catchError((e) => debugPrint('Error saving msg: $e'));
      }

      _activeStreamProjectId = projectId;
      final currentDocType = _getDocTypeForIndex(state.currentDocIndex);
      final currentUserName = ref.read(userNameProvider);

      // 🎯 FIX 422: Mapeo estricto del historial (Solo role y content)
      final compatibleHistory = state.messages
          .where((msg) => msg.role != MessageRole.system)
          .map(
            (msg) => ChatMessage(
              id: '',
              role: msg.role,
              content: msg.content,
              timestamp: '',
            ),
          )
          .toList();

      final stream = repository.sendMessageStream(
        message,
        projectId,
        docType: currentDocType,
        userName: currentUserName,
        history: compatibleHistory,
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
            state = state.copyWith(
              messages: [
                ...messagesWithAssistant.sublist(
                  0,
                  messagesWithAssistant.length - 1,
                ),
                updatedAssistant,
              ],
              isStreaming: true,
            );
          } else if (event is DoneEvent) {
            final fullResponse = event.fullResponse.isEmpty
                ? streamBuffer.toString()
                : event.fullResponse;
            final completedAssistant = assistantMessage.copyWith(
              content: fullResponse,
              isStreaming: false,
            );
            state = state.copyWith(
              messages: [
                ...messagesWithAssistant.sublist(
                  0,
                  messagesWithAssistant.length - 1,
                ),
                completedAssistant,
              ],
              currentProposal: isHidden
                  ? state.currentProposal
                  : DocumentProposal(
                      id: generateId(),
                      docType: currentDocType,
                      content: fullResponse,
                      metadata: {'doc_index': state.currentDocIndex},
                      validationState: ValidationState.pending,
                    ),
              isStreaming: false,
            );
            if (!isGuideProject) {
              _repository.saveMessage(projectId, completedAssistant);
            }
          } else if (event is ErrorEvent) {
            state = state.copyWith(
              isStreaming: false,
              hasError: true,
              errorMessage: event.error,
            );
          }
        },
        onError: (e) {
          state = state.copyWith(
            isStreaming: false,
            hasError: true,
            errorMessage: e.toString(),
          );
          _activeStreamSubscription = null;
        },
        onDone: () => _activeStreamSubscription = null,
      );
      await _activeStreamSubscription?.asFuture();
    } on Exception catch (e) {
      state = state.copyWith(
        isStreaming: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. DOCUMENT VALIDATION & WORKFLOW ENGINE
  // ═══════════════════════════════════════════════════════════════════════════
  /// Validates a document proposal and saves it to the project filesystem.
  ///
  /// This method:
  /// 1. Cleans the document content (removes markdown fences, metadata)
  /// 2. Determines the document type based on current workflow index
  /// 3. Saves the file to the appropriate context/section folder
  /// 4. Updates workflow progress (advances to next document)
  /// 5. Refreshes the filesystem notifier
  ///
  /// [messageId] - Optional message ID to validate a specific message.
  /// If null, validates the current proposal.
  Future<void> validateProposal([String? messageId]) async {
    if (_isValidating) {
      return;
    }
    _isValidating = true;
    try {
      final projectPath = state.projectPath;
      if (projectPath == null) {
        throw Exception('No project context');
      }

      String content;
      final docType = _getDocTypeForIndex(state.currentDocIndex);

      if (messageId != null) {
        final message = state.messages.firstWhere(
          (m) => m.id == messageId,
          orElse: () => throw Exception('Message not found'),
        );
        content = message.content;
      } else {
        if (state.currentProposal == null) {
          throw Exception('No proposal');
        }
        content = state.currentProposal!.content;
      }

      // 🎯 LIMPIEZA CIRUJANA: Solo aquí quitamos las marcas
      // para el archivo real
      final cleanedContent = _cleanDocumentContent(content);
      final relativePath = _getFilePathForDocType(docType, cleanedContent);

      await _fileSystemService.saveDocument(
        projectPath: projectPath,
        relativePath: relativePath,
        content: cleanedContent,
      );

      addSystemMessage('✅ Documento validado y guardado en `$relativePath`');
      ref.read(fileSystemNotifierProvider.notifier).refresh();

      // Marcar mensaje como validado (si hay messageId específico)
      final updatedValidatedIds = messageId != null
          ? {...state.validatedMessageIds, messageId}
          : state.validatedMessageIds;

      // 🎯 FIX (Tarea 0.5): SIEMPRE avanzar el workflow tras validación exitosa
      // ANTI-REGRESIÓN: NO bloquear el avance basándose en la presencia/ausencia de messageId
      final nextIndex = state.currentDocIndex + 1;
      if (!projectPath.startsWith('mock://')) {
        await ProjectProgressService.updateAfterDocumentSave(projectPath);
      }

      state = state.copyWith(
        clearProposal: true,
        currentDocIndex: nextIndex,
        validatedMessageIds: updatedValidatedIds,
      );

      if (nextIndex <= state.totalDocs) {
        final nextDoc = _getDocTypeForIndex(nextIndex);
        await sendMessageStream(
          'He validado el documento anterior. '
          'Por favor, genera ahora: $nextDoc',
          isHidden: true,
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(hasError: true, errorMessage: 'Error saving: $e');
    } finally {
      _isValidating = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. STRING UTILITIES & PATH ROUTING
  // ═══════════════════════════════════════════════════════════════════════════
  /// Removes markdown fences, metadata tags, and duplicate path labels.
  String _cleanDocumentContent(String rawContent) {
    var clean = rawContent;
    if (clean.contains('[document]')) {
      clean = clean.split('[document]').last;
    }

    // 🎯 LIMPIEZA ROBUSTA: Regex para eliminar cualquier apertura/cierre de bloques de código
    clean = clean.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '');
    clean = clean.replaceAll('```', '');

    // Limpieza de etiquetas de ruta duplicadas
    clean = clean.replaceAll(
      RegExp(r'\*\*(Path|File|Ruta):\*\*.*?\n', caseSensitive: false),
      '',
    );

    return clean.trim();
  }

  String _getDocTypeForIndex(int targetIndex) {
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
    return docTypes[(targetIndex - 1).clamp(0, docTypes.length - 1)];
  }

  String _getFilePathForDocType(String docType, String content) {
    if (docType == 'USER_STORIES_MASTER') {
      return 'context/20-REQUIREMENTS/USER_STORIES_MASTER.json';
    }

    final sectionMap = {
      'PROJECT_MANIFESTO': '10-CONTEXT',
      'DOMAIN_LANGUAGE': '10-CONTEXT',
      'USER_JOURNEY_MAP': '10-CONTEXT',
      'REQUIREMENTS_MASTER': '20-REQUIREMENTS',
      'SECURITY_PRIVACY_POLICY': '20-REQUIREMENTS',
      'COMPLIANCE_MATRIX': '20-REQUIREMENTS',
      'TECH_STACK_DECISION': '30-ARCHITECTURE',
      'DATA_MODEL_SCHEMA': '30-ARCHITECTURE',
      'API_INTERFACE_CONTRACT': '30-ARCHITECTURE',
      'PROJECT_STRUCTURE_MAP': '30-ARCHITECTURE',
      'SECURITY_THREAT_MODEL': '30-ARCHITECTURE',
      'ARCH_DECISION_RECORDS': '30-ARCHITECTURE',
      'DESIGN_SYSTEM': '35-UX_UI',
      'UI_WIREFRAMES_FLOW': '35-UX_UI',
      'ACCESSIBILITY_GUIDE': '35-UX_UI',
      'ROADMAP_PHASES': '40-PLANNING',
      'DEPLOYMENT_INFRASTRUCTURE': '40-PLANNING',
      'CI_CD_PIPELINE': '40-PLANNING',
      'TESTING_STRATEGY': '40-PLANNING',
    };

    if (sectionMap.containsKey(docType)) {
      return 'context/${sectionMap[docType]}/$docType.md';
    }
    return '$docType.md';
  }

  // ══════════════════════════════════════════════════════════════
  // 5. HELPER ACTIONS
  // ══════════════════════════════════════════════════════════════

  /// Adds a system message to the chat history.
  ///
  /// System messages are used for workflow notifications and context updates.
  void addSystemMessage(String content) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: generateId(),
          role: MessageRole.system,
          content: content,
          timestamp: DateTime.now().toIso8601String(),
        ),
      ],
    );
  }

  /// Resets the notifier state for a new project session.
  ///
  /// [totalDocs] - Total number of documents in the workflow (default: 24).
  void resetForNewProject({int totalDocs = 24}) {
    state = ChatState(totalDocs: totalDocs);
  }

  /// Rejects the current document proposal and clears it from state.
  void rejectProposal() => state = state.copyWith(clearProposal: true);

  /// Retries sending the last user message.
  ///
  /// Resends the most recent user message to the AI backend.
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

  Future<void> _cancelActiveStream() async {
    await _activeStreamSubscription?.cancel();
    _activeStreamSubscription = null;
    if (state.isStreaming) {
      state = state.copyWith(isStreaming: false);
    }
  }

  @override
  void dispose() {
    _activeStreamSubscription?.cancel();
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 6. PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

/// Mock implementation of [ChatRepository] for guide/tutorial flows.
///
/// Returns canned responses without making real API calls.
class _MockChatRepository implements ChatRepository {
  @override
  Stream<String> generateDocument(
    String d,
    String u,
    Map<String, dynamic> c,
  ) async* {
    yield 'Mock';
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(
    String m,
    String p, {
    String? docType,
    String? userName,
    List<ChatMessage>? history,
  }) async* {
    yield const TokenEvent(token: 'Mock');
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
