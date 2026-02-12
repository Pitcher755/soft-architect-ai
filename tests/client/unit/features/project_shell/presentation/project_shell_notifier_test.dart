// tests/unit/flutter/features/project_shell/presentation/project_shell_notifier_test.dart
// ignore_for_file: invalid_use_of_protected_member,invalid_use_of_visible_for_testing_member
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/repositories/project_repository.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/notifiers/project_shell_notifier.dart';

import '../../../../helpers/project_fixtures.dart';

// Fake implementation for testing
class FakeProjectRepository implements ProjectRepository {
  FakeProjectRepository({
    this.projects = const [],
    this.shouldThrowGetAll = false,
    this.shouldThrowCreate = false,
    this.shouldThrowDelete = false,
    this.exception,
    this.createdProject,
  });

  final List<Project> projects;
  final bool shouldThrowGetAll;
  final bool shouldThrowCreate;
  final bool shouldThrowDelete;
  final Exception? exception;
  final Project? createdProject;

  @override
  Future<Project> createProject(String name, String path) async {
    if (shouldThrowCreate) {
      throw exception ?? Exception('Test error');
    }
    return createdProject ??
        Project(
          id: 'test-id',
          name: name,
          path: path,
          createdAt: DateTime.now(),
          lastOpened: null,
        );
  }

  @override
  Future<Project?> getProject(String projectId) async {
    if (shouldThrowGetAll) {
      throw exception ?? Exception('Test error');
    }
    return projects.where((p) => p.id == projectId).firstOrNull;
  }

  @override
  Future<List<Project>> getAllProjects() async {
    if (shouldThrowGetAll) {
      throw exception ?? Exception('Test error');
    }
    return projects;
  }

  @override
  Future<Project?> getLastOpenedProject() async {
    if (shouldThrowGetAll) {
      throw exception ?? Exception('Test error');
    }
    return projects.where((p) => p.lastOpened != null).firstOrNull;
  }

  @override
  Future<void> updateLastOpened(String projectId) async {
    if (shouldThrowGetAll) {
      throw exception ?? Exception('Test error');
    }
    // No-op for fake implementation
  }

  @override
  Future<void> updateProject(Project project) async {
    if (shouldThrowGetAll) {
      throw exception ?? Exception('Test error');
    }
    // No-op for fake implementation
  }

  @override
  Future<void> deleteProject(String projectId) async {
    if (shouldThrowDelete) {
      throw exception ?? Exception('Test error');
    }
    // No-op for fake implementation
  }
}

void main() {
  group('ProjectShellNotifier', () {
    late ProjectShellNotifier notifier;

    tearDown(() {
      // Only dispose if initialized (some tests may not create it)
      try {
        notifier.dispose();
      } catch (_) {
        // Ignore if not initialized
      }
    });

    ProjectShellNotifier createNotifier([
      List<Project>? initialProjects,
      Exception? error,
      Project? createdProject,
      bool shouldThrowDelete = false,
      bool shouldThrowCreate = false,
    ]) {
      final repo = FakeProjectRepository(
        projects: initialProjects ?? [],
        shouldThrowGetAll:
            error != null && !shouldThrowDelete && !shouldThrowCreate,
        shouldThrowCreate: shouldThrowCreate,
        shouldThrowDelete: shouldThrowDelete,
        exception: error,
        createdProject: createdProject,
      );
      return ProjectShellNotifier(repo);
    }

    group('initialization', () {
      test('should load projects on initialization', () async {
        final List<Project> projects = [testProject];

        // Create notifier with initial projects
        notifier = createNotifier(projects);

        // Wait for initialization to complete
        await Future.delayed(Duration.zero);

        expect(notifier.state.projects, equals(projects));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, isNull);
      });

      test('should handle initialization error', () async {
        // Create notifier with error
        notifier = createNotifier(null, Exception('Database error'));

        // Wait for initialization to complete
        await Future.delayed(Duration.zero);

        expect(notifier.state.projects, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(
          notifier.state.errorMessage,
          contains('Failed to load projects'),
        );
      });
    });

    group('selectProject', () {
      test('should update selected project and timestamp', () async {
        // Initialize with projects
        notifier = createNotifier([testProject]);
        await Future.delayed(Duration.zero);

        await notifier.selectProject(testProject);

        // Verify selected project
        expect(notifier.state.selectedProject, isNotNull);
        expect(
          notifier.state.selectedProject!.id,
          equals(testProject.id),
        );

        // Verify lastOpened was updated
        expect(
          notifier.state.selectedProject!.lastOpened,
          isNotNull,
        );
      });
    });

    group('createProject', () {
      test('should create project and update state', () async {
        const name = 'new-project';
        const path = '/home/test/new-project';
        final newProject = Project(
          id: 'new-proj-123',
          name: name,
          path: path,
          createdAt: DateTime(2026, 2, 3, 12, 0),
        );

        // Initialize with empty projects
        notifier = createNotifier([], null, newProject);
        await Future.delayed(Duration.zero);

        await notifier.createProject(name, path);

        expect(notifier.state.projects, contains(newProject));
        expect(notifier.state.selectedProject, equals(newProject));
        expect(notifier.state.errorMessage, isNull);
      });

      test('should handle create project error', () async {
        const name = 'invalid-project';
        const path = '/home/test/project';

        // Initialize with empty projects and error for createProject
        notifier = createNotifier(
          [],
          Exception('Validation error'),
          null,
          false,
          true,
        );
        await Future.delayed(Duration.zero);

        await notifier.createProject(name, path);

        expect(notifier.state.projects, isEmpty);
        expect(notifier.state.selectedProject, isNull);
        expect(
          notifier.state.errorMessage,
          contains('Failed to create project'),
        );
      });
    });

    group('deleteProject', () {
      test('should delete project and update state', () async {
        final projectToDelete = testProject;
        final otherProject = Project(
          id: 'other-proj-456',
          name: 'other-project',
          path: '/home/test/other',
          createdAt: DateTime(2026, 2, 3, 11, 0),
        );

        // Initialize with projects
        notifier = createNotifier([projectToDelete, otherProject]);
        await Future.delayed(Duration.zero);

        // Select the project to delete
        await notifier.selectProject(projectToDelete);

        await notifier.deleteProject(projectToDelete.id);

        expect(notifier.state.projects, equals([otherProject]));
        expect(
          notifier.state.selectedProject,
          isNull,
        ); // Should be deselected
        expect(notifier.state.errorMessage, isNull);
      });

      test(
        'should keep selected project if different project deleted',
        () async {
          final projectToDelete = testProject;
          final otherProject = Project(
            id: 'other-proj-456',
            name: 'other-project',
            path: '/home/test/other',
            createdAt: DateTime(2026, 2, 3, 11, 0),
          );

          // Initialize with projects
          notifier = createNotifier([projectToDelete, otherProject]);
          await Future.delayed(Duration.zero);

          // Select a different project
          await notifier.selectProject(otherProject);

          await notifier.deleteProject(projectToDelete.id);

          expect(notifier.state.projects, equals([otherProject]));
          expect(
            notifier.state.selectedProject,
            equals(otherProject),
          ); // Should remain selected
          expect(notifier.state.errorMessage, isNull);
        },
      );

      test('should handle delete project error', () async {
        final projectToDelete = testProject;

        // Initialize with projects and error for deleteProject
        notifier = createNotifier(
          [projectToDelete],
          Exception('Delete error'),
          null,
          true,
        );
        await Future.delayed(Duration.zero);

        await notifier.deleteProject(projectToDelete.id);

        expect(
          notifier.state.projects,
          equals([projectToDelete]),
        ); // Should remain
        expect(
          notifier.state.errorMessage,
          contains('Failed to delete project'),
        );
      });
    });

    group('ProjectShellState', () {
      test('copyWith should create new instance with updated values', () {
        const originalState = ProjectShellState(
          projects: [],
          selectedProject: null,
          isLoading: false,
          errorMessage: null,
        );

        final newProject = testProject;
        final updatedState = originalState.copyWith(
          projects: [newProject],
          selectedProject: newProject,
          isLoading: true,
          errorMessage: 'Test error',
        );

        expect(updatedState.projects, equals([newProject]));
        expect(updatedState.selectedProject, equals(newProject));
        expect(updatedState.isLoading, isTrue);
        expect(updatedState.errorMessage, equals('Test error'));
      });

      test('copyWith should preserve original values when not specified', () {
        const originalState = ProjectShellState(
          projects: [],
          selectedProject: null,
          isLoading: true,
          errorMessage: 'Original error',
        );

        final updatedState = originalState.copyWith(projects: [testProject]);

        expect(updatedState.projects, equals([testProject]));
        expect(updatedState.selectedProject, isNull);
        expect(updatedState.isLoading, isTrue);
        expect(updatedState.errorMessage, equals('Original error'));
      });
    });
  });
}
