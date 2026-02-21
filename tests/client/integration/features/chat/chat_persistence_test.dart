import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Chat Persistence Integration Tests', () {
    late ChatRepositoryImpl repository;
    late Database testDb;

    setUp(() async {
      // Create in-memory database for each test
      testDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create schema
      await testDb.execute('''
        CREATE TABLE IF NOT EXISTS chat_messages (
          id TEXT PRIMARY KEY,
          project_id TEXT NOT NULL,
          role TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          is_streaming INTEGER DEFAULT 0,
          metadata TEXT
        )
      ''');

      repository = ChatRepositoryImpl(
        baseUrl: 'http://localhost:8000',
        apiKey: 'test-key',
        database: testDb,
      );
    });

    tearDown(() async {
      await testDb.close();
    });

    test('should save and retrieve chat messages', () async {
      const projectId = 'test-project-123';

      // Save messages
      final message1 = ChatMessage(
        id: 'msg1',
        role: MessageRole.user,
        content: 'Hello',
        timestamp: DateTime.now().toIso8601String(),
      );

      final message2 = ChatMessage(
        id: 'msg2',
        role: MessageRole.assistant,
        content: 'Hi there!',
        timestamp: DateTime.now().toIso8601String(),
      );

      await repository.saveMessage(projectId, message1);
      await repository.saveMessage(projectId, message2);

      // Retrieve history
      final history = await repository.getChatHistory(projectId);

      expect(history.length, 2);
      expect(history[0].id, 'msg1');
      expect(history[0].content, 'Hello');
      expect(history[0].role, MessageRole.user);
      expect(history[1].id, 'msg2');
      expect(history[1].content, 'Hi there!');
      expect(history[1].role, MessageRole.assistant);
    });

    test('should clear chat history for project', () async {
      const projectId = 'test-project-456';

      // Save message
      final message = ChatMessage(
        id: 'msg1',
        role: MessageRole.user,
        content: 'Test',
        timestamp: DateTime.now().toIso8601String(),
      );

      await repository.saveMessage(projectId, message);

      // Verify saved
      var history = await repository.getChatHistory(projectId);
      expect(history.length, 1);

      // Clear history
      await repository.clearChatHistory(projectId);

      // Verify cleared
      history = await repository.getChatHistory(projectId);
      expect(history, isEmpty);
    });

    test('should handle multiple projects independently', () async {
      const project1 = 'project-a';
      const project2 = 'project-b';

      // Save to project 1
      await repository.saveMessage(
        project1,
        ChatMessage(
          id: 'msg-a1',
          role: MessageRole.user,
          content: 'Message A1',
          timestamp: DateTime.now().toIso8601String(),
        ),
      );

      // Save to project 2
      await repository.saveMessage(
        project2,
        ChatMessage(
          id: 'msg-b1',
          role: MessageRole.user,
          content: 'Message B1',
          timestamp: DateTime.now().toIso8601String(),
        ),
      );

      // Verify separate histories
      final historyA = await repository.getChatHistory(project1);
      final historyB = await repository.getChatHistory(project2);

      expect(historyA.length, 1);
      expect(historyB.length, 1);
      expect(historyA[0].content, 'Message A1');
      expect(historyB[0].content, 'Message B1');
    });

    test('should preserve message metadata', () async {
      const projectId = 'test-metadata';

      final message = ChatMessage(
        id: 'msg-with-meta',
        role: MessageRole.assistant,
        content: 'Response with metadata',
        timestamp: DateTime.now().toIso8601String(),
        metadata: {'docType': 'README', 'isProposal': true},
      );

      await repository.saveMessage(projectId, message);

      final history = await repository.getChatHistory(projectId);

      expect(history.length, 1);
      expect(history[0].metadata, isNotNull);
      expect(history[0].metadata!['docType'], 'README');
      expect(history[0].metadata!['isProposal'], true);
    });

    test('should return empty list for non-existent project', () async {
      const projectId = 'non-existent';

      final history = await repository.getChatHistory(projectId);

      expect(history, isEmpty);
    });

    test('should preserve message order by timestamp', () async {
      const projectId = 'order-test';

      // Save messages with explicit timestamps
      final msg1 = ChatMessage(
        id: 'msg1',
        role: MessageRole.user,
        content: 'First',
        timestamp: '2024-01-01T10:00:00.000Z',
      );

      final msg2 = ChatMessage(
        id: 'msg2',
        role: MessageRole.assistant,
        content: 'Second',
        timestamp: '2024-01-01T10:01:00.000Z',
      );

      final msg3 = ChatMessage(
        id: 'msg3',
        role: MessageRole.user,
        content: 'Third',
        timestamp: '2024-01-01T10:02:00.000Z',
      );

      // Save in random order
      await repository.saveMessage(projectId, msg2);
      await repository.saveMessage(projectId, msg1);
      await repository.saveMessage(projectId, msg3);

      // Retrieve should be in timestamp order
      final history = await repository.getChatHistory(projectId);

      expect(history.length, 3);
      expect(history[0].content, 'First');
      expect(history[1].content, 'Second');
      expect(history[2].content, 'Third');
    });
  });
}
