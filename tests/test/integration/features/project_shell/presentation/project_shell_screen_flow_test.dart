// tests/integration/flutter/features/project_shell/presentation/project_shell_screen_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/repositories/project_repository.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/screens/project_shell_screen.dart';

void main() {
  group('Project Shell Screen Flow Integration Test', () {
    testWidgets('should render project shell screen with basic layout', (
      WidgetTester tester,
    ) async {
      // When - Render the project shell screen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override with a mock repository that returns test data
            projectRepositoryProvider.overrideWith(
              (ref) => MockProjectRepository(),
            ),
          ],
          child: MaterialApp(home: ProjectShellScreen()),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Then - Screen should render basic layout
      expect(find.byType(ProjectShellScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display project information when project is selected', (
      WidgetTester tester,
    ) async {
      // When - Render screen and wait for project loading
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectRepositoryProvider.overrideWith(
              (ref) => MockProjectRepository(),
            ),
          ],
          child: MaterialApp(home: ProjectShellScreen()),
        ),
      );

      // Wait for initialization and project loading
      await tester.pumpAndSettle();

      // Then - Should show some project-related UI elements
      // Note: This test verifies basic rendering, detailed interaction tests
      // are covered in widget tests
      expect(find.byType(ProjectShellScreen), findsOneWidget);
    });
  });
}

// Mock repository for testing
class MockProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> getAllProjects() async {
    return [
      Project(
        id: 'test',
        name: 'Test Project',
        path: '/test',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<Project> createProject(String name, String path) async {
    return Project(
      id: 'new',
      name: name,
      path: path,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteProject(String id) async {
    // Mock implementation
  }

  @override
  Future<Project?> getProject(String projectId) async {
    if (projectId == 'test') {
      return Project(
        id: 'test',
        name: 'Test Project',
        path: '/test',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<Project?> getLastOpenedProject() async {
    return Project(
      id: 'test',
      name: 'Test Project',
      path: '/test',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateLastOpened(String projectId) async {
    // Mock implementation
  }
}
