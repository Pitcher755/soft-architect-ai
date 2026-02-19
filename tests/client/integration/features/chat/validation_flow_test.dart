import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:softarchitect_ai/features/chat/presentation/notifiers/chat_notifier.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/notifiers/file_system_notifier.dart';
import 'package:softarchitect_ai/features/project_shell/core/services/file_system_service.dart';

// Fake implementations for integration testing
class FakeFileSystemService implements FileSystemService {
  final Map<String, String> savedFiles = {};
  final List<String> savedPaths = [];
  bool shouldFail = false;

  @override
  Future<void> saveDocument({
    required String projectPath,
    required String relativePath,
    required String content,
  }) async {
    if (shouldFail) {
      throw Exception('Failed to save document');
    }
    final fullPath = '$projectPath/$relativePath';
    savedFiles[fullPath] = content;
    savedPaths.add(relativePath);
  }

  @override
  Future<String?> readDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    return savedFiles[fullPath];
  }

  @override
  Future<bool> documentExists({
    required String projectPath,
    required String relativePath,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    return savedFiles.containsKey(fullPath);
  }

  @override
  Future<void> deleteDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    savedFiles.remove(fullPath);
  }

  @override
  Future<void> initializeProjectDirectories({
    required String projectPath,
  }) async {
    // No-op for testing
  }
}

class FakeChatRepository implements ChatRepository {
  List<String> generatedTokens = [];
  bool shouldFail = false;
  String errorMessage = 'Test error';
  final List<DocumentProposal> savedProposals = [];

  @override
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) async* {
    if (shouldFail) {
      throw Exception(errorMessage);
    }
    for (final token in generatedTokens) {
      yield token;
    }
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId,
  ) async* {
    if (shouldFail) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield ErrorEvent(
        error: errorMessage,
        code: 'TEST_ERROR',
        shouldRetry: false,
      );
      return;
    }
    for (final token in generatedTokens) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield TokenEvent(token: token, isFinal: false);
    }
    await Future.delayed(const Duration(milliseconds: 50));
    yield DoneEvent(
      fullResponse: generatedTokens.join(''),
      sources: [],
      metadata: {},
    );
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    savedProposals.add(proposal);
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async {
    return [];
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    // No-op for testing
  }

  @override
  Future<void> saveMessage(String projectId, ChatMessage message) async {
    // No-op for testing
  }
}

void main() {
  group('Validation Flow Integration Tests', () {
    late FakeChatRepository fakeRepository;
    late FakeFileSystemService fakeFileSystemService;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeChatRepository();
      fakeFileSystemService = FakeFileSystemService();
      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepository),
          fileSystemServiceProvider.overrideWithValue(fakeFileSystemService),
          fileSystemNotifierProvider.overrideWith((ref) {
            return FileSystemNotifier();
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('INTEGRATION: Complete validation flow with visual feedback', (
      tester,
    ) async {
      // 1. Setup: User creates project and sends message
      final notifier = container.read(chatNotifierProvider.notifier);
      const projectPath = '/tmp/integration_test_project';
      await notifier.setProjectPath(projectPath);

      // 2. AI generates document with markdown header
      fakeRepository.generatedTokens = [
        '# README\n\n',
        'This is a test project for ',
        'integration testing.',
      ];

      // Send message and wait for streaming to complete
      await notifier.sendMessageStream('Generate README');
      await tester.pumpAndSettle();

      // 3. Verify document was generated
      final stateAfterGeneration = container.read(chatNotifierProvider);
      expect(stateAfterGeneration.messages.length, greaterThanOrEqualTo(2));
      final assistantMessage = stateAfterGeneration.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );
      expect(assistantMessage.content, contains('README'));
      expect(assistantMessage.isStreaming, false);

      // 4. Verify validation button appears (gray, outline icon)
      expect(stateAfterGeneration.validatedMessageIds, isEmpty);

      // 5. User clicks validate button
      await notifier.validateProposal(assistantMessage.id);
      await tester.pumpAndSettle();

      // 6. Verify file was saved to correct location (README → root)
      expect(fakeFileSystemService.savedFiles, isNotEmpty);
      final savedPaths = fakeFileSystemService.savedPaths;
      expect(savedPaths, contains('README.md'));

      // 7. Verify button state changed (message marked as validated)
      final stateAfterValidation = container.read(chatNotifierProvider);
      expect(
        stateAfterValidation.validatedMessageIds.contains(assistantMessage.id),
        true,
      );

      // 8. Verify saved content is correct
      final savedContent =
          fakeFileSystemService.savedFiles['$projectPath/README.md'];
      expect(savedContent, contains('README'));
      expect(
        savedContent,
        contains('This is a test project for integration testing.'),
      );

      // 9. Verify proposal was saved to database
      expect(fakeRepository.savedProposals, isNotEmpty);
      final savedProposal = fakeRepository.savedProposals.first;
      expect(savedProposal.content, contains('README'));
      expect(savedProposal.validationState, ValidationState.validated);
    });

    testWidgets('INTEGRATION: Validate non-README document to section folder', (
      tester,
    ) async {
      final notifier = container.read(chatNotifierProvider.notifier);
      const projectPath = '/tmp/test_sections';
      await notifier.setProjectPath(projectPath);

      // Generate document with specific section header
      fakeRepository.generatedTokens = [
        '# PROJECT MANIFESTO\n\n',
        'Vision: Build amazing software\n\n',
        'Mission: Deliver value to users',
      ];

      await notifier.sendMessageStream('Generate manifesto');
      await tester.pumpAndSettle();

      final stateAfterGeneration = container.read(chatNotifierProvider);
      final assistantMessage = stateAfterGeneration.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Validate document
      await notifier.validateProposal(assistantMessage.id);
      await tester.pumpAndSettle();

      // Verify file was saved to section folder (not root)
      expect(fakeFileSystemService.savedFiles, isNotEmpty);
      final savedPaths = fakeFileSystemService.savedPaths;
      expect(savedPaths.length, 1);

      // Verify path contains section folder
      final savedPath = savedPaths.first;
      expect(savedPath, isNot('README.md')); // Not in root
      expect(savedPath, contains('/')); // Contains folder separator
    });

    testWidgets('INTEGRATION: Replace existing file on re-validation', (
      tester,
    ) async {
      final notifier = container.read(chatNotifierProvider.notifier);
      const projectPath = '/tmp/test_replace';
      await notifier.setProjectPath(projectPath);

      // Generate and validate first version
      fakeRepository.generatedTokens = ['# README\n\n', 'Version 1 content'];
      await notifier.sendMessageStream('Generate v1');
      await tester.pumpAndSettle();

      var state = container.read(chatNotifierProvider);
      var assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );
      await notifier.validateProposal(assistantMessage.id);
      await tester.pumpAndSettle();

      final firstContent =
          fakeFileSystemService.savedFiles['$projectPath/README.md'];
      expect(firstContent, contains('Version 1'));

      // Generate and validate second version (same document)
      fakeRepository.generatedTokens = [
        '# README\n\n',
        'Version 2 content (updated)',
      ];
      await notifier.sendMessageStream('Generate v2');
      await tester.pumpAndSettle();

      state = container.read(chatNotifierProvider);
      assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );
      await notifier.validateProposal(assistantMessage.id);
      await tester.pumpAndSettle();

      // Verify file was replaced (not duplicated)
      final secondContent =
          fakeFileSystemService.savedFiles['$projectPath/README.md'];
      expect(secondContent, contains('Version 2'));
      expect(secondContent, isNot(contains('Version 1')));

      // Verify only one README exists
      final readmeCount = fakeFileSystemService.savedFiles.keys
          .where((path) => path.endsWith('README.md'))
          .length;
      expect(readmeCount, 1);
    });

    testWidgets(
      'INTEGRATION: Multiple validations preserve independent states',
      (tester) async {
        final notifier = container.read(chatNotifierProvider.notifier);
        const projectPath = '/tmp/test_multiple';
        await notifier.setProjectPath(projectPath);

        // Generate README
        fakeRepository.generatedTokens = ['# README\n\n', 'First doc'];
        await notifier.sendMessageStream('Generate README');
        await tester.pumpAndSettle();

        var state = container.read(chatNotifierProvider);
        final readmeMessage = state.messages.lastWhere(
          (m) => m.role == MessageRole.assistant,
        );

        // Generate MANIFESTO
        fakeRepository.generatedTokens = [
          '# PROJECT MANIFESTO\n\n',
          'Second doc',
        ];
        await notifier.sendMessageStream('Generate manifesto');
        await tester.pumpAndSettle();

        state = container.read(chatNotifierProvider);
        final manifestoMessage = state.messages.lastWhere(
          (m) => m.role == MessageRole.assistant,
        );

        // Validate only README
        await notifier.validateProposal(readmeMessage.id);
        await tester.pumpAndSettle();

        state = container.read(chatNotifierProvider);
        expect(state.validatedMessageIds.contains(readmeMessage.id), true);
        expect(state.validatedMessageIds.contains(manifestoMessage.id), false);

        // Validate MANIFESTO
        await notifier.validateProposal(manifestoMessage.id);
        await tester.pumpAndSettle();

        state = container.read(chatNotifierProvider);
        expect(state.validatedMessageIds.contains(readmeMessage.id), true);
        expect(state.validatedMessageIds.contains(manifestoMessage.id), true);

        // Verify both files were saved
        expect(fakeFileSystemService.savedFiles.keys, hasLength(2));
      },
    );

    testWidgets('INTEGRATION: Error handling displays error state', (
      tester,
    ) async {
      final notifier = container.read(chatNotifierProvider.notifier);
      const projectPath = '/tmp/test_error';
      await notifier.setProjectPath(projectPath);

      // Generate document
      fakeRepository.generatedTokens = ['# TEST DOC\n\n', 'Content'];
      await notifier.sendMessageStream('Generate doc');
      await tester.pumpAndSettle();

      var state = container.read(chatNotifierProvider);
      final assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Simulate filesystem error
      fakeFileSystemService.shouldFail = true;

      // Attempt validation
      await notifier.validateProposal(assistantMessage.id);
      await tester.pumpAndSettle();

      // Verify error state
      state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('Failed to save document'));

      // Verify message was NOT marked as validated
      expect(state.validatedMessageIds.contains(assistantMessage.id), false);

      // Verify file was NOT saved
      expect(fakeFileSystemService.savedFiles, isEmpty);
    });

    testWidgets('INTEGRATION: Validation state persists across UI rebuilds', (
      tester,
    ) async {
      final notifier = container.read(chatNotifierProvider.notifier);
      const projectPath = '/tmp/test_persist';
      await notifier.setProjectPath(projectPath);

      // Generate and validate document
      fakeRepository.generatedTokens = ['# README\n\n', 'Persistent test'];
      await notifier.sendMessageStream('Generate README');
      await tester.pumpAndSettle();

      var state = container.read(chatNotifierProvider);
      final assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );
      await notifier.validateProposal(assistantMessage.id);
      await tester.pumpAndSettle();

      // Verify initial validation
      state = container.read(chatNotifierProvider);
      expect(state.validatedMessageIds.contains(assistantMessage.id), true);

      // Simulate UI rebuild with pump (state should persist in container)
      await tester.pump();

      // Verify validation state persisted after rebuild
      state = container.read(chatNotifierProvider);
      expect(state.validatedMessageIds.contains(assistantMessage.id), true);

      // Verify validatedMessageIds Set is still intact
      expect(state.validatedMessageIds, isA<Set<String>>());
      expect(state.validatedMessageIds.length, 1);
    });
  });
}

// UI model for MessageBubbleWidget (integration test context)
class ChatMessageUI {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessageUI({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });
}
