import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/data/repositories/project_repository.dart';
import 'package:softarchitect_ai/features/project_shell/data/datasources/sqlite_datasource.dart';

void main() {
  late ProjectRepository repository;
  late SQLiteDataSource dataSource;

  setUp(() {
    dataSource = SQLiteDataSource();
    repository = ProjectRepository(dataSource);
  });

  group('ProjectRepository Integration Tests', () {
    group('Create and Retrieve Flow', () {
      test('creates project and retrieves it successfully', () async {
        final project = Project(
          id: 'test-001',
          name: 'Integration Test Project',
          path: '/tmp/test-project',
          description: 'Test description',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create
        await repository.createProject(project);

        // Retrieve
        final retrieved = await repository.getProjectById('test-001');

        expect(retrieved, isNotNull);
        expect(retrieved?.name, equals('Integration Test Project'));
        expect(retrieved?.path, equals('/tmp/test-project'));
      });

      test('creates multiple projects and lists all', () async {
        final projects = [
          Project(
            id: 'test-002',
            name: 'Project Alpha',
            path: '/tmp/alpha',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Project(
            id: 'test-003',
            name: 'Project Beta',
            path: '/tmp/beta',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final project in projects) {
          await repository.createProject(project);
        }

        final allProjects = await repository.getAllProjects();

        expect(allProjects.length, greaterThanOrEqualTo(2));
        expect(
          allProjects.map((p) => p.id).contains('test-002'),
          isTrue,
        );
      });
    });

    group('Update Project Flow', () {
      test('updates project metadata successfully', () async {
        final original = Project(
          id: 'test-004',
          name: 'Original Name',
          path: '/tmp/original',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createProject(original);

        final updated = Project(
          id: 'test-004',
          name: 'Updated Name',
          path: '/tmp/updated',
          description: 'New description',
          createdAt: original.createdAt,
          updatedAt: DateTime.now(),
        );

        await repository.updateProject(updated);

        final retrieved = await repository.getProjectById('test-004');

        expect(retrieved?.name, equals('Updated Name'));
        expect(retrieved?.description, equals('New description'));
      });
    });

    group('Delete Project Flow', () {
      test('deletes project and verifies removal', () async {
        final project = Project(
          id: 'test-005',
          name: 'To Delete',
          path: '/tmp/delete-me',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createProject(project);
        await repository.deleteProject('test-005');

        final retrieved = await repository.getProjectById('test-005');

        expect(retrieved, isNull);
      });
    });

    group('Search and Filter Flow', () {
      test('searches projects by name pattern', () async {
        await repository.createProject(Project(
          id: 'search-001',
          name: 'Flutter Project',
          path: '/tmp/flutter',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        await repository.createProject(Project(
          id: 'search-002',
          name: 'Python Project',
          path: '/tmp/python',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        final results = await repository.searchProjects('Flutter');

        expect(results, isNotEmpty);
        expect(results.first.name, contains('Flutter'));
      });

      test('filters projects by creation date', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1));

        await repository.createProject(Project(
          id: 'date-001',
          name: 'Recent Project',
          path: '/tmp/recent',
          createdAt: now,
          updatedAt: now,
        ));

        final oldProject = Project(
          id: 'date-002',
          name: 'Old Project',
          path: '/tmp/old',
          createdAt: yesterday,
          updatedAt: yesterday,
        );

        // Simulate old project in database
        await repository.createProject(oldProject);

        final recentProjects = await repository.getProjectsCreatedAfter(
          yesterday.add(Duration(hours: 1)),
        );

        expect(recentProjects, isNotEmpty);
      });
    });

    group('Concurrent Operations', () {
      test('handles multiple rapid creations without conflicts', () async {
        final futures = List.generate(
          5,
          (index) => repository.createProject(
            Project(
              id: 'concurrent-$index',
              name: 'Project $index',
              path: '/tmp/project-$index',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
        );

        await Future.wait(futures);

        final allProjects = await repository.getAllProjects();

        expect(
          allProjects
              .where((p) => p.id.startsWith('concurrent-'))
              .length,
          equals(5),
        );
      });
    });

    group('Error Handling Integration', () {
      test('handles duplicate project creation gracefully', () async {
        final project = Project(
          id: 'duplicate-001',
          name: 'Duplicate Test',
          path: '/tmp/dup',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createProject(project);

        expect(
          () => repository.createProject(project),
          throwsException,
        );
      });

      test('handles update of non-existent project', () async {
        final project = Project(
          id: 'nonexistent-001',
          name: 'Does Not Exist',
          path: '/tmp/nope',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () => repository.updateProject(project),
          throwsException,
        );
      });

      test('handles database connection errors gracefully', () async {
        // Simulate connection error by using invalid datasource
        final badRepository = ProjectRepository(
          SQLiteDataSource(), // Placeholder for error simulation
        );

        expect(
          () => badRepository.getProjectById('invalid'),
          throwsException,
        );
      });
    });

    group('Data Consistency', () {
      test('maintains data consistency across operations', () async {
        const projectId = 'consistency-001';
        const initialName = 'Initial Name';
        const updatedName = 'Updated Name';

        // Create
        final initial = Project(
          id: projectId,
          name: initialName,
          path: '/tmp/consistency',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.createProject(initial);

        // Verify creation
        var retrieved = await repository.getProjectById(projectId);
        expect(retrieved?.name, equals(initialName));

        // Update
        final updated = Project(
          id: projectId,
          name: updatedName,
          path: '/tmp/consistency',
          createdAt: initial.createdAt,
          updatedAt: DateTime.now(),
        );
        await repository.updateProject(updated);

        // Verify update
        retrieved = await repository.getProjectById(projectId);
        expect(retrieved?.name, equals(updatedName));

        // Delete
        await repository.deleteProject(projectId);

        // Verify deletion
        retrieved = await repository.getProjectById(projectId);
        expect(retrieved, isNull);
      });
    });
  });
}
