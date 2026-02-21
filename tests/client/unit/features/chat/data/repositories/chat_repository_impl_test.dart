import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';
import 'package:softarchitect_ai/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/infrastructure/network/sse_client.dart';
import 'package:sqflite/sqflite.dart';

/// Fake Database for testing with noSuchMethod for unimplemented methods.
class FakeDatabase implements Database {
  final Map<String, List<Map<String, Object?>>> tables = {};
  final List<Map<String, Object?>> insertCalls = [];

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    insertCalls.add({
      'table': table,
      'values': Map<String, Object?>.from(values),
      'conflictAlgorithm': conflictAlgorithm,
    });
    tables.putIfAbsent(table, () => []);
    tables[table]!.add(Map<String, Object?>.from(values));
    return tables[table]!.length;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (!tables.containsKey(table)) {
      return [];
    }

    var result = tables[table]!;

    // Simple WHERE filtering
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final projectId = whereArgs.first as String;
      result = result
          .where((row) => row['project_id'] == projectId)
          .toList()
          .cast<Map<String, Object?>>();
    }

    return result;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final count = tables[table]?.length ?? 0;
    tables.remove(table);
    return count;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async => 0;

  @override
  Future<void> close() async {}

  @override
  String get path => ':memory:';

  @override
  bool get isOpen => true;

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Database get database => this;

  // noSuchMethod handles all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake SSE Client for testing.
class FakeSseClient implements SseClient {
  @override
  Stream<ChatStreamEvent> connect(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async* {
    yield TokenEvent(token: 'test', isFinal: false);
  }

  @override
  Duration get timeout => const Duration(seconds: 30);

  @override
  void close() {}
}

/// Failing database for error testing.
class FailingDatabase extends FakeDatabase {
  bool insertAttempted = false;

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    insertAttempted = true;
    throw Exception('Database error');
  }
}

void main() {
  late FakeDatabase fakeDatabase;
  late FakeSseClient fakeSseClient;
  late ChatRepositoryImpl repository;

  setUp(() {
    fakeDatabase = FakeDatabase();
    fakeSseClient = FakeSseClient();
    repository = ChatRepositoryImpl(
      baseUrl: 'http://localhost:8000',
      apiKey: 'test-key',
      sseClient: fakeSseClient,
      database: fakeDatabase,
    );
  });

  group('ChatRepositoryImpl - saveProposal', () {
    test('should save proposal with correct metadata to database', () async {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-1',
        docType: 'README',
        content: '# README\n\nTest content',
        metadata: {'author': 'test'},
        validationState: ValidationState.pending,
      );

      // Act
      await repository.saveProposal(proposal);

      // Assert
      expect(fakeDatabase.insertCalls, hasLength(1));
      final insertCall = fakeDatabase.insertCalls.first;
      expect(insertCall['table'], 'chat_messages');
      expect(insertCall['conflictAlgorithm'], ConflictAlgorithm.replace);

      final values = insertCall['values'] as Map<String, Object?>;
      expect(values['id'], 'prop-1');
      expect(values['project_id'], 'proposal');
      expect(values['role'], 'assistant');
      expect(values['content'], '# README\n\nTest content');
    });

    test('should include all proposal metadata in saved message', () async {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-2',
        docType: 'MANIFESTO',
        content: '# Project Manifesto',
        metadata: {'version': '1.0', 'priority': 'high'},
        validationState: ValidationState.validated,
      );

      // Act
      await repository.saveProposal(proposal);

      // Assert
      expect(fakeDatabase.insertCalls, hasLength(1));
      final values =
          fakeDatabase.insertCalls.first['values'] as Map<String, Object?>;

      final metadataJson = values['metadata'] as String;
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      expect(metadata['is_proposal'], true);
      expect(metadata['doc_type'], 'MANIFESTO');
      expect(metadata['validation_state'], 'validated');
      expect(metadata['version'], '1.0');
      expect(metadata['priority'], 'high');
    });

    test('should not throw when database insert fails', () async {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-3',
        docType: 'DESIGN',
        content: '# Design Doc',
        metadata: {},
        validationState: ValidationState.pending,
      );

      final failingDatabase = FailingDatabase();
      final failingRepository = ChatRepositoryImpl(
        baseUrl: 'http://localhost:8000',
        apiKey: 'test-key',
        sseClient: fakeSseClient,
        database: failingDatabase,
      );

      // Act & Assert - Should not throw
      await failingRepository.saveProposal(proposal);

      // Verify insert was attempted
      expect(failingDatabase.insertAttempted, true);
    });

    test('should use ConflictAlgorithm.replace for upsert behavior', () async {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-4',
        docType: 'API_SPEC',
        content: '# API Specification',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await repository.saveProposal(proposal);

      // Assert
      expect(fakeDatabase.insertCalls, hasLength(1));
      expect(
        fakeDatabase.insertCalls.first['conflictAlgorithm'],
        ConflictAlgorithm.replace,
      );
    });

    test('should format timestamp correctly in ISO8601', () async {
      // Arrange
      final now = DateTime(2026, 2, 13, 14, 30);
      final proposal = DocumentProposal(
        id: 'prop-5',
        docType: 'CHANGELOG',
        content: '# Changelog',
        metadata: {},
        validationState: ValidationState.pending,
        createdAt: now,
      );

      // Act
      await repository.saveProposal(proposal);

      // Assert
      expect(fakeDatabase.insertCalls, hasLength(1));
      final values =
          fakeDatabase.insertCalls.first['values'] as Map<String, Object?>;
      final timestamp = values['timestamp'] as String;

      expect(timestamp, '2026-02-13T14:30:00.000');

      // Verify ISO8601 format can be parsed
      final parsedDate = DateTime.parse(timestamp);
      expect(parsedDate.year, 2026);
      expect(parsedDate.month, 2);
      expect(parsedDate.day, 13);
      expect(parsedDate.hour, 14);
      expect(parsedDate.minute, 30);
    });
  });

  group('ChatRepositoryImpl - getChatHistory', () {
    test('should return empty list when no messages exist', () async {
      // Arrange - Empty database

      // Act
      final result = await repository.getChatHistory('test-project');

      // Assert
      expect(result, isEmpty);
    });

    test('should parse metadata correctly from JSON', () async {
      // Arrange - Insert a message with metadata
      await fakeDatabase.insert('chat_messages', {
        'id': 'msg-1',
        'project_id': 'test-project',
        'role': 'assistant',
        'content': 'Test content',
        'timestamp': '2026-02-13T10:00:00.000',
        'is_streaming': 0,
        'metadata': jsonEncode({'is_proposal': true, 'doc_type': 'README'}),
      });

      // Act
      final result = await repository.getChatHistory('test-project');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.metadata, isNotNull);
      expect(result.first.metadata!['is_proposal'], true);
      expect(result.first.metadata!['doc_type'], 'README');
    });

    test('should handle empty metadata gracefully', () async {
      // Arrange - Insert a message with empty metadata
      await fakeDatabase.insert('chat_messages', {
        'id': 'msg-2',
        'project_id': 'test-project',
        'role': 'user',
        'content': 'User message',
        'timestamp': '2026-02-13T10:05:00.000',
        'is_streaming': 0,
        'metadata': '{}', // Empty metadata JSON
      });

      // Act
      final result = await repository.getChatHistory('test-project');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.metadata, isEmpty);
    });
  });
}
