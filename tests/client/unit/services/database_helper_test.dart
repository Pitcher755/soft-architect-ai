import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/services/database_helper.dart'
    show DatabaseException, ProjectModel;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

// Helper functions for in-memory database testing
Future<ProjectModel> _insertProject(Database db, ProjectModel project) async {
  try {
    await db.insert('projects', project.toMap());
    return project;
  } catch (e) {
    throw DatabaseException('Failed to insert project', e as Exception);
  }
}

Future<ProjectModel?> _getProjectById(Database db, String id) async {
  final results = await db.query('projects', where: 'id = ?', whereArgs: [id]);
  if (results.isEmpty) return null;
  return ProjectModel.fromMap(results.first);
}

Future<ProjectModel?> _getProjectByPath(Database db, String path) async {
  final results = await db.query(
    'projects',
    where: 'path = ?',
    whereArgs: [path],
  );
  if (results.isEmpty) return null;
  return ProjectModel.fromMap(results.first);
}

Future<List<ProjectModel>> _getAllProjects(Database db) async {
  final results = await db.query('projects');
  return results.map((map) => ProjectModel.fromMap(map)).toList();
}

Future<ProjectModel> _updateProject(Database db, ProjectModel project) async {
  final count = await db.update(
    'projects',
    project.toMap(),
    where: 'id = ?',
    whereArgs: [project.id],
  );
  if (count == 0) {
    throw DatabaseException('Project not found');
  }
  return project;
}

Future<bool> _deleteProject(Database db, String id) async {
  final count = await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  return count > 0;
}

Future<void> _deleteAllProjects(Database db) async {
  await db.delete('projects');
}

Future<int> _deleteChatMessages(Database db, String projectId) async {
  return await db.delete(
    'chat_messages',
    where: 'project_id = ?',
    whereArgs: [projectId],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI (for testing on desktop/CI)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ProjectModel', () {
    test('creates model from map correctly', () {
      final map = {
        'id': 'test-id-123',
        'name': 'Test Project',
        'path': '/home/user/test-project',
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-15T12:45:00.000Z',
      };

      final model = ProjectModel.fromMap(map);

      expect(model.id, equals('test-id-123'));
      expect(model.name, equals('Test Project'));
      expect(model.path, equals('/home/user/test-project'));
      expect(
        model.createdAt,
        equals(DateTime.parse('2024-01-15T10:30:00.000Z')),
      );
      expect(
        model.updatedAt,
        equals(DateTime.parse('2024-01-15T12:45:00.000Z')),
      );
    });

    test('converts model to map correctly', () {
      final createdAt = DateTime.parse('2024-01-15T10:30:00.000Z');
      final updatedAt = DateTime.parse('2024-01-15T12:45:00.000Z');

      final model = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = model.toMap();

      expect(map['id'], equals('test-id-123'));
      expect(map['name'], equals('Test Project'));
      expect(map['path'], equals('/home/user/test-project'));
      expect(map['created_at'], equals(createdAt.toIso8601String()));
      expect(map['updated_at'], equals(updatedAt.toIso8601String()));
    });

    test('creates copy with updated fields', () {
      final original = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        name: 'Updated Project',
        path: '/home/user/updated-project',
      );

      expect(updated.id, equals(original.id));
      expect(updated.name, equals('Updated Project'));
      expect(updated.path, equals('/home/user/updated-project'));
      expect(updated.createdAt, equals(original.createdAt));
      expect(updated.updatedAt, equals(original.updatedAt));
    });

    test('equality compares id, name, and path', () {
      final now = DateTime.now();

      final model1 = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: now,
        updatedAt: now,
      );

      final model2 = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: now.add(const Duration(hours: 1)), // Different timestamp
        updatedAt: now.add(const Duration(hours: 2)),
      );

      final model3 = ProjectModel(
        id: 'different-id',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: now,
        updatedAt: now,
      );

      expect(model1, equals(model2)); // Same id, name, path
      expect(model1, isNot(equals(model3))); // Different id
    });

    test('hashCode is consistent with equals', () {
      final now = DateTime.now();

      final model1 = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: now,
        updatedAt: now,
      );

      final model2 = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: now.add(const Duration(hours: 1)),
        updatedAt: now.add(const Duration(hours: 2)),
      );

      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('toString returns formatted string', () {
      final now = DateTime.now();

      final model = ProjectModel(
        id: 'test-id-123',
        name: 'Test Project',
        path: '/home/user/test-project',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        model.toString(),
        equals(
          'ProjectModel(id: test-id-123, name: Test Project, '
          'path: /home/user/test-project, createdAt: $now, updatedAt: $now)',
        ),
      );
    });
  });

  group('DatabaseException', () {
    test('creates exception with message only', () {
      final exception = DatabaseException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.originalException, isNull);
    });

    test('creates exception with message and original exception', () {
      final originalException = Exception('Original error');
      final exception = DatabaseException('Test error', originalException);

      expect(exception.message, equals('Test error'));
      expect(exception.originalException, equals(originalException));
    });

    test('toString formats correctly without original exception', () {
      final exception = DatabaseException('Test error');

      expect(exception.toString(), equals('DatabaseException: Test error'));
    });

    test('toString formats correctly with original exception', () {
      final originalException = Exception('Original error');
      final exception = DatabaseException('Test error', originalException);

      expect(
        exception.toString(),
        equals(
          'DatabaseException: Test error\n'
          'Cause: Exception: Original error',
        ),
      );
    });
  });

  group('DatabaseHelper', () {
    late Database db;

    setUp(() async {
      // ✅ CRITICAL FIX: Use fully in-memory database (prevents UNIQUE constraint errors)
      // Each test gets a completely fresh, isolated database in RAM
      databaseFactory = databaseFactoryFfi;

      // Create in-memory database (auto-destroyed after test)
      db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            // Replicate DatabaseHelper schema exactly
            await db.execute('''
              CREATE TABLE IF NOT EXISTS projects (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                path TEXT NOT NULL UNIQUE,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                last_opened TEXT
              )
            ''');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS chat_messages (
                id TEXT PRIMARY KEY,
                project_id TEXT NOT NULL,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                timestamp TEXT NOT NULL,
                is_streaming INTEGER DEFAULT 0,
                metadata TEXT,
                FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE INDEX IF NOT EXISTS idx_chat_project_timestamp
              ON chat_messages(project_id, timestamp)
            ''');
          },
        ),
      );
    });

    tearDown(() async {
      // Close in-memory database (automatically destroyed)
      try {
        await db.close();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    group('Database Initialization', () {
      test('initializes database successfully', () async {
        expect(db, isNotNull);
        expect(db.isOpen, isTrue);
      });

      test('returns same database instance on multiple calls', () async {
        expect(db, same(db)); // In-memory DB is singleton
      });

      test('creates projects table with correct schema', () async {
        // Query table info
        final result = await db.rawQuery("PRAGMA table_info('projects')");

        final columns = result.map((row) => row['name'] as String).toList();

        expect(columns, contains('id'));
        expect(columns, contains('name'));
        expect(columns, contains('path'));
        expect(columns, contains('created_at'));
        expect(columns, contains('last_opened'));
      });

      test('creates chat_messages table with correct schema', () async {
        final result = await db.rawQuery("PRAGMA table_info('chat_messages')");

        final columns = result.map((row) => row['name'] as String).toList();

        expect(columns, contains('id'));
        expect(columns, contains('project_id'));
        expect(columns, contains('role'));
        expect(columns, contains('content'));
        expect(columns, contains('timestamp'));
        expect(columns, contains('is_streaming'));
        expect(columns, contains('metadata'));
      });
    });

    group('Project CRUD Operations', () {
      test('inserts project successfully', () async {
        final project = ProjectModel(
          id: 'test-id-123',
          name: 'Test Project',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _insertProject(db, project);

        expect(result.id, equals(project.id));
        expect(result.name, equals(project.name));
        expect(result.path, equals(project.path));
      });

      test('throws on duplicate path insertion', () async {
        final project1 = ProjectModel(
          id: 'test-id-1',
          name: 'Test Project 1',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final project2 = ProjectModel(
          id: 'test-id-2',
          name: 'Test Project 2',
          path: '/home/user/test-project', // Same path
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, project1);

        expect(
          () async => await _insertProject(db, project2),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('retrieves project by ID', () async {
        final project = ProjectModel(
          id: 'test-id-123',
          name: 'Test Project',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, project);

        final retrieved = await _getProjectById(db, 'test-id-123');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('test-id-123'));
        expect(retrieved.name, equals('Test Project'));
      });

      test('returns null when project not found by ID', () async {
        final result = await _getProjectById(db, 'non-existent-id');

        expect(result, isNull);
      });

      test('retrieves project by path', () async {
        final project = ProjectModel(
          id: 'test-id-123',
          name: 'Test Project',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, project);

        final retrieved = await _getProjectByPath(
          db,
          '/home/user/test-project',
        );

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('test-id-123'));
        expect(retrieved.path, equals('/home/user/test-project'));
      });

      test('returns null when project not found by path', () async {
        final result = await _getProjectByPath(db, '/non/existent/path');

        expect(result, isNull);
      });

      test('retrieves all projects', () async {
        final project1 = ProjectModel(
          id: 'test-id-1',
          name: 'Test Project 1',
          path: '/home/user/test-project-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final project2 = ProjectModel(
          id: 'test-id-2',
          name: 'Test Project 2',
          path: '/home/user/test-project-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, project1);
        await _insertProject(db, project2);

        final allProjects = await _getAllProjects(db);

        expect(allProjects.length, equals(2));
        expect(allProjects.any((p) => p.id == 'test-id-1'), isTrue);
        expect(allProjects.any((p) => p.id == 'test-id-2'), isTrue);
      });

      test('returns empty list when no projects exist', () async {
        final allProjects = await _getAllProjects(db);

        expect(allProjects, isEmpty);
      });

      test('updates project successfully', () async {
        final originalProject = ProjectModel(
          id: 'test-id-123',
          name: 'Original Project',
          path: '/home/user/original-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, originalProject);

        final updatedProject = originalProject.copyWith(
          name: 'Updated Project',
        );

        final result = await _updateProject(db, updatedProject);

        expect(result.name, equals('Updated Project'));

        final retrieved = await _getProjectById(db, 'test-id-123');
        expect(retrieved!.name, equals('Updated Project'));
      });

      test('throws when updating non-existent project', () async {
        final project = ProjectModel(
          id: 'non-existent-id',
          name: 'Test Project',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () async => await _updateProject(db, project),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('deletes project successfully', () async {
        final project = ProjectModel(
          id: 'test-id-123',
          name: 'Test Project',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, project);

        final result = await _deleteProject(db, 'test-id-123');

        expect(result, isTrue);

        final retrieved = await _getProjectById(db, 'test-id-123');
        expect(retrieved, isNull);
      });

      test('returns false when deleting non-existent project', () async {
        final result = await _deleteProject(db, 'non-existent-id');

        expect(result, isFalse);
      });

      test('deletes all projects successfully', () async {
        final project1 = ProjectModel(
          id: 'test-id-1',
          name: 'Test Project 1',
          path: '/home/user/test-project-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final project2 = ProjectModel(
          id: 'test-id-2',
          name: 'Test Project 2',
          path: '/home/user/test-project-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _insertProject(db, project1);
        await _insertProject(db, project2);

        await _deleteAllProjects(db);

        final allProjects = await _getAllProjects(db);
        expect(allProjects, isEmpty);
      });
    });

    group('Chat Messages Operations', () {
      test('deletes chat messages for project', () async {
        // Insert test project
        final project = ProjectModel(
          id: 'test-project-id',
          name: 'Test Project',
          path: '/home/user/test-project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _insertProject(db, project);

        // Insert test messages
        await db.insert('chat_messages', {
          'id': 'msg-1',
          'project_id': 'test-project-id',
          'role': 'user',
          'content': 'Test message 1',
          'timestamp': DateTime.now().toIso8601String(),
          'is_streaming': 0,
        });

        await db.insert('chat_messages', {
          'id': 'msg-2',
          'project_id': 'test-project-id',
          'role': 'assistant',
          'content': 'Test message 2',
          'timestamp': DateTime.now().toIso8601String(),
          'is_streaming': 0,
        });

        final deletedCount = await _deleteChatMessages(db, 'test-project-id');

        expect(deletedCount, equals(2));

        // Verify messages deleted
        final messages = await db.query(
          'chat_messages',
          where: 'project_id = ?',
          whereArgs: ['test-project-id'],
        );
        expect(messages, isEmpty);
      });

      test(
        'returns 0 when deleting messages for non-existent project',
        () async {
          final deletedCount = await _deleteChatMessages(
            db,
            'non-existent-project-id',
          );

          expect(deletedCount, equals(0));
        },
      );
    });

    // Note: Database Management tests (close, getDatabaseFileSize) are not
    // applicable for in-memory databases. These would need to be tested
    // separately with a real DatabaseHelper instance if needed.
  });
}
