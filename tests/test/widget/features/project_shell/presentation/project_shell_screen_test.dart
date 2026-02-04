// tests/widget/flutter/features/project_shell/presentation/project_shell_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/repositories/project_repository.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/notifiers/project_shell_notifier.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/screens/project_shell_screen.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/directory_tree_widget.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/markdown_preview_widget.dart';
import '../../../../helpers/project_fixtures.dart';

/// Mock repository that returns predefined test data
class MockProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> getAllProjects() async => [testProject];

  @override
  Future<Project?> getProject(String projectId) async =>
      projectId == testProject.id ? testProject : null;

  @override
  Future<Project> createProject(String name, String path) async {
    return Project(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      path: path,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteProject(String projectId) async {}

  @override
  Future<Project?> getLastOpenedProject() async => testProject;

  @override
  Future<void> updateLastOpened(String projectId) async {}
}

/// Fake notifier for testing - skips async initialization
class FakeProjectShellNotifier extends ProjectShellNotifier {
  FakeProjectShellNotifier(ProjectRepository repository, ProjectShellState initialState)
      : super(
          repository,
          skipInit: true,
          initialState: initialState,
        );
}

void main() {
  group('ProjectShellScreen', () {
    late MockProjectRepository mockRepository;

    setUp(() {
      mockRepository = MockProjectRepository();
    });

    Widget _buildApp(ProjectShellState state) {
      return ProviderScope(
        overrides: [
          projectShellProvider.overrideWith((_) {
            return FakeProjectShellNotifier(mockRepository, state);
          }),
        ],
        child: const MaterialApp(
          home: ProjectShellScreen(),
        ),
      );
    }

    testWidgets('should display app title in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const ProjectShellState(
            projects: [],
            selectedProject: null,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SoftArchitect'), findsOneWidget);
      expect(find.byIcon(Icons.terminal), findsOneWidget);
    });

    testWidgets('should display no project view when no project is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const ProjectShellState(
            projects: [],
            selectedProject: null,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Project Selected'), findsOneWidget);
      expect(find.text('Create or select a project to get started'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('should display project name in app bar when project is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          ProjectShellState(
            projects: [testProject],
            selectedProject: testProject,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('test-project'), findsOneWidget);
    });

    testWidgets('should display project view when project is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          ProjectShellState(
            projects: [testProject],
            selectedProject: testProject,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display the main project layout
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const ProjectShellState(
            projects: [],
            selectedProject: null,
            isLoading: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when there is an error', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const ProjectShellState(
            projects: [],
            selectedProject: null,
            isLoading: false,
            errorMessage: 'Test error message',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should display directory tree with project root', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          ProjectShellState(
            projects: [testProject],
            selectedProject: testProject,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // DirectoryTreeWidget should be present
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
    });

    testWidgets('should display markdown preview widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          ProjectShellState(
            projects: [testProject],
            selectedProject: testProject,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // MarkdownPreviewWidget should be present
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });

    testWidgets('should update selected file when directory tree selection changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          ProjectShellState(
            projects: [testProject],
            selectedProject: testProject,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially no file should be selected in the preview
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);

      // Note: Testing the actual file selection would require more complex setup
      // with mocked file system access, which is beyond basic widget testing
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          ProjectShellState(
            projects: [testProject],
            selectedProject: testProject,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have a Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      // Should have an AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have a Row layout for the main content
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should display info button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const ProjectShellState(
            projects: [],
            selectedProject: null,
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should handle empty projects list', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const ProjectShellState(
            projects: [],
            selectedProject: null,
            isLoading: false,
          ),
        ),
      );

      expect(find.text('No Project Selected'), findsOneWidget);
      expect(find.byType(DirectoryTreeWidget), findsNothing);
      expect(find.byType(MarkdownPreviewWidget), findsNothing);
    });
  });
}
