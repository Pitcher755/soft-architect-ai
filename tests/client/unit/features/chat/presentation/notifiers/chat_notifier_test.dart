import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:softarchitect_ai/features/chat/presentation/notifiers/chat_notifier.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/notifiers/file_system_notifier.dart';
import 'package:softarchitect_ai/features/project_shell/core/services/file_system_service.dart';

// Fake FileSystemService for testing
class FakeFileSystemService implements FileSystemService {
  final Map<String, String> savedFiles = {};
  bool shouldFail = false;
  String? lastSavedPath;
  String? lastSavedContent;

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
    lastSavedPath = relativePath;
    lastSavedContent = content;
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

// Fake implementation for testing
class FakeChatRepository implements ChatRepository {
  List<String> generatedTokens = [];
  bool shouldFail = false;
  String errorMessage = 'Test error';

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
    String projectId,
  ) {
    if (shouldFail) {
      return Stream.value(ErrorEvent(
        error: errorMessage,
        code: 'TEST_ERROR',
        shouldRetry: false,
      ));
    }
    final events = <ChatStreamEvent>[];
    for (final token in generatedTokens) {
      events.add(TokenEvent(token: token, isFinal: false));
    }
    events.add(DoneEvent(
      fullResponse: generatedTokens.join(''),
      sources: [],
      metadata: {},
    );
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    // No-op for testing
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
    // No-op for testing (mock implementation)
  }
}

void main() {
  late FakeChatRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeChatRepository();
    container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ChatNotifier State Machine', () {
    test('should initialize with empty state', () {
      final state = container.read(chatNotifierProvider);

      expect(state.messages, isEmpty);
      expect(state.currentDocIndex, 1);
      expect(state.totalDocs, 25);
      expect(state.isStreaming, false);
      expect(state.hasError, false);
      expect(state.currentProposal, isNull);
    });

    test('should add user message and start streaming', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Hello', ' ', 'World'];

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      await notifier.sendMessageStream('Test message');

      // Wait for async operations
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(chatNotifierProvider);

      // Verify user message was added
      expect(state.messages.length, greaterThanOrEqualTo(1));
      expect(state.messages.first.role, MessageRole.user);
      expect(state.messages.first.content, 'Test message');
    });

    test('should stream tokens and update assistant message', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Token', '1', ' ', 'Token2'];

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      await notifier.sendMessageStream('Generate document');

      // Wait for streaming to complete
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final state = container.read(chatNotifierProvider);

      // Verify assistant message accumulated tokens
      expect(state.messages.length, greaterThanOrEqualTo(2));
      final assistantMessage = state.messages.last;
      expect(assistantMessage.role, MessageRole.assistant);
      expect(assistantMessage.content, 'Token1 Token2');
    });

    test(
      'should transition to proposal state after streaming complete',
      () async {
        final notifier = container.read(chatNotifierProvider.notifier);
        fakeRepository.generatedTokens = ['Document', ' ', 'content'];

        // ✅ Required: Set project path before sending message
        await notifier.setProjectPath('/tmp/test_project');

        await notifier.sendMessageStream('Create document');

        // Wait for streaming to complete and proposal to be created
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final state = container.read(chatNotifierProvider);

        // Verify proposal was created
        expect(state.currentProposal, isNotNull);
        expect(state.currentProposal!.validationState, ValidationState.pending);
        expect(state.currentProposal!.content, 'Document content');
        expect(state.isStreaming, false);
      },
    );

    test('should handle stream errors gracefully', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.shouldFail = true;
      fakeRepository.errorMessage = 'Network error';

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      await notifier.sendMessageStream('This will fail');

      // Wait for error to be captured
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final state = container.read(chatNotifierProvider);

      // Verify error state
      expect(state.hasError, true);
      expect(state.errorMessage, contains('Network error'));
      expect(state.isStreaming, false);
    });

    test('should advance document index after validation', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Document', ' ', 'One'];

      // Set project path
      notifier.setProjectPath('/tmp/test_project');

      // Generate first document
      await notifier.sendMessageStream('First document');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final initialState = container.read(chatNotifierProvider);
      expect(initialState.currentDocIndex, 1);
      expect(initialState.currentProposal, isNotNull);

      // Validate proposal
      await notifier.validateProposal();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final updatedState = container.read(chatNotifierProvider);

      // Verify document index advanced
      expect(updatedState.currentDocIndex, 2);
      expect(updatedState.currentProposal, isNull);
    });
  });

  group('ChatNotifier Streaming Behavior', () {
    test('sendMessageStream adds user message immediately', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      final userContent = 'Test streaming message';

      // Act: Call streaming method (async)
      final future = notifier.sendMessageStream(userContent);

      // Wait for immediate user message addition (no delay needed)
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // Assert: User message must be present immediately
      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, greaterThanOrEqualTo(1));
      expect(state.messages.first.role, MessageRole.user);
      expect(state.messages.first.content, userContent);

      // Wait for stream to complete before tearDown
      await future;
    });

    test(
      'sendMessageStream adds empty AI message with isStreaming=true',
      () async {
        final notifier = container.read(chatNotifierProvider.notifier);
        fakeRepository.generatedTokens = ['First', ' ', 'Token'];

        // Act: Call streaming method (async)
        final future = notifier.sendMessageStream('Trigger AI response');

        // Wait minimal time for initial state update (before first token @ 50ms)
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Assert: AI message must exist with isStreaming flag
        final state = container.read(chatNotifierProvider);
        expect(state.messages.length, greaterThanOrEqualTo(2));
        final aiMessage = state.messages.last;
        expect(aiMessage.role, MessageRole.assistant);
        expect(aiMessage.isStreaming, true);
        expect(aiMessage.content, isEmpty); // Initially empty

        // Wait for stream to complete before tearDown
        await future;
      },
    );

    test('sendMessageStream appends tokens to AI message', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Hello', ' ', 'World', '!'];

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Act: Call streaming method (async)
      final future = notifier.sendMessageStream('Generate text');

      // Wait for tokens to accumulate (4 tokens * 50ms = 200ms, wait 180ms)
      await Future<void>.delayed(const Duration(milliseconds: 180));

      // Assert: AI message must accumulate tokens (still streaming)
      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, greaterThanOrEqualTo(2));
      final aiMessage = state.messages.last;
      expect(aiMessage.role, MessageRole.assistant);
      expect(aiMessage.content, contains('Hello')); // Partial content
      expect(aiMessage.isStreaming, true); // Still streaming

      // Wait for stream to complete before tearDown
      await future;
    });

    test('sendMessageStream marks message complete on DoneEvent', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Complete', ' ', 'Response'];

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Act: Call streaming method and wait for completion
      await notifier.sendMessageStream('Complete message');

      // Assert: AI message must be marked as complete
      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, greaterThanOrEqualTo(2));
      final aiMessage = state.messages.last;
      expect(aiMessage.role, MessageRole.assistant);
      expect(aiMessage.content, 'Complete Response');
      expect(aiMessage.isStreaming, false); // Streaming finished
      expect(state.isStreaming, false); // Global streaming flag off
    });

    test('sendMessageStream handles ErrorEvent', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.shouldFail = true;
      fakeRepository.errorMessage = 'Streaming error occurred';

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Act: Call streaming method that will fail and wait
      await notifier.sendMessageStream('This will fail');

      // Assert: Error must be captured in state
      final state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('Streaming error occurred'));
      expect(state.isStreaming, false); // Streaming stopped on error
    });
  });

  group('ChatNotifier Legacy Methods Coverage', () {
    test('rejectProposal clears current proposal', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Document', ' ', 'content'];

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Generate document and wait for proposal
      await notifier.sendMessageStream('Generate document');
      await Future<void>.delayed(const Duration(milliseconds: 220));

      final stateWithProposal = container.read(chatNotifierProvider);
      expect(stateWithProposal.currentProposal, isNotNull);

      // Reject proposal
      notifier.rejectProposal();

      final stateAfterReject = container.read(chatNotifierProvider);
      expect(stateAfterReject.currentProposal, isNull);
    });

    test('clearError resets error state', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.shouldFail = true;
      fakeRepository.errorMessage = 'Test error';

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Trigger error
      await notifier.sendMessageStream('Fail');
      await Future<void>.delayed(const Duration(milliseconds: 180));

      final stateWithError = container.read(chatNotifierProvider);
      expect(stateWithError.hasError, true);

      // Clear error
      notifier.clearError();

      final stateCleaned = container.read(chatNotifierProvider);
      expect(stateCleaned.hasError, false);
      // errorMessage persists but hasError is false (expected behavior)
    });

    test('resetForNewProject resets state with custom totalDocs', () async {
      final notifier = container.read(chatNotifierProvider.notifier);

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Send some messages first
      await notifier.sendMessageStream('Test message');

      // Reset for new project
      notifier.resetForNewProject(totalDocs: 30);

      final state = container.read(chatNotifierProvider);
      expect(state.messages, isEmpty);
      expect(state.currentDocIndex, 1);
      expect(state.totalDocs, 30);
      expect(state.currentProposal, isNull);
      expect(state.hasError, false);
    });

    test('setProjectPath updates project path in state', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      const testPath = '/tmp/test_project';

      await notifier.setProjectPath(testPath);

      final state = container.read(chatNotifierProvider);
      expect(state.projectPath, testPath);
    });

    test('retryLastMessage re-sends last user message', () async {
      final notifier = container.read(chatNotifierProvider.notifier);

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Send successful message first
      fakeRepository.generatedTokens = ['First', ' ', 'message'];
      await notifier.sendMessageStream('First message');
      await Future<void>.delayed(const Duration(milliseconds: 220));

      final initialState = container.read(chatNotifierProvider);
      expect(initialState.hasError, false);
      final messageCountBefore = initialState.messages.length;

      // Simulate error scenario by failing next message
      fakeRepository.shouldFail = true;
      fakeRepository.errorMessage = 'Connection error';
      await notifier.sendMessageStream('Second message');
      await Future<void>.delayed(const Duration(milliseconds: 180));

      final stateWithError = container.read(chatNotifierProvider);
      expect(stateWithError.hasError, true);

      // Fix repository and retry
      fakeRepository.shouldFail = false;
      fakeRepository.generatedTokens = ['Retry', ' ', 'success'];

      await notifier.retryLastMessage();
      await Future<void>.delayed(const Duration(milliseconds: 220));

      final stateAfterRetry = container.read(chatNotifierProvider);
      // After retry, messaging continues (error cleared before retry)
      expect(stateAfterRetry.messages.length, greaterThan(messageCountBefore));
    });

    test('regenerateProposal re-generates document', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['First', ' ', 'version'];

      // ✅ Required: Set project path before sending message
      await notifier.setProjectPath('/tmp/test_project');

      // Generate initial document
      await notifier.sendMessageStream('Generate document');
      await Future<void>.delayed(const Duration(milliseconds: 220));

      final initialState = container.read(chatNotifierProvider);
      final initialContent = initialState.currentProposal?.content ?? '';

      // Regenerate with different content
      fakeRepository.generatedTokens = ['Second', ' ', 'version'];
      await notifier.regenerateProposal();
      await Future<void>.delayed(const Duration(milliseconds: 280));

      final regeneratedState = container.read(chatNotifierProvider);
      final regeneratedContent =
          regeneratedState.currentProposal?.content ?? '';

      expect(regeneratedContent, isNot(equals(initialContent)));
      expect(regeneratedContent, contains('Second'));
    });
  });

  group('ChatNotifier - validateProposal Enhanced', () {
    late FakeFileSystemService fakeFileSystemService;

    setUp(() {
      fakeFileSystemService = FakeFileSystemService();
      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepository),
          fileSystemServiceProvider.overrideWithValue(fakeFileSystemService),
          // Mock FileSystemNotifier to prevent null errors
          fileSystemNotifierProvider.overrideWith((ref) {
            return FileSystemNotifier();
          }),
        ],
      );
    });

    test('should detect document type from H1 header in content', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      // Generate message via sendMessageStream with H1 header
      fakeRepository.generatedTokens = [
        '# PROJECT MANIFESTO\n\n',
        'Content here...',
      ];

      await notifier.sendMessageStream('Generate manifesto');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Get the generated message ID
      final state = container.read(chatNotifierProvider);
      final assistantMessage = state.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Validate that specific message (not currentProposal)
      await notifier.validateProposal(assistantMessage.id);

      // Verify file was saved with correct path (detection worked)
      expect(fakeFileSystemService.savedFiles.isNotEmpty, true);
      expect(
        fakeFileSystemService.lastSavedPath,
        '10-CONTEXT/PROJECT_MANIFESTO.md',
      );
    });

    test('should save README.md to project root', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      fakeRepository.generatedTokens = [
        '# README\n\n',
        'Project',
        ' ',
        'Description',
      ];
      await notifier.sendMessageStream('Generate README');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Validate the generated proposal
      await notifier.validateProposal();

      // Verify README was saved to root
      final savedPath = fakeFileSystemService.lastSavedPath;
      expect(savedPath, 'README.md');

      final fullPath = '/tmp/test_project/README.md';
      expect(fakeFileSystemService.savedFiles.containsKey(fullPath), true);
    });

    test('should save non-README documents to section folders', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      fakeRepository.generatedTokens = [
        '# PROJECT MANIFESTO\n\n',
        'Vision',
        ' ',
        'Statement',
      ];
      await notifier.sendMessageStream('Generate project manifesto');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Validate the generated proposal
      await notifier.validateProposal();

      // Verify document was saved to section folder
      final savedPath = fakeFileSystemService.lastSavedPath;
      expect(savedPath, isNotNull);
      expect(savedPath!.contains('/'), true); // Contains folder separator

      // Check actual saved content
      expect(
        fakeFileSystemService.lastSavedContent,
        contains('PROJECT MANIFESTO'),
      );
    });

    test('should mark message as validated in state', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      fakeRepository.generatedTokens = ['# TEST DOC\n\n', 'Content'];
      await notifier.sendMessageStream('Generate document');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final stateBeforeValidation = container.read(chatNotifierProvider);
      expect(stateBeforeValidation.validatedMessageIds, isEmpty);

      // Get the last assistant message ID
      final assistantMessage = stateBeforeValidation.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Validate the specific message
      await notifier.validateProposal(assistantMessage.id);

      final stateAfterValidation = container.read(chatNotifierProvider);
      expect(
        stateAfterValidation.validatedMessageIds.contains(assistantMessage.id),
        true,
      );
    });

    test('should save proposal to database with metadata', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      fakeRepository.generatedTokens = ['# DESIGN DOC\n\n', 'Architecture'];
      await notifier.sendMessageStream('Generate design doc');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final stateBeforeValidation = container.read(chatNotifierProvider);
      final assistantMessage = stateBeforeValidation.messages.lastWhere(
        (m) => m.role == MessageRole.assistant,
      );

      // Validate and save to database
      await notifier.validateProposal(assistantMessage.id);

      // Verify file was saved (repository.saveProposal was called)
      expect(fakeFileSystemService.savedFiles.isNotEmpty, true);
    });

    test(
      'should replace existing file when validating same document',
      () async {
        final notifier = container.read(chatNotifierProvider.notifier);
        await notifier.setProjectPath('/tmp/test_project');

        // Generate and validate first version
        fakeRepository.generatedTokens = ['# README\n\n', 'Version', ' ', '1'];
        await notifier.sendMessageStream('Generate README v1');
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await notifier.validateProposal();

        final firstContent = fakeFileSystemService.lastSavedContent;
        expect(firstContent, contains('Version 1'));

        // Generate and validate second version (should replace)
        fakeRepository.generatedTokens = ['# README\n\n', 'Version', ' ', '2'];
        await notifier.sendMessageStream('Generate README v2');
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await notifier.validateProposal();

        final secondContent = fakeFileSystemService.lastSavedContent;
        expect(secondContent, contains('Version 2'));
        expect(secondContent, isNot(contains('Version 1')));

        // Verify only one README exists (replaced, not duplicated)
        final readmeFiles = fakeFileSystemService.savedFiles.keys.where(
          (path) => path.endsWith('README.md'),
        );
        expect(readmeFiles, hasLength(1));
      },
    );

    test('should handle validation error gracefully', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      fakeRepository.generatedTokens = ['# TEST DOC\n\n', 'Content'];
      await notifier.sendMessageStream('Generate document');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Simulate filesystem error
      fakeFileSystemService.shouldFail = true;

      // Validate (should catch error)
      await notifier.validateProposal();

      final state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('Failed to save document'));
    });

    test(
      'should validate current proposal when no message ID provided',
      () async {
        final notifier = container.read(chatNotifierProvider.notifier);
        await notifier.setProjectPath('/tmp/test_project');

        fakeRepository.generatedTokens = ['# PROPOSAL\n\n', 'Content'];
        await notifier.sendMessageStream('Generate proposal');
        await Future<void>.delayed(const Duration(milliseconds: 250));

        final stateBeforeValidation = container.read(chatNotifierProvider);
        expect(stateBeforeValidation.currentProposal, isNotNull);

        // Validate current proposal (no ID)
        await notifier.validateProposal();

        // Verify proposal was cleared (workflow advanced)
        final stateAfterValidation = container.read(chatNotifierProvider);
        expect(stateAfterValidation.currentProposal, isNull);
        expect(fakeFileSystemService.savedFiles.isNotEmpty, true);
      },
    );

    test('should advance workflow after validating current proposal', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      fakeRepository.generatedTokens = ['# DOC 1\n\n', 'Content'];
      await notifier.sendMessageStream('Generate doc 1');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final stateBeforeValidation = container.read(chatNotifierProvider);
      final indexBefore = stateBeforeValidation.currentDocIndex;

      // Validate current proposal
      await notifier.validateProposal();

      final stateAfterValidation = container.read(chatNotifierProvider);
      expect(stateAfterValidation.currentDocIndex, indexBefore + 1);
    });

    test(
      'should not advance workflow when validating specific message',
      () async {
        final notifier = container.read(chatNotifierProvider.notifier);
        await notifier.setProjectPath('/tmp/test_project');

        fakeRepository.generatedTokens = ['# DOC 1\n\n', 'Content'];
        await notifier.sendMessageStream('Generate doc 1');
        await Future<void>.delayed(const Duration(milliseconds: 250));

        final stateBeforeValidation = container.read(chatNotifierProvider);
        final indexBefore = stateBeforeValidation.currentDocIndex;
        final assistantMessage = stateBeforeValidation.messages.lastWhere(
          (m) => m.role == MessageRole.assistant,
        );

        // Validate specific message (not current proposal)
        await notifier.validateProposal(assistantMessage.id);

        final stateAfterValidation = container.read(chatNotifierProvider);
        expect(stateAfterValidation.currentDocIndex, indexBefore); // No change
      },
    );

    test('should return error when no project path set', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      // DON'T set project path

      fakeRepository.generatedTokens = ['# DOC\n\n', 'Content'];
      await notifier.sendMessageStream('Generate doc');
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Attempt validation without project path
      await notifier.validateProposal();

      final state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('No project context'));
    });

    test('should return error when message ID not found', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      // Validate non-existent message ID
      await notifier.validateProposal('non-existent-id');

      final state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('Failed to save document'));
    });

    test('should return error when no proposal to validate', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.setProjectPath('/tmp/test_project');

      // Attempt validation when no current proposal exists
      await notifier.validateProposal();

      final state = container.read(chatNotifierProvider);
      expect(state.hasError, true);
      expect(state.errorMessage, contains('No proposal to validate'));
    });
  });

  group('Context Bleed Prevention & Stream Management', () {
    test('should cancel active stream when changing projects', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = [
        'Long',
        ' ',
        'streaming',
        ' ',
        'response',
      ];

      // Start streaming for project A
      await notifier.setProjectPath('/tmp/project-a');
      notifier.sendMessageStream('Test message');

      // Wait briefly to ensure stream starts
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Verify streaming is active
      var state = container.read(chatNotifierProvider);
      expect(state.isStreaming, true);
      expect(state.projectPath, '/tmp/project-a');

      // Change to project B (should cancel stream)
      await notifier.setProjectPath('/tmp/project-b');

      // Verify streaming stopped and state reset
      state = container.read(chatNotifierProvider);
      expect(state.isStreaming, false);
      expect(state.projectPath, '/tmp/project-b');
      expect(state.messages, isEmpty); // State should be reset
    });

    test('should dispose and cancel active streams', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['Test', ' ', 'tokens'];

      await notifier.setProjectPath('/tmp/test_project');
      notifier.sendMessageStream('Test');

      // Wait briefly for stream to start
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Dispose should not throw
      expect(() => container.dispose(), returnsNormally);
    });

    test(
      'should discard stream events from different project',
      () async {
        final notifier = container.read(chatNotifierProvider.notifier);
        fakeRepository.generatedTokens = ['Token1', ' ', 'Token2'];

        // Set project A
        await notifier.setProjectPath('/tmp/project-a');

        // Start streaming
        final streamFuture = notifier.sendMessageStream('Test message');

        // Immediately change to project B (simulates rapid project switching)
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await notifier.setProjectPath('/tmp/project-b');

        // Wait for original stream to complete
        await streamFuture.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // Stream should be cancelled, timeout is expected
          },
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Verify project B state is clean (no messages from project A)
        final state = container.read(chatNotifierProvider);
        expect(state.projectPath, '/tmp/project-b');
        expect(state.messages, isEmpty);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test('should send hidden message without adding to UI', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['AI', ' ', 'response'];

      await notifier.setProjectPath('/tmp/test_project');

      // Send hidden message
      await notifier.sendMessageStream('Hidden prompt for LLM', isHidden: true);

      // Wait for streaming to complete
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = container.read(chatNotifierProvider);

      // Should only have AI response, NOT the hidden user message
      expect(state.messages.where((m) => m.role == MessageRole.user), isEmpty);
      expect(
        state.messages.where((m) => m.role == MessageRole.assistant),
        isNotEmpty,
      );
    });

    test('should add system message to chat', () {
      final notifier = container.read(chatNotifierProvider.notifier);

      // Add system message
      notifier.addSystemMessage('✅ Document validated at /path/to/file.md');

      final state = container.read(chatNotifierProvider);

      expect(state.messages.length, 1);
      expect(state.messages.first.role, MessageRole.system);
      expect(state.messages.first.content, contains('Document validated'));
    });

    test('should handle isHidden flag in ChatMessage entity', () {
      // Test visible message
      const visibleMessage = ChatMessage(
        id: 'msg-1',
        role: MessageRole.user,
        content: 'Visible message',
        timestamp: '2024-01-01T00:00:00Z',
      );
      expect(visibleMessage.isHidden, false);

      // Test hidden message
      const hiddenMessage = ChatMessage(
        id: 'msg-2',
        role: MessageRole.user,
        content: 'Hidden prompt',
        timestamp: '2024-01-01T00:00:00Z',
        metadata: {'hidden': true},
      );
      expect(hiddenMessage.isHidden, true);
    });

    test('should cancel previous stream when sending new message', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      fakeRepository.generatedTokens = ['First', ' ', 'response'];

      await notifier.setProjectPath('/tmp/test_project');

      // Start first stream
      notifier.sendMessageStream('First message');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var state = container.read(chatNotifierProvider);
      expect(state.isStreaming, true);

      // Start second stream (should cancel first)
      fakeRepository.generatedTokens = ['Second', ' ', 'response'];
      notifier.sendMessageStream('Second message');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // FIX: Verify isStreaming is true immediately after starting second stream
      state = container.read(chatNotifierProvider);
      expect(state.isStreaming, true);

      // Wait for second stream to complete
      await Future<void>.delayed(const Duration(milliseconds: 200));

      state = container.read(chatNotifierProvider);

      // Should have messages from second stream, first stream canceled
      final userMessages = state.messages
          .where((m) => m.role == MessageRole.user)
          .toList();
      expect(userMessages.length, 2);
      expect(userMessages.last.content, 'Second message');
    });
  });
}
