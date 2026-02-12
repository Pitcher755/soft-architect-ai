import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage Entity', () {
    test('should create user message with correct properties', () {
      // Arrange
      const message = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hello AI',
        timestamp: '2026-02-05T10:00:00Z',
      );

      // Assert
      expect(message.id, '1');
      expect(message.role, MessageRole.user);
      expect(message.content, 'Hello AI');
      expect(message.isUser, true);
      expect(message.isAssistant, false);
    });

    test('should create assistant message with streaming state', () {
      // Arrange
      const message = ChatMessage(
        id: '2',
        role: MessageRole.assistant,
        content: 'Partial response...',
        timestamp: '2026-02-05T10:00:05Z',
        isStreaming: true,
      );

      // Assert
      expect(message.role, MessageRole.assistant);
      expect(message.isStreaming, true);
      expect(message.isComplete, false);
    });

    test('should support equality comparison', () {
      // Arrange
      const message1 = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Test',
        timestamp: '2026-02-05T10:00:00Z',
      );
      const message2 = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Test',
        timestamp: '2026-02-05T10:00:00Z',
      );

      // Assert
      expect(message1, equals(message2));
      expect(message1.hashCode, equals(message2.hashCode));
    });

    test('should create copyWith new content for streaming', () {
      // Arrange
      const original = ChatMessage(
        id: '1',
        role: MessageRole.assistant,
        content: 'Hello',
        timestamp: '2026-02-05T10:00:00Z',
        isStreaming: true,
      );

      // Act
      final updated = original.copyWith(content: 'Hello World');

      // Assert
      expect(updated.content, 'Hello World');
      expect(updated.id, original.id);
      expect(updated.isStreaming, original.isStreaming);
    });

    test('should identify system role as neither user nor assistant', () {
      const message = ChatMessage(
        id: '3',
        role: MessageRole.system,
        content: 'System message',
        timestamp: '2026-02-05T10:00:10Z',
      );

      expect(message.isUser, isFalse);
      expect(message.isAssistant, isFalse);
      expect(message.isComplete, isTrue);
    });

    test('copyWith should update role, timestamp and metadata', () {
      const original = ChatMessage(
        id: '4',
        role: MessageRole.user,
        content: 'Hola',
        timestamp: '2026-02-05T10:00:00Z',
      );

      final updated = original.copyWith(
        role: MessageRole.assistant,
        timestamp: '2026-02-05T10:00:01Z',
        metadata: const {'tokens': 10},
      );

      expect(updated.role, MessageRole.assistant);
      expect(updated.timestamp, '2026-02-05T10:00:01Z');
      expect(updated.metadata?['tokens'], 10);
      expect(updated.id, original.id);
    });

    test('equality depends on id role and content', () {
      const base = ChatMessage(
        id: 'same',
        role: MessageRole.user,
        content: 'X',
        timestamp: 't1',
      );
      const different = ChatMessage(
        id: 'same',
        role: MessageRole.assistant,
        content: 'X',
        timestamp: 't1',
      );

      expect(base == different, isFalse);
      expect(base.hashCode == different.hashCode, isFalse);
    });
  });
}
