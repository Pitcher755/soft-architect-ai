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
  });
}
