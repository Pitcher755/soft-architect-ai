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
      yield ErrorEvent(
        error: errorMessage,
        code: 'TEST_ERROR',
        shouldRetry: false,
      );
      return;
    }
    for (final token in generatedTokens) {
      yield TokenEvent(token: token, isFinal: false);
    }
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
}
