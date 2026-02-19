import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/presentation/notifiers/streaming_state.dart';

void main() {
  group('ChatState', () {
    test('should initialize with default values', () {
      // Arrange & Act
      const state = ChatState();

      // Assert
      expect(state.messages, isEmpty);
      expect(state.currentProposal, isNull);
      expect(state.currentDocIndex, 1);
      expect(state.totalDocs, 25);
      expect(state.isStreaming, false);
      expect(state.hasError, false);
      expect(state.errorMessage, isNull);
      expect(state.projectPath, isNull);
      expect(state.isLoading, false);
      expect(state.validatedMessageIds, isEmpty);
    });

    test('should create initial clean state via factory', () {
      // Arrange & Act
      final state = ChatState.initial();

      // Assert
      expect(state.messages, isEmpty);
      expect(state.validatedMessageIds, isEmpty);
      expect(state.currentDocIndex, 1);
      expect(state.hasError, false);
    });

    group('Progress Tracking', () {
      test('should return correct progress text', () {
        // Arrange
        const state = ChatState(currentDocIndex: 5, totalDocs: 25);

        // Act & Assert
        expect(state.progressText, 'Doc 5/25');
      });

      test('should indicate completion when index exceeds total', () {
        // Arrange
        const state = ChatState(currentDocIndex: 26, totalDocs: 25);

        // Act & Assert
        expect(state.isComplete, true);
      });

      test('should not be complete before reaching total docs', () {
        // Arrange
        const state = ChatState(currentDocIndex: 24, totalDocs: 25);

        // Act & Assert
        expect(state.isComplete, false);
      });

      test('should not be complete at exactly total docs', () {
        // Arrange
        const state = ChatState(currentDocIndex: 25, totalDocs: 25);

        // Act & Assert
        expect(state.isComplete, false);
      });
    });

    group('Validated Messages Tracking', () {
      test('should start with empty validated messages set', () {
        // Arrange & Act
        const state = ChatState();

        // Assert
        expect(state.validatedMessageIds, isEmpty);
        expect(state.validatedMessageIds, isA<Set<String>>());
      });

      test('should preserve validated message IDs on copyWith', () {
        // Arrange
        const state = ChatState(
          validatedMessageIds: {'msg-1', 'msg-2', 'msg-3'},
        );

        // Act
        final newState = state.copyWith(isStreaming: true);

        // Assert
        expect(
          newState.validatedMessageIds,
          containsAll(['msg-1', 'msg-2', 'msg-3']),
        );
        expect(newState.validatedMessageIds, hasLength(3));
      });

      test('should update validated message IDs via copyWith', () {
        // Arrange
        const state = ChatState(validatedMessageIds: {'msg-1'});

        // Act
        final newState = state.copyWith(
          validatedMessageIds: {'msg-1', 'msg-2'},
        );

        // Assert
        expect(newState.validatedMessageIds, containsAll(['msg-1', 'msg-2']));
        expect(newState.validatedMessageIds, hasLength(2));
      });

      test('should allow adding validated message IDs incrementally', () {
        // Arrange
        const state = ChatState(validatedMessageIds: {'msg-1', 'msg-2'});

        // Act
        final newIds = {...state.validatedMessageIds, 'msg-3'};
        final newState = state.copyWith(validatedMessageIds: newIds);

        // Assert
        expect(
          newState.validatedMessageIds,
          containsAll(['msg-1', 'msg-2', 'msg-3']),
        );
      });

      test('should be immutable - original set unchanged', () {
        // Arrange
        const originalIds = {'msg-1', 'msg-2'};
        const state = ChatState(validatedMessageIds: originalIds);

        // Act
        final newState = state.copyWith(
          validatedMessageIds: {'msg-1', 'msg-2', 'msg-3'},
        );

        // Assert
        expect(state.validatedMessageIds, hasLength(2));
        expect(newState.validatedMessageIds, hasLength(3));
      });
    });

    group('copyWith', () {
      test('should copy with new messages', () {
        // Arrange
        const state = ChatState();
        final newMessages = [
          ChatMessage(
            id: '1',
            role: MessageRole.user,
            content: 'Test',
            timestamp: '2026-02-13T10:00:00.000',
          ),
        ];

        // Act
        final newState = state.copyWith(messages: newMessages);

        // Assert
        expect(newState.messages, hasLength(1));
        expect(newState.messages.first.content, 'Test');
      });

      test('should copy with new proposal', () {
        // Arrange
        const state = ChatState();
        final proposal = DocumentProposal(
          id: '1',
          docType: 'TEST',
          content: 'Content',
          metadata: {},
          validationState: ValidationState.pending,
        );

        // Act
        final newState = state.copyWith(currentProposal: proposal);

        // Assert
        expect(newState.currentProposal, isNotNull);
        expect(newState.currentProposal!.docType, 'TEST');
      });

      test('should clear proposal when clearProposal is true', () {
        // Arrange
        final state = ChatState(
          currentProposal: DocumentProposal(
            id: '1',
            docType: 'TEST',
            content: 'Content',
            metadata: {},
            validationState: ValidationState.pending,
          ),
        );

        // Act
        final newState = state.copyWith(clearProposal: true);

        // Assert
        expect(newState.currentProposal, isNull);
      });

      test('should preserve proposal when clearProposal is false', () {
        // Arrange
        final proposal = DocumentProposal(
          id: '1',
          docType: 'TEST',
          content: 'Content',
          metadata: {},
          validationState: ValidationState.pending,
        );
        final state = ChatState(currentProposal: proposal);

        // Act
        final newState = state.copyWith(isStreaming: true);

        // Assert
        expect(newState.currentProposal, isNotNull);
        expect(newState.currentProposal!.id, '1');
      });

      test('should copy with streaming state', () {
        // Arrange
        const state = ChatState();

        // Act
        final newState = state.copyWith(isStreaming: true);

        // Assert
        expect(newState.isStreaming, true);
      });

      test('should copy with error state', () {
        // Arrange
        const state = ChatState();

        // Act
        final newState = state.copyWith(
          hasError: true,
          errorMessage: 'Test error',
        );

        // Assert
        expect(newState.hasError, true);
        expect(newState.errorMessage, 'Test error');
      });

      test('should copy with project path', () {
        // Arrange
        const state = ChatState();

        // Act
        final newState = state.copyWith(projectPath: '/test/path');

        // Assert
        expect(newState.projectPath, '/test/path');
      });

      test('should copy with loading state', () {
        // Arrange
        const state = ChatState();

        // Act
        final newState = state.copyWith(isLoading: true);

        // Assert
        expect(newState.isLoading, true);
      });

      test('should copy with doc index', () {
        // Arrange
        const state = ChatState(currentDocIndex: 1);

        // Act
        final newState = state.copyWith(currentDocIndex: 5);

        // Assert
        expect(newState.currentDocIndex, 5);
      });
    });

    group('clearError', () {
      test('should clear error state', () {
        // Arrange
        const state = ChatState(hasError: true, errorMessage: 'Test error');

        // Act
        final newState = state.clearError();

        // Assert
        expect(newState.hasError, false);
        expect(newState.errorMessage, isNull);
      });

      test('should preserve other state when clearing error', () {
        // Arrange
        final messages = [
          ChatMessage(
            id: '1',
            role: MessageRole.user,
            content: 'Test',
            timestamp: '2026-02-13T10:00:00.000',
          ),
        ];
        final state = ChatState(
          messages: messages,
          hasError: true,
          errorMessage: 'Error',
          currentDocIndex: 5,
          validatedMessageIds: const {'msg-1'},
        );

        // Act
        final newState = state.clearError();

        // Assert
        expect(newState.messages, hasLength(1));
        expect(newState.currentDocIndex, 5);
        expect(newState.validatedMessageIds, contains('msg-1'));
        expect(newState.hasError, false);
      });
    });

    group('reset', () {
      test('should reset state to initial values', () {
        // Arrange
        final messages = [
          ChatMessage(
            id: '1',
            role: MessageRole.user,
            content: 'Test',
            timestamp: '2026-02-13T10:00:00.000',
          ),
        ];
        final state = ChatState(
          messages: messages,
          currentDocIndex: 10,
          isStreaming: true,
          hasError: true,
          validatedMessageIds: const {'msg-1', 'msg-2'},
        );

        // Act
        final newState = state.reset();

        // Assert
        expect(newState.messages, isEmpty);
        expect(newState.currentDocIndex, 1);
        expect(newState.isStreaming, false);
        expect(newState.hasError, false);
        expect(newState.validatedMessageIds, isEmpty);
      });

      test('should preserve totalDocs on reset', () {
        // Arrange
        const state = ChatState(totalDocs: 30, currentDocIndex: 15);

        // Act
        final newState = state.reset();

        // Assert
        expect(newState.totalDocs, 30);
      });
    });

    group('Immutability', () {
      test('should not mutate original state on copyWith', () {
        // Arrange
        const originalState = ChatState(
          currentDocIndex: 1,
          isStreaming: false,
          validatedMessageIds: {'msg-1'},
        );

        // Act
        originalState.copyWith(
          currentDocIndex: 2,
          isStreaming: true,
          validatedMessageIds: {'msg-1', 'msg-2'},
        );

        // Assert - Original unchanged
        expect(originalState.currentDocIndex, 1);
        expect(originalState.isStreaming, false);
        expect(originalState.validatedMessageIds, hasLength(1));
      });

      test('should create independent state copies', () {
        // Arrange
        const state1 = ChatState(validatedMessageIds: {'msg-1'});

        // Act
        final state2 = state1.copyWith(validatedMessageIds: {'msg-1', 'msg-2'});

        // Assert
        expect(state1.validatedMessageIds, hasLength(1));
        expect(state2.validatedMessageIds, hasLength(2));
      });
    });
  });
}
