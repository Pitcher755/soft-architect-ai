// tests/unit/data/sqlite_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:softarchitect_ai/features/project_shell/data/models/project_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SQLiteDataSource', () {
    late Database db;

    setUp(() async {
      sqfliteFfiInit();
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await SQLiteDataSource.createTables(db);
    });

    tearDown(() async => await db.close());

    test('saveProject inserts project into database', () async {
      final ds = SQLiteDataSource(db);
      final project = ProjectModel(
        id: '123',
        name: 'test-project',
        path: '/path',
        createdAt: DateTime.now(),
      );
      await ds.saveProject(project);
      final result = await db.query(
        'projects',
        where: 'id = ?',
        whereArgs: ['123'],
      );
      expect(result.length, 1);
    });

    test('getProject retrieves project from database', () async {
      final ds = SQLiteDataSource(db);
      final project = ProjectModel(
        id: '456',
        name: 'another-project',
        path: '/path',
        createdAt: DateTime.now(),
      );
      await ds.saveProject(project);
      final retrieved = await ds.getProject('456');
      expect(retrieved?.name, 'another-project');
    });

    test('saveProject throws on duplicate name', () async {
      final ds = SQLiteDataSource(db);
      await db.insert('projects', {
        'id': '1',
        'name': 'duplicate',
        'path': '/p1',
        'created_at': DateTime.now().toIso8601String(),
      });
      final dup = ProjectModel(
        id: '2',
        name: 'duplicate',
        path: '/p2',
        createdAt: DateTime.now(),
      );
      expect(() => ds.saveProject(dup), throwsA(isA<DatabaseException>()));
    });
  });
}
