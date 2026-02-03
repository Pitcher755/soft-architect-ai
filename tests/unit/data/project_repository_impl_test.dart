// tests/unit/data/project_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/features/project_shell/data/repositories/project_repository_impl.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import '../../test_helper.dart';

void main() {
  group('ProjectRepositoryImpl', () {
    late ProjectRepositoryImpl repository;
    late MockSQLiteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockSQLiteDataSource();
      repository = ProjectRepositoryImpl(mockDataSource);
    });

    test('createProject returns project on success', () async {
      const projectName = 'New Project';
      const projectPath = '/home/user/projects/new';

      when(mockDataSource.createProject(any)).thenAnswer((_) async => 'proj-123');

      final result = await repository.createProject(projectName, projectPath);

      expect(result.id, 'proj-123');
      expect(result.name, projectName);
      verify(mockDataSource.createProject(any)).called(1);
    });

    test('getProject returns project when exists', () async {
      final mockProject = {
        'id': 'test-proj',
        'name': 'Test',
        'path': '/test',
        'createdAt': '2026-02-03T10:00:00Z',
      };

      when(mockDataSource.getProject('test-proj'))
          .thenAnswer((_) async => mockProject);

      final result = await repository.getProject('test-proj');

      expect(result, isNotNull);
      expect(result!.name, 'Test');
    });

    test('getAllProjects returns list of projects', () async {
      final mockProjects = [
        {
          'id': 'proj-1',
          'name': 'Project 1',
          'path': '/proj1',
          'createdAt': '2026-02-03T10:00:00Z',
        },
        {
          'id': 'proj-2',
          'name': 'Project 2',
          'path': '/proj2',
          'createdAt': '2026-02-03T10:00:00Z',
        },
      ];

      when(mockDataSource.getAllProjects())
          .thenAnswer((_) async => mockProjects);

      final results = await repository.getAllProjects();

      expect(results.length, 2);
      expect(results[0].name, 'Project 1');
      expect(results[1].name, 'Project 2');
    });

    test('deleteProject calls dataSource deleteProject', () async {
      when(mockDataSource.deleteProject('proj-to-delete'))
          .thenAnswer((_) async => {});

      await repository.deleteProject('proj-to-delete');

      verify(mockDataSource.deleteProject('proj-to-delete')).called(1);
    });
  });
}
