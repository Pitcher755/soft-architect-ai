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

/// Custom exception for missing project context
class ProjectContextError implements Exception {
  ProjectContextError(this.message);
  final String message;

  @override
  String toString() => 'ProjectContextError: $message';
}

/// Generate unique ID using UUID v4
String generateId() => UuidGenerator.v4();

const String _backendBaseUrl = String.fromEnvironment(
  'BACKEND_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
const String _backendApiKey = String.fromEnvironment(
  'BACKEND_API_KEY',
  defaultValue: 'dev_test_key_12345',
);

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

  // 🛡️ BLOQUEO ANTI-DOBLE CLIC
  bool _isValidating = false;

  Future<void> setProjectPath(String path) async {
    await _cancelActiveStream();

    state = ChatState.initial().copyWith(
      projectPath: path,
      isLoading: true,
      totalDocs: 24,
    );
    final projectId = UuidGenerator.fromString(path);

    try {
      // 1. CARGAR HISTORIAL DE CHAT
      final history = await _repository.getChatHistory(projectId);

      // 2. 🎯 RECUPERAR EL PASO PERSISTENTE DE LA BASE DE DATOS
      // Usamos el método estático real loadProgress y leemos la
      // propiedad documentosCreados
      var savedIndex = 1;
      if (!path.startsWith('mock://')) {
        final progress = await ProjectProgressService.loadProgress(path);
        // Si tiene 1 documento creado, el siguiente a pedir es el 2.
        savedIndex = (progress?.documentosCreados ?? 0) + 1;
      }

      debugPrint(
        '🔄 [LOAD_STATE] Cargado progreso persistente. '
        'Índice actual: $savedIndex',
      );

      state = state.copyWith(
        messages: history,
        isLoading: false,
        currentDocIndex: savedIndex, // 👈 RESTAURAMOS EL ÍNDICE REAL
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load chat history: $e',
      );
    }
  }

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

      if (!isGuideProject && !isHidden) {
        try {
          await _repository.saveMessage(projectId, userMessage);
        } on Exception catch (e) {
          debugPrint('Warning: Message not saved: $e');
        }
      }

      _activeStreamProjectId = projectId;

      final currentDocType = _getDocTypeForIndex(state.currentDocIndex);
      debugPrint(
        '🚀 [SEND_STREAM] Pidiendo al backend el documento de índice: '
        '${state.currentDocIndex} -> Tipo: $currentDocType',
      );

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
            final fullResponse = event.fullResponse.isEmpty
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

            if (!isGuideProject && !isHidden) {
              _repository
                  .saveMessage(projectId, completedAssistant)
                  .catchError((e) => debugPrint('Error saving async msg'));
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
        onDone: () {
          _activeStreamSubscription = null;
        },
        cancelOnError: true,
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

  Future<void> validateProposal([String? messageId]) async {
    if (_isValidating) {
      debugPrint('⚠️ [VALIDATE] Ignorando pulsación doble.');
      return;
    }
    _isValidating = true;

    try {
      final projectPath = state.projectPath;
      if (projectPath == null) {
        throw Exception('No project context');
      }

      String content;
      String docType;

      if (messageId != null) {
        try {
          final message = state.messages.firstWhere((m) => m.id == messageId);
          content = message.content;
          docType = _getDocTypeForIndex(state.currentDocIndex);
        } on StateError {
          throw Exception('Message not found');
        }
      } else {
        final proposal = state.currentProposal;
        if (proposal == null) {
          throw Exception('No proposal to validate');
        }
        content = proposal.content;
        docType = proposal.docType;
      }

      final relativePath = _getFilePathForDocType(docType, content);

      debugPrint(
        '💾 [VALIDATE] Guardando índice actual: '
        '${state.currentDocIndex} -> Tipo: $docType',
      );

      await _fileSystemService.saveDocument(
        projectPath: projectPath,
        relativePath: relativePath,
        content: content,
      );

      final newValidatedIds = {...state.validatedMessageIds};
      if (messageId != null) {
        newValidatedIds.add(messageId);
      }

      ref.read(fileSystemNotifierProvider.notifier).refresh();

      final shouldAdvanceWorkflow =
          messageId == null && state.currentProposal != null;

      if (shouldAdvanceWorkflow) {
        final oldIndex = state.currentDocIndex;
        final nextIndex = oldIndex + 1;

        debugPrint(
          '🔢 [VALIDATE] Cálculo de salto: '
          'De índice $oldIndex pasamos a $nextIndex',
        );

        // 🎯 3. GUARDAMOS EL NUEVO ÍNDICE DE FORMA PERSISTENTE
        if (!projectPath.startsWith('mock://')) {
          await ProjectProgressService.updateAfterDocumentSave(projectPath);
          debugPrint(
            '💾 [DB] Progreso (status.json) actualizado para '
            'paso $nextIndex',
          );
        }

        // Actualizamos el estado
        state = state.copyWith(
          validatedMessageIds: newValidatedIds,
          clearProposal: true,
          currentDocIndex: nextIndex,
        );

        if (nextIndex <= state.totalDocs) {
          final nextDocType = _getDocTypeForIndex(nextIndex);
          debugPrint('🚀 [VALIDATE] El siguiente paso real será: $nextDocType');

          await sendMessageStream(
            'The previous document was validated. Please generate the '
            'document for step: $nextDocType.',
            isHidden: true,
          );
        } else {
          addSystemMessage('🎉 Workflow completado.');
        }
      } else {
        state = state.copyWith(
          validatedMessageIds: newValidatedIds,
          clearProposal: messageId == null,
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(hasError: true, errorMessage: 'Error saving: $e');
    } finally {
      _isValidating = false;
    }
  }

  String _getDocTypeForIndex(int targetIndex) {
    final docTypes = [
      'PROJECT_MANIFESTO', // Index 1 (Array pos 0)
      'DOMAIN_LANGUAGE', // Index 2 (Array pos 1)
      'USER_JOURNEY_MAP', // Index 3 (Array pos 2)
      'REQUIREMENTS_MASTER', // Index 4 (Array pos 3)
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

    final arrayPos = targetIndex - 1;
    final safePos = arrayPos.clamp(0, docTypes.length - 1);

    debugPrint(
      '🔎 [ARRAY_LOOKUP] UI Index pedida: $targetIndex -> '
      'Posición de array: $safePos -> '
      'Resuelve a: ${docTypes[safePos]}',
    );

    return docTypes[safePos];
  }

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

  String _getFilePathForDocType(String docType, String content) {
    if (['RULES', 'CONTRIBUTING', 'AGENTS', 'README'].contains(docType) ||
        docType.contains('README')) {
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
    await sendMessageStream('Regenerate the document: $lastUserMessage');
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
    String? docType,
    String? userName,
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

// Volvemos al provider original sin inventar dependencias
final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    repository: ref.watch(chatRepositoryProvider),
    mockRepository: ref.watch(mockChatRepositoryProvider),
    fileSystemService: ref.watch(fileSystemServiceProvider),
    ref: ref,
  ),
);
