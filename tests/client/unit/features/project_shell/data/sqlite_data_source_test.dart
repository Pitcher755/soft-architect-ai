// tests/unit/flutter/features/project_shell/data/sqlite_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:softarchitect_ai/features/project_shell/data/models/project_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../helpers/test_helper.dart';

void main() {
  group('SQLiteDataSource', () {
    late sqflite.Database db;
    late SQLiteDataSource dataSource;

    setUp(() async {
      db = await initTestDatabase();
      dataSource = SQLiteDataSource(db);
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    group('saveProject', () {
      test('should save project successfully', () async {
        final project = ProjectModel(
          id: 'test-proj-123',
          name: 'test-project',
          path: '/home/test/project',
          createdAt: DateTime(2026, 2, 3, 10, 0),
        );

        await dataSource.saveProject(project);

        final saved = await dataSource.getProject('test-proj-123');
        expect(saved?.id, equals('test-proj-123'));
        expect(saved?.name, equals('test-project'));
        expect(saved?.path, equals('/home/test/project'));
      });

      test(
        'should throw DatabaseException when saving duplicate project',
        () async {
          final project = ProjectModel(
            id: 'test-proj-123',
            name: 'test-project',
            path: '/home/test/project',
            createdAt: DateTime(2026, 2, 3, 10, 0),
          );

          await dataSource.saveProject(project);

          expect(
            () => dataSource.saveProject(project),
            throwsA(isA<DatabaseException>()),
          );
        },
      );
    });

    group('getProject', () {
      test('should return project when exists', () async {
        final project = ProjectModel(
          id: 'test-proj-123',
          name: 'test-project',
          path: '/home/test/project',
          createdAt: DateTime(2026, 2, 3, 10, 0),
        );

        await dataSource.saveProject(project);
        final result = await dataSource.getProject('test-proj-123');

        expect(result, isNotNull);
        expect(result?.id, equals('test-proj-123'));
        expect(result?.name, equals('test-project'));
      });

      test('should return null when project does not exist', () async {
        final result = await dataSource.getProject('non-existent-id');
        expect(result, isNull);
      });
    });

    group('getAllProjects', () {
      test('should return all projects', () async {
        final project1 = ProjectModel(
          id: 'test-proj-1',
          name: 'project-1',
          path: '/home/test/project1',
          createdAt: DateTime(2026, 2, 3, 10, 0),
        );

        final project2 = ProjectModel(
          id: 'test-proj-2',
          name: 'project-2',
          path: '/home/test/project2',
          createdAt: DateTime(2026, 2, 3, 11, 0),
        );

        await dataSource.saveProject(project1);
        await dataSource.saveProject(project2);

        final results = await dataSource.getAllProjects();

        expect(results.length, equals(2));
        expect(
          results.map((p) => p.id),
          containsAll(['test-proj-1', 'test-proj-2']),
        );
      });

      test('should return empty list when no projects exist', () async {
        final results = await dataSource.getAllProjects();
        expect(results, isEmpty);
      });
    });

    group('updateLastOpened', () {
      test('should update last opened timestamp', () async {
        final project = ProjectModel(
          id: 'test-proj-123',
          name: 'test-project',
          path: '/home/test/project',
          createdAt: DateTime(2026, 2, 3, 10, 0),
        );

        await dataSource.saveProject(project);
        await dataSource.updateLastOpened('test-proj-123');

        final updated = await dataSource.getProject('test-proj-123');
        expect(updated?.lastOpened, isNotNull);
        expect(
          updated?.lastOpened?.isAfter(DateTime(2026, 2, 3, 9, 59)),
          isTrue,
        );
      });
    });

    group('deleteProject', () {
      test('should delete project successfully', () async {
        final project = ProjectModel(
          id: 'test-proj-123',
          name: 'test-project',
          path: '/home/test/project',
          createdAt: DateTime(2026, 2, 3, 10, 0),
        );

        await dataSource.saveProject(project);
        await dataSource.deleteProject('test-proj-123');

        final result = await dataSource.getProject('test-proj-123');
        expect(result, isNull);
      });

      test('should not throw when deleting non-existent project', () async {
        await expectLater(
          dataSource.deleteProject('non-existent-id'),
          completes,
        );
      });
    });

    group('createTables', () {
      test('should create tables without error', () async {
        // Tables are created in setUp, this test verifies no exceptions
        final result = await dataSource.getAllProjects();
        expect(result, isA<List<ProjectModel>>());
      });
    });
  });
}
