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

    test('equality is false when content differs (same id and role)', () {
      // Forces full evaluation of operator== up to the content comparison.
      final msg1 = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Hello',
        timestamp: 't1',
      );
      final msg2 = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'World',
        timestamp: 't1',
      );

      expect(msg1 == msg2, isFalse);
    });

    test('fromJson deserialises a full JSON map correctly', () {
      final json = {
        'id': 'msg-42',
        'role': 'assistant',
        'content': 'Hello from AI',
        'timestamp': '2026-01-01T00:00:00Z',
        'metadata': <String, dynamic>{'tokens': 5},
      };

      final message = ChatMessage.fromJson(json);

      expect(message.id, 'msg-42');
      expect(message.role, MessageRole.assistant);
      expect(message.content, 'Hello from AI');
      expect(message.timestamp, '2026-01-01T00:00:00Z');
      expect(message.metadata?['tokens'], 5);
    });

    test('fromJson falls back to user role for unknown role string', () {
      final json = {
        'id': 'x',
        'role': 'unknown_role',
        'content': 'content',
        'timestamp': 't',
        'metadata': null,
      };

      final message = ChatMessage.fromJson(json);

      expect(message.role, MessageRole.user);
    });

    test('isHidden returns true when metadata contains hidden:true', () {
      const hidden = ChatMessage(
        id: 'h',
        role: MessageRole.user,
        content: 'secret',
        timestamp: 't',
        metadata: {'hidden': true},
      );
      const visible = ChatMessage(
        id: 'v',
        role: MessageRole.user,
        content: 'visible',
        timestamp: 't',
      );

      expect(hidden.isHidden, isTrue);
      expect(visible.isHidden, isFalse);
    });

    test('toJson serialises all fields correctly', () {
      const message = ChatMessage(
        id: 'msg-1',
        role: MessageRole.assistant,
        content: 'Response text',
        timestamp: '2026-06-01T12:00:00Z',
        metadata: {'key': 'val'},
      );

      final json = message.toJson();

      expect(json['id'], 'msg-1');
      expect(json['role'], 'assistant');
      expect(json['content'], 'Response text');
      expect(json['timestamp'], '2026-06-01T12:00:00Z');
      expect((json['metadata'] as Map<String, dynamic>)['key'], 'val');
    });
  });
}
