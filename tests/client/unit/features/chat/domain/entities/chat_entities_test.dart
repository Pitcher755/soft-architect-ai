import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';

void main() {
  group('ChatMessage Entity', () {
    test('should create instance with all fields', () {
      final message = ChatMessage(
        id: 'msg-1',
        role: MessageRole.user,
        content: 'Test message content',
        timestamp: '2026-02-13T12:00:00Z',
        isStreaming: false,
      );

      expect(message.id, 'msg-1');
      expect(message.role, MessageRole.user);
      expect(message.content, 'Test message content');
      expect(message.timestamp, '2026-02-13T12:00:00Z');
      expect(message.isStreaming, false);
    });

    test('should create instance with default isStreaming=false', () {
      final message = ChatMessage(
        id: 'msg-2',
        role: MessageRole.assistant,
        content: 'Assistant response',
        timestamp: '2026-02-13T12:01:00Z',
      );

      expect(message.isStreaming, false);
    });

    test('copyWith should update only specified fields', () {
      final original = ChatMessage(
        id: 'msg-3',
        role: MessageRole.user,
        content: 'Original content',
        timestamp: '2026-02-13T12:00:00Z',
        isStreaming: true,
      );

      final updated = original.copyWith(
        content: 'Updated content',
        isStreaming: false,
      );

      expect(updated.id, 'msg-3'); // Unchanged
      expect(updated.role, MessageRole.user); // Unchanged
      expect(updated.content, 'Updated content'); // Changed
      expect(updated.timestamp, '2026-02-13T12:00:00Z'); // Unchanged
      expect(updated.isStreaming, false); // Changed
    });

    test('copyWith should keep all fields unchanged if none specified', () {
      final original = ChatMessage(
        id: 'msg-4',
        role: MessageRole.assistant,
        content: 'Test',
        timestamp: '2026-02-13T12:00:00Z',
        isStreaming: true,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.role, original.role);
      expect(copy.content, original.content);
      expect(copy.timestamp, original.timestamp);
      expect(copy.isStreaming, original.isStreaming);
    });
  });

  group('DocumentProposal Entity', () {
    test('should create instance with all fields', () {
      final proposal = DocumentProposal(
        id: 'prop-1',
        docType: 'Feature Document',
        content: '# Feature\nContent here',
        metadata: {'author': 'architect', 'version': '1.0'},
        validationState: ValidationState.pending,
      );

      expect(proposal.id, 'prop-1');
      expect(proposal.docType, 'Feature Document');
      expect(proposal.content, '# Feature\nContent here');
      expect(proposal.metadata, {'author': 'architect', 'version': '1.0'});
      expect(proposal.validationState, ValidationState.pending);
    });

    test('should create with empty metadata by default', () {
      final proposal = DocumentProposal(
        id: 'prop-2',
        docType: 'Test Doc',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      expect(proposal.metadata, isEmpty);
    });

    test('copyWith should update only specified fields', () {
      final original = DocumentProposal(
        id: 'prop-3',
        docType: 'Original Type',
        content: 'Original content',
        metadata: {'key': 'value'},
        validationState: ValidationState.pending,
      );

      final updated = original.copyWith(
        content: 'Updated content',
        validationState: ValidationState.validated,
      );

      expect(updated.id, 'prop-3'); // Unchanged
      expect(updated.docType, 'Original Type'); // Unchanged
      expect(updated.content, 'Updated content'); // Changed
      expect(updated.metadata, {'key': 'value'}); // Unchanged
      expect(updated.validationState, ValidationState.validated); // Changed
    });

    test('should support ValidationState transitions', () {
      final proposal = DocumentProposal(
        id: 'prop-4',
        docType: 'Test',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      final validatedProposal = proposal.copyWith(
        validationState: ValidationState.validated,
      );

      final rejectedProposal = proposal.copyWith(
        validationState: ValidationState.rejected,
      );

      expect(validatedProposal.validationState, ValidationState.validated);
      expect(rejectedProposal.validationState, ValidationState.rejected);
    });
  });

  group('MessageRole Enum', () {
    test('should have user and assistant roles', () {
      expect(MessageRole.values, contains(MessageRole.user));
      expect(MessageRole.values, contains(MessageRole.assistant));
    });

    test('should distinguish between user and assistant', () {
      expect(MessageRole.user, isNot(equals(MessageRole.assistant)));
    });
  });

  group('ValidationState Enum', () {
    test('should have all three states', () {
      expect(ValidationState.values, contains(ValidationState.pending));
      expect(ValidationState.values, contains(ValidationState.validated));
      expect(ValidationState.values, contains(ValidationState.rejected));
    });

    test('should distinguish between all states', () {
      expect(ValidationState.pending, isNot(equals(ValidationState.validated)));
      expect(ValidationState.pending, isNot(equals(ValidationState.rejected)));
      expect(ValidationState.validated, isNot(equals(ValidationState.rejected)));
    });
  });
}
