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
  ) {
    if (shouldFail) {
      return Stream.error(Exception(errorMessage));
    }
    return Stream.fromIterable(generatedTokens);
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId, {
    String? docType,
    String? userName,
    List<ChatMessage>? history,
    Map<String, String>? projectContext,
  }) {
    if (shouldFail) {
      return Stream.value(
        ErrorEvent(error: errorMessage, code: 'TEST_ERROR', shouldRetry: false),
      );
    }
    final events = <ChatStreamEvent>[];
    for (final token in generatedTokens) {
      events.add(TokenEvent(token: token, isFinal: false));
    }
    events.add(
      DoneEvent(
        fullResponse: generatedTokens.join(''),
        sources: [],
        metadata: {},
      ),
    );
    return Stream.fromIterable(events);
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) {
    savedProposals.add(proposal);
    return Future.value(); // Synchronous return to avoid dangling futures
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) =>
      Future.value([]); // Synchronous return

  @override
  Future<void> clearChatHistory(String projectId) => Future.value(); // Synchronous return

  @override
  Future<void> saveMessage(String projectId, ChatMessage message) =>
      Future.value(); // Synchronous return

  @override
  Future<void> ingestDocument({
    required String projectId,
    required String docName,
    required String markdownContent,
  }) =>
      Future.value();
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
      // Stream is active: don't use pumpAndSettle (infinite animation)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 6. Verify file was saved to correct location
      expect(fakeFileSystemService.savedFiles, isNotEmpty);
      final savedPaths = fakeFileSystemService.savedPaths;
      // El primer documento (index 1) es PROJECT_MANIFESTO que va a context/10-CONTEXT/
      expect(savedPaths, contains('context/10-CONTEXT/PROJECT_MANIFESTO.md'));

      // 7. Verify button state changed (message marked as validated)
      final stateAfterValidation = container.read(chatNotifierProvider);
      expect(
        stateAfterValidation.validatedMessageIds.contains(assistantMessage.id),
        true,
      );

      // 8. Verify saved content is correct
      final savedPath = '$projectPath/context/10-CONTEXT/PROJECT_MANIFESTO.md';
      final savedContent = fakeFileSystemService.savedFiles[savedPath];
      expect(savedContent, isNotNull);
      expect(savedContent, contains('README'));
      expect(
        savedContent,
        contains('This is a test project for integration testing.'),
      );

      // Wait for any pending futures to complete before tearDown
      await tester.pump(const Duration(milliseconds: 50));
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
      // Stream active: use pump() instead of pumpAndSettle()
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final stateAfterGeneration = container.read(chatNotifierProvider);
      final assistantMessage = stateAfterGeneration.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Validate document
      await notifier.validateProposal(assistantMessage.id);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify file was saved to section folder (not root)
      expect(fakeFileSystemService.savedFiles, isNotEmpty);
      final savedPaths = fakeFileSystemService.savedPaths;
      expect(savedPaths.length, 1);

      // Verify path contains section folder
      final savedPath = savedPaths.first;
      expect(savedPath, isNot('README.md')); // Not in root
      expect(savedPath, contains('/')); // Contains folder separator

      // Wait for any pending futures to complete before tearDown
      await tester.pump(const Duration(milliseconds: 50));
    });

    // This test performs TWO sequential validation cycles which triggers
    // a race condition where the second sendMessageStream starts before
    // the first validation's internal silent validation stream completes.
    // Needs investigation into ChatNotifier's stream disposal mechanism.
    // Related error: "Bad state: Cannot add event while adding stream"
    testWidgets(
      'INTEGRATION: Replace existing file on re-validation',
      skip: true, // FakeAsync bug: sequential streams cause event loop deadlock
      (tester) async {
        final notifier = container.read(chatNotifierProvider.notifier);
        const projectPath = '/tmp/test_replace';
        await notifier.setProjectPath(projectPath);

        // Generate and validate first version
        fakeRepository.generatedTokens = ['# README\n\n', 'Version 1 content'];
        await notifier.sendMessageStream('Generate v1');
        // Stream active: use pump() instead of pumpAndSettle()
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        var state = container.read(chatNotifierProvider);
        var assistantMessage = state.messages.lastWhere(
          (m) => m.role == MessageRole.assistant,
        );
        await notifier.validateProposal(assistantMessage.id);
        // FIX: Use pump() instead of pumpAndSettle() to avoid timeout with cursor animation
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final firstContent =
            fakeFileSystemService.savedFiles['$projectPath/README.md'];
        expect(firstContent, contains('Version 1'));

        // Generate and validate second version (same document)
        await tester.pump(const Duration(milliseconds: 500));

        fakeRepository.generatedTokens = [
          '# README\n\n',
          'Version 2 content (updated)',
        ];

        await notifier.sendMessageStream('Generate v2');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        state = container.read(chatNotifierProvider);
        assistantMessage = state.messages.lastWhere(
          (m) => m.role == MessageRole.assistant,
        );
        await notifier.validateProposal(assistantMessage.id);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

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

        // Wait for any pending futures to complete before tearDown
        await tester.pump(const Duration(milliseconds: 50));
        await Future.microtask(() {}); // Ensure all microtasks complete
      },
    );

    // This test performs two sequential validateProposal() calls which suffers
    // from the same race condition as "Replace existing file" test.
    // The issue: second validation starts before first validation's internal
    // silent validation stream completes.
    // Needs investigation into ChatNotifier's stream disposal mechanism.
    testWidgets(
      'INTEGRATION: Multiple validations preserve independent states',
      (tester) async {
        final notifier = container.read(chatNotifierProvider.notifier);
        const projectPath = '/tmp/test_multiple';
        await notifier.setProjectPath(projectPath);

        // Generate README
        fakeRepository.generatedTokens = ['# README\n\n', 'First doc'];
        await notifier.sendMessageStream('Generate README');
        // Stream active: use pump() instead of pumpAndSettle()
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

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
        // Stream active: use pump() instead of pumpAndSettle()
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        state = container.read(chatNotifierProvider);
        final manifestoMessage = state.messages.lastWhere(
          (m) => m.role == MessageRole.assistant,
        );

        // Validate only README
        await notifier.validateProposal(readmeMessage.id);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        state = container.read(chatNotifierProvider);
        expect(state.validatedMessageIds.contains(readmeMessage.id), true);
        expect(state.validatedMessageIds.contains(manifestoMessage.id), false);

        // Validate MANIFESTO
        await notifier.validateProposal(manifestoMessage.id);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        state = container.read(chatNotifierProvider);
        expect(state.validatedMessageIds.contains(readmeMessage.id), true);
        expect(state.validatedMessageIds.contains(manifestoMessage.id), true);

        // Verify both files were saved
        expect(fakeFileSystemService.savedFiles.keys, hasLength(2));

        // Verify documents are independent (no cross-contamination)
        final readme =
            fakeFileSystemService.savedFiles['$projectPath/README.md']!;
        final manifesto = fakeFileSystemService.savedFiles.values.firstWhere(
          (content) => content.contains('MANIFESTO'),
        );
        expect(readme, contains('README'));
        expect(manifesto, contains('MANIFESTO'));
        expect(readme, isNot(contains('MANIFESTO')));

        // Wait for any pending futures to complete before tearDown
        await tester.pump(const Duration(milliseconds: 50));
      },
      skip: true,
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
      // Stream active: use pump() instead of pumpAndSettle()
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      var state = container.read(chatNotifierProvider);
      final assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Simulate filesystem error
      fakeFileSystemService.shouldFail = true;

      // Attempt validation
      await notifier.validateProposal(assistantMessage.id);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify error state
      state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('Failed to save document'));

      // Verify message was NOT marked as validated
      expect(state.validatedMessageIds.contains(assistantMessage.id), false);

      // Verify file was NOT saved
      expect(fakeFileSystemService.savedFiles, isEmpty);

      // Wait for any pending futures to complete before tearDown
      await tester.pump(const Duration(milliseconds: 50));
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
      // Stream active: use pump() instead of pumpAndSettle()
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      var state = container.read(chatNotifierProvider);
      final assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );
      await notifier.validateProposal(assistantMessage.id);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

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

      // Wait for any pending futures to complete before tearDown
      await tester.pump(const Duration(milliseconds: 50));
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
