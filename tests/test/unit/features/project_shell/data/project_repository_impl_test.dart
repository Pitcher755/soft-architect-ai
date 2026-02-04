// tests/unit/flutter/features/project_shell/data/project_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:softarchitect_ai/features/project_shell/data/models/project_model.dart';
import 'package:softarchitect_ai/features/project_shell/data/repositories/project_repository_impl.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';

// Generate mocks
class MockSQLiteDataSource extends Mock implements SQLiteDataSource {}

void main() {
  group('ProjectRepositoryImpl', () {
    late MockSQLiteDataSource mockDataSource;
    late ProjectRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockSQLiteDataSource();
      repository = ProjectRepositoryImpl(mockDataSource);
    });

    group('createProject', () {
      test('should create project successfully with valid data', () async {
        const name = 'test-project';
        const path = '/home/test/project';

        final expectedProject = ProjectModel(
          id: anyNamed('id'), // Will be generated
          name: name,
          path: path,
          createdAt: anyNamed('createdAt'), // Will be set
        );

        when(mockDataSource.saveProject(any)).thenAnswer((_) async {});

        final result = await repository.createProject(name, path);

        expect(result.name, equals(name));
        expect(result.path, equals(path));
        expect(result.id, startsWith('proj_'));
        expect(result.createdAt, isNotNull);
        verify(mockDataSource.saveProject(any)).called(1);
      });

      test('should throw exception for invalid project name', () async {
        await expectLater(
          repository.createProject('ab', '/home/test/project'),
          throwsA(isA<ValidationException>()),
        );
        verifyNever(mockDataSource.saveProject(any));
      });

      test('should throw exception for path traversal attempt', () async {
        await expectLater(
          repository.createProject('test-project', '../../../etc/passwd'),
          throwsA(isA<PathTraversalException>()),
        );
        verifyNever(mockDataSource.saveProject(any));
      });

      test('should throw exception for tilde in path', () async {
        await expectLater(
          repository.createProject('test-project', '~/malicious/path'),
          throwsA(isA<PathTraversalException>()),
        );
        verifyNever(mockDataSource.saveProject(any));
      });

      test('should rethrow database exceptions', () async {
        when(mockDataSource.saveProject(any))
            .thenThrow(DatabaseException('Database error'));

        await expectLater(
          repository.createProject('test-project', '/home/test/project'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getProject', () {
      test('should return project from data source', () async {
        const projectId = 'test-proj-123';
        final expectedProject = ProjectModel(
          id: projectId,
          name: 'test-project',
          path: '/home/test/project',
          createdAt: DateTime(2026, 2, 3, 10, 0),
        );

        when(mockDataSource.getProject(projectId))
            .thenAnswer((_) async => expectedProject);

        final result = await repository.getProject(projectId);

        expect(result, equals(expectedProject));
        verify(mockDataSource.getProject(projectId)).called(1);
      });

      test('should return null when project not found', () async {
        when(mockDataSource.getProject('non-existent'))
            .thenAnswer((_) async => null);

        final result = await repository.getProject('non-existent');

        expect(result, isNull);
        verify(mockDataSource.getProject('non-existent')).called(1);
      });
    });

    group('getAllProjects', () {
      test('should return all projects from data source', () async {
        final projects = [
          ProjectModel(
            id: 'proj-1',
            name: 'project-1',
            path: '/path/1',
            createdAt: DateTime(2026, 2, 3, 10, 0),
          ),
          ProjectModel(
            id: 'proj-2',
            name: 'project-2',
            path: '/path/2',
            createdAt: DateTime(2026, 2, 3, 11, 0),
          ),
        ];

        when(mockDataSource.getAllProjects())
            .thenAnswer((_) async => projects);

        final result = await repository.getAllProjects();

        expect(result, equals(projects));
        verify(mockDataSource.getAllProjects()).called(1);
      });
    });

    group('getLastOpenedProject', () {
      test('should return project with most recent lastOpened', () async {
        final oldProject = ProjectModel(
          id: 'old-proj',
          name: 'old-project',
          path: '/path/old',
          createdAt: DateTime(2026, 2, 1),
          lastOpened: DateTime(2026, 2, 2),
        );

        final recentProject = ProjectModel(
          id: 'recent-proj',
          name: 'recent-project',
          path: '/path/recent',
          createdAt: DateTime(2026, 2, 1),
          lastOpened: DateTime(2026, 2, 3),
        );

        final noLastOpenedProject = ProjectModel(
          id: 'no-last-opened',
          name: 'no-last-opened-project',
          path: '/path/no-last',
          createdAt: DateTime(2026, 2, 1),
        );

        when(mockDataSource.getAllProjects()).thenAnswer((_) async => [
          oldProject,
          recentProject,
          noLastOpenedProject,
        ]);

        final result = await repository.getLastOpenedProject();

        expect(result, equals(recentProject));
      });

      test('should return null when no projects exist', () async {
        when(mockDataSource.getAllProjects())
            .thenAnswer((_) async => []);

        final result = await repository.getLastOpenedProject();

        expect(result, isNull);
      });
    });

    group('updateLastOpened', () {
      test('should delegate to data source', () async {
        const projectId = 'test-proj-123';

        when(mockDataSource.updateLastOpened(projectId))
            .thenAnswer((_) async {});

        await repository.updateLastOpened(projectId);

        verify(mockDataSource.updateLastOpened(projectId)).called(1);
      });
    });

    group('deleteProject', () {
      test('should delegate to data source', () async {
        const projectId = 'test-proj-123';

        when(mockDataSource.deleteProject(projectId))
            .thenAnswer((_) async {});

        await repository.deleteProject(projectId);

        verify(mockDataSource.deleteProject(projectId)).called(1);
      });
    });

    group('_generateId', () {
      test('should generate deterministic ID with proj_ prefix', () {
        final id1 = repository._generateId('test', '/path');
        final id2 = repository._generateId('test', '/path');

        expect(id1, startsWith('proj_'));
        expect(id1.length, equals(21)); // proj_ + 16 chars
        expect(id1, isNot(equals(id2))); // Should be different due to timestamp
      });
    });
  });
}
