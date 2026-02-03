// tests/unit/data/sqlite_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import '../../test_helper.dart';

void main() {
  group('SQLiteDataSource', () {
    late Database database;
    late SQLiteDataSource dataSource;

    setUp(() async {
      database = await initTestDatabase();
      dataSource = SQLiteDataSource(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('createProject inserts project into database', () async {
      const projectData = {
        'id': 'test-proj-1',
        'name': 'Test Project',
        'path': '/home/test/projects/test',
        'createdAt': '2026-02-03T10:00:00Z',
      };

      final id = await dataSource.createProject(projectData);

      expect(id, isNotEmpty);
    });

    test('getProject retrieves project by ID', () async {
      const projectData = {
        'id': 'test-proj-2',
        'name': 'Retrieve Test',
        'path': '/home/test/projects/retrieve',
        'createdAt': '2026-02-03T10:00:00Z',
      };

      await dataSource.createProject(projectData);
      final project = await dataSource.getProject('test-proj-2');

      expect(project, isNotNull);
      expect(project!['name'], 'Retrieve Test');
    });

    test('getAllProjects returns all projects', () async {
      const project1 = {
        'id': 'proj-1',
        'name': 'Project 1',
        'path': '/proj1',
        'createdAt': '2026-02-03T10:00:00Z',
      };
      const project2 = {
        'id': 'proj-2',
        'name': 'Project 2',
        'path': '/proj2',
        'createdAt': '2026-02-03T10:00:00Z',
      };

      await dataSource.createProject(project1);
      await dataSource.createProject(project2);

      final projects = await dataSource.getAllProjects();

      expect(projects.length, 2);
    });

    test('deleteProject removes project from database', () async {
      const projectData = {
        'id': 'test-proj-delete',
        'name': 'Delete Test',
        'path': '/home/test/projects/delete',
        'createdAt': '2026-02-03T10:00:00Z',
      };

      await dataSource.createProject(projectData);
      await dataSource.deleteProject('test-proj-delete');
      final project = await dataSource.getProject('test-proj-delete');

      expect(project, isNull);
    });
  });
}
