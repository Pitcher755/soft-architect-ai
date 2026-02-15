import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:softarchitect_ai/features/chat/presentation/notifiers/chat_notifier.dart';

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
    // Add realistic streaming delays (50ms between tokens)
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

      notifier.sendMessage('Test message');

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

      notifier.sendMessage('Generate document');

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

        notifier.sendMessage('Create document');

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

      notifier.sendMessage('This will fail');

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
      notifier.sendMessage('First document');
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

      // Generate document and wait for proposal
      notifier.sendMessage('Generate document');
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

      // Trigger error
      notifier.sendMessage('Fail');
      await Future<void>.delayed(const Duration(milliseconds: 180));

      final stateWithError = container.read(chatNotifierProvider);
      expect(stateWithError.hasError, true);

      // Clear error
      notifier.clearError();

      final stateCleaned = container.read(chatNotifierProvider);
      expect(stateCleaned.hasError, false);
      // errorMessage persists but hasError is false (expected behavior)
    });

    test('resetForNewProject resets state with custom totalDocs', () {
      final notifier = container.read(chatNotifierProvider.notifier);

      // Send some messages first
      notifier.sendMessage('Test message');

      // Reset for new project
      notifier.resetForNewProject(totalDocs: 30);

      final state = container.read(chatNotifierProvider);
      expect(state.messages, isEmpty);
      expect(state.currentDocIndex, 1);
      expect(state.totalDocs, 30);
      expect(state.currentProposal, isNull);
      expect(state.hasError, false);
    });

    test('setProjectPath updates project path in state', () {
      final notifier = container.read(chatNotifierProvider.notifier);
      const testPath = '/tmp/test_project';

      notifier.setProjectPath(testPath);

      final state = container.read(chatNotifierProvider);
      expect(state.projectPath, testPath);
    });

    test('retryLastMessage re-sends last user message', () async {
      final notifier = container.read(chatNotifierProvider.notifier);

      // Send successful message first
      fakeRepository.generatedTokens = ['First', ' ', 'message'];
      notifier.sendMessage('First message');
      await Future<void>.delayed(const Duration(milliseconds: 220));

      final initialState = container.read(chatNotifierProvider);
      expect(initialState.hasError, false);
      final messageCountBefore = initialState.messages.length;

      // Simulate error scenario by failing next message
      fakeRepository.shouldFail = true;
      fakeRepository.errorMessage = 'Connection error';
      notifier.sendMessage('Second message');
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

      // Generate initial document
      notifier.sendMessage('Generate document');
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
}
