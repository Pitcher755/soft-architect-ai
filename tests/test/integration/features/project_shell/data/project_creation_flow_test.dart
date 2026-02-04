// tests/integration/flutter/features/project_shell/data/project_creation_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:softarchitect_ai/features/project_shell/data/repositories/project_repository_impl.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../helpers/test_helper.dart';

void main() {
  group('Project Creation Flow Integration Test', () {
    late SQLiteDataSource dataSource;
    late ProjectRepositoryImpl repository;
    late sqflite.Database db;

    setUp(() async {
      db = await initTestDatabase();
      await clearTestDatabase(db); // Limpiar base de datos antes de cada test
      dataSource = SQLiteDataSource(db);
      repository = ProjectRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('should create and retrieve project successfully', () async {
      // Given
      const projectName = 'integration-test-project';
      const projectPath = '/home/test/integration/project';

      // When - Create project
      final createdProject = await repository.createProject(
        projectName,
        projectPath,
      );

      // Then - Verify project was created
      expect(createdProject.name, equals(projectName));
      expect(createdProject.path, equals(projectPath));
      expect(createdProject.id, startsWith('proj_'));
      expect(createdProject.createdAt, isNotNull);

      // When - Retrieve project
      final retrievedProject = await repository.getProject(createdProject.id);

      // Then - Verify project can be retrieved
      expect(retrievedProject, isNotNull);
      expect(retrievedProject?.id, equals(createdProject.id));
      expect(retrievedProject?.name, equals(projectName));
      expect(retrievedProject?.path, equals(projectPath));
    });

    test('should list all created projects', () async {
      // Given - Create multiple projects
      final project1 = await repository.createProject('project-1', '/path/1');
      final project2 = await repository.createProject('project-2', '/path/2');
      final project3 = await repository.createProject('project-3', '/path/3');

      // When - Get all projects
      final allProjects = await repository.getAllProjects();

      // Then - Verify all projects are returned
      expect(allProjects.length, equals(3));
      expect(
        allProjects.map((p) => p.id),
        containsAll([project1.id, project2.id, project3.id]),
      );
      expect(
        allProjects.map((p) => p.name),
        containsAll(['project-1', 'project-2', 'project-3']),
      );
    });

    test('should update last opened timestamp', () async {
      // Given
      final project = await repository.createProject(
        'test-project',
        '/test/path',
      );

      // When
      await repository.updateLastOpened(project.id);

      // Then - Verify timestamp was updated (would need to check database directly)
      final updatedProject = await repository.getProject(project.id);
      expect(updatedProject?.lastOpened, isNotNull);
    });

    test('should delete project completely', () async {
      // Given
      final project = await repository.createProject(
        'to-delete',
        '/delete/path',
      );
      final projectId = project.id;

      // Verify it exists
      final existing = await repository.getProject(projectId);
      expect(existing, isNotNull);

      // When
      await repository.deleteProject(projectId);

      // Then
      final deleted = await repository.getProject(projectId);
      expect(deleted, isNull);

      // And it's not in the all projects list
      final allProjects = await repository.getAllProjects();
      expect(allProjects.map((p) => p.id), isNot(contains(projectId)));
    });

    test('should return last opened project correctly', () async {
      // Given - Create projects with different last opened times
      final oldProject = await repository.createProject(
        'old-project',
        '/old/path',
      );
      final newProject = await repository.createProject(
        'new-project',
        '/new/path',
      );

      // Update last opened for both (new project last)
      await repository.updateLastOpened(oldProject.id);
      await Future.delayed(
        const Duration(milliseconds: 10),
      ); // Ensure different timestamps
      await repository.updateLastOpened(newProject.id);

      // When
      final lastOpened = await repository.getLastOpenedProject();

      // Then
      expect(lastOpened, isNotNull);
      expect(lastOpened?.id, equals(newProject.id));
    });

    test('should handle validation errors during creation', () async {
      // Test invalid name
      await expectLater(
        repository.createProject('ab', '/valid/path'),
        throwsA(isA<InvalidProjectNameException>()),
      );

      // Test path traversal
      await expectLater(
        repository.createProject('valid-name', '../../../etc/passwd'),
        throwsA(isA<PathTraversalException>()),
      );

      // Test tilde in path
      await expectLater(
        repository.createProject('valid-name', '~/malicious/path'),
        throwsA(isA<PathTraversalException>()),
      );
    });

    test('should generate unique IDs for different projects', () async {
      // Given
      final project1 = await repository.createProject('project-1', '/path/1');
      final project2 = await repository.createProject('project-2', '/path/2');

      // Then
      expect(project1.id, isNot(equals(project2.id)));
      expect(project1.id, startsWith('proj_'));
      expect(project2.id, startsWith('proj_'));
    });

    test('should handle concurrent operations', () async {
      // This test verifies that the repository can handle multiple operations
      // without corrupting data

      final futures = <Future>[];

      // Create multiple projects concurrently
      for (int i = 0; i < 5; i++) {
        futures.add(
          repository.createProject('concurrent-$i', '/concurrent/$i'),
        );
      }

      // Wait for all to complete
      await Future.wait(futures);

      // Verify all were created
      final allProjects = await repository.getAllProjects();
      expect(allProjects.length, equals(5));
      expect(
        allProjects.every((p) => p.name.startsWith('concurrent-')),
        isTrue,
      );
    });
  });
}
