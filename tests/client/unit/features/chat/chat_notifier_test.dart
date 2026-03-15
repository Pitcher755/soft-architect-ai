// tests/client/unit/features/chat/chat_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/utils/uuid_generator.dart';
import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:softarchitect_ai/features/chat/presentation/notifiers/chat_notifier.dart';
import 'package:softarchitect_ai/features/chat/presentation/notifiers/streaming_state.dart';
import 'package:softarchitect_ai/features/project_shell/core/services/file_system_service.dart';

/// Fake ChatRepository for testing
class FakeChatRepository implements ChatRepository {
  final Map<String, List<ChatMessage>> _storage = {};

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async {
    return _storage[projectId] ?? [];
  }

  @override
  Future<void> saveMessage(String projectId, ChatMessage message) async {
    _storage.putIfAbsent(projectId, () => []);
    _storage[projectId]!.add(message);
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(
    String projectPath,
    String message, {
    String? docType,
    String? userName,
    List<ChatMessage>? history,
    Map<String, String>? projectContext,
  }) {
    final events = <ChatStreamEvent>[
      TokenEvent(token: 'Fake', isFinal: false),
      TokenEvent(token: ' streaming', isFinal: false),
      TokenEvent(token: ' response', isFinal: true),
      DoneEvent(
        fullResponse: 'Fake streaming response',
        sources: const [],
        metadata: const {},
      ),
    ];
    return Stream.fromIterable(events);
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    _storage.remove(projectId);
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    // Not used in these tests
  }

  @override
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) {
    return Stream.value('Fake document content');
  }
}

/// Fake FileSystemService for testing
class FakeFileSystemService implements FileSystemService {
  @override
  Future<void> saveDocument({
    required String projectPath,
    required String relativePath,
    required String content,
  }) async {
    // No-op for tests
  }

  @override
  Future<String?> readDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    return null;
  }

  @override
  Future<bool> documentExists({
    required String projectPath,
    required String relativePath,
  }) async {
    return false;
  }

  @override
  Future<void> deleteDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    // No-op for tests
  }

  @override
  Future<void> initializeProjectDirectories({
    required String projectPath,
  }) async {
    // No-op for tests
  }
}

void main() {
  group('ChatNotifier - State Management', () {
    late FakeChatRepository fakeRepository;
    late FakeChatRepository fakeMockRepository;
    late FakeFileSystemService fakeFileSystemService;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeChatRepository();
      fakeMockRepository = FakeChatRepository();
      fakeFileSystemService = FakeFileSystemService();

      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepository),
          mockChatRepositoryProvider.overrideWithValue(fakeMockRepository),
          fileSystemServiceProvider.overrideWithValue(fakeFileSystemService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('setProjectPath() ALWAYS resets state to initial', () async {
      // ARRANGE: Fake repository returns empty history
      final notifier = container.read(chatNotifierProvider.notifier);

      // ACT: Set initial project path
      await notifier.setProjectPath('/home/user/project-a');

      // ASSERT: State should be clean with project-a path
      final stateAfterFirst = container.read(chatNotifierProvider);
      expect(stateAfterFirst.projectPath, '/home/user/project-a');
      expect(stateAfterFirst.messages, isEmpty);
      expect(stateAfterFirst.isLoading, false);

      // ACT: Switch to project-b
      await notifier.setProjectPath('/home/user/project-b');

      // ASSERT: State should be CLEAN (no polluted messages)
      final stateAfterSwitch = container.read(chatNotifierProvider);
      expect(stateAfterSwitch.projectPath, '/home/user/project-b');
      expect(stateAfterSwitch.messages, isEmpty);
      expect(stateAfterSwitch.currentDocIndex, 1);
      expect(stateAfterSwitch.currentProposal, isNull);
    });

    test('setProjectPath() loads chat history from SQLite', () async {
      // ARRANGE: Pre-populate fake repository with history
      final projectId = UuidGenerator.fromString('/home/user/my-project');
      final historicalMessages = [
        ChatMessage(
          id: 'msg-1',
          role: MessageRole.user,
          content: 'Historical message 1',
          timestamp: DateTime.now().toIso8601String(),
        ),
        ChatMessage(
          id: 'msg-2',
          role: MessageRole.assistant,
          content: 'Historical response 1',
          timestamp: DateTime.now().toIso8601String(),
        ),
      ];

      for (final msg in historicalMessages) {
        await fakeRepository.saveMessage(projectId, msg);
      }

      final notifier = container.read(chatNotifierProvider.notifier);

      // ACT: Set project path
      await notifier.setProjectPath('/home/user/my-project');

      // ASSERT: State should contain loaded history
      final state = container.read(chatNotifierProvider);
      expect(state.messages, hasLength(2));
      expect(state.messages[0].content, 'Historical message 1');
      expect(state.messages[1].content, 'Historical response 1');
    });

    test(
      'sendMessage() throws ProjectContextError if no projectPath',
      () async {
        // ARRANGE: Create notifier without setting project path
        final notifier = container.read(chatNotifierProvider.notifier);

        // ACT: Try to send message without project context
        await notifier.sendMessageStream('Hello without context');

        // ASSERT: State should have error message
        final state = container.read(chatNotifierProvider);
        expect(state.hasError, true);
        expect(state.errorMessage, contains('project context'));
        expect(state.isStreaming, false);
      },
    );

    test(
      'sendMessageStream() throws ProjectContextError if no projectPath',
      () async {
        // ARRANGE: Create notifier without setting project path
        final notifier = container.read(chatNotifierProvider.notifier);

        // ACT: Try to send message stream without project context
        await notifier.sendMessageStream('Hello stream without context');

        // ASSERT: State should have error message
        final state = container.read(chatNotifierProvider);
        expect(state.hasError, true);
        expect(state.errorMessage, contains('project context'));
        expect(state.isStreaming, false);
      },
    );

    test('ChatState.initial() factory creates clean state', () {
      // ACT: Create initial state
      final state = ChatState.initial();

      // ASSERT: All fields should be at default values
      expect(state.messages, isEmpty);
      expect(state.currentProposal, isNull);
      expect(state.currentDocIndex, 1);
      expect(state.totalDocs, 25);
      expect(state.isStreaming, false);
      expect(state.hasError, false);
      expect(state.errorMessage, isNull);
      expect(state.projectPath, isNull);
      expect(state.isLoading, false);
    });

    test(
      'Full workflow with project switching prevents state pollution',
      () async {
        // ARRANGE: Two projects with different chat histories
        final projectIdA = UuidGenerator.fromString('/home/user/project-a');
        final projectIdB = UuidGenerator.fromString('/home/user/project-b');

        final historyA = [
          ChatMessage(
            id: 'a-1',
            role: MessageRole.user,
            content: 'Message from project A',
            timestamp: DateTime.now().toIso8601String(),
          ),
        ];

        final historyB = [
          ChatMessage(
            id: 'b-1',
            role: MessageRole.user,
            content: 'Message from project B',
            timestamp: DateTime.now().toIso8601String(),
          ),
        ];

        await fakeRepository.saveMessage(projectIdA, historyA[0]);
        await fakeRepository.saveMessage(projectIdB, historyB[0]);

        final notifier = container.read(chatNotifierProvider.notifier);

        // ACT 1: Open project A
        await notifier.setProjectPath('/home/user/project-a');
        final stateA = container.read(chatNotifierProvider);

        // ASSERT 1: Should have only project A messages
        expect(stateA.messages, hasLength(1));
        expect(stateA.messages[0].content, 'Message from project A');

        // ACT 2: Switch to project B
        await notifier.setProjectPath('/home/user/project-b');
        final stateB = container.read(chatNotifierProvider);

        // ASSERT 2: Should have ONLY project B messages (NO POLLUTION)
        expect(stateB.messages, hasLength(1));
        expect(stateB.messages[0].content, 'Message from project B');

        // ACT 3: Switch back to project A
        await notifier.setProjectPath('/home/user/project-a');
        final stateA2 = container.read(chatNotifierProvider);

        // ASSERT 3: Should have project A messages again (NO POLLUTION)
        expect(stateA2.messages, hasLength(1));
        expect(stateA2.messages[0].content, 'Message from project A');
      },
    );
  });
}
