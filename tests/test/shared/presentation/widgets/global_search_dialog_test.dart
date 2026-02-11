import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';
import 'package:softarchitect_ai/features/settings/domain/repositories/i_last_project_repository.dart';
import 'package:softarchitect_ai/features/settings/domain/usecases/load_last_project_usecase.dart';
import 'package:softarchitect_ai/features/settings/domain/usecases/save_last_project_usecase.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';
import 'package:softarchitect_ai/shared/presentation/widgets/global_search_dialog.dart';

void main() {
  Project _createProject() => Project(
    id: 'project-1',
    name: 'Project Alpha',
    path: '/tmp/project-alpha',
    createdAt: DateTime(2026, 2, 10),
    lastOpened: DateTime(2026, 2, 11),
  );

  group('GlobalSearchDialog', () {
    testWidgets('should render search input field', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlobalSearchDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsWidgets,
          reason: 'GlobalSearchDialog should have search TextField');
    });

    testWidgets('should display project results list', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlobalSearchDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget,
          reason: 'Should have ListView for displaying search results');
    });

    testWidgets('should show close button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlobalSearchDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget,
          reason: 'Should have close button to dismiss dialog');
    });

    testWidgets('should show results count text', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlobalSearchDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsWidgets,
          reason: 'Should display results count in text');
    });

    testWidgets(
        'should navigate to project and update last project when card is tapped',
        (WidgetTester tester) async {
      final project = _createProject();
      final fakeRepository = _FakeLastProjectRepository();
      final loadUseCase = LoadLastProjectUseCase(fakeRepository);
      final saveUseCase = SaveLastProjectUseCase(fakeRepository);
      final container = ProviderContainer(
        overrides: [
          projectsProvider.overrideWith(
            () => _TestProjectsNotifier([project]),
          ),
          loadLastProjectUseCaseProvider.overrideWithValue(loadUseCase),
          saveLastProjectUseCaseProvider.overrideWithValue(saveUseCase),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('open_search_dialog'),
                  onPressed: () => GlobalSearchDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/project-shell',
            builder: (context, state) {
              final path = state.uri.queryParameters['path'] ?? '';
              return Scaffold(body: Text('Project Shell: $path'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('open_search_dialog')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(project.name));
      await tester.pumpAndSettle();

      expect(find.byType(GlobalSearchDialog), findsNothing,
          reason: 'Dialog should be dismissed after project selection');
      expect(
        container.read(lastProjectProvider),
        project.path,
        reason: 'Last project path should be updated',
      );
      expect(find.text('Project Shell: ${project.path}'), findsOneWidget,
          reason: 'Should navigate to project shell route');
    });
  });
}

class _TestProjectsNotifier extends ProjectsNotifier {
  _TestProjectsNotifier(this._projects);

  final List<Project> _projects;

  @override
  List<Project> build() => _projects;
}

class _FakeLastProjectRepository implements ILastProjectRepository {
  String? _path;

  @override
  Future<String?> loadLastProjectPath() async => _path;

  @override
  Future<void> saveLastProjectPath(String path) async {
    _path = path;
  }

  @override
  Future<void> clearLastProjectPath() async {
    _path = null;
  }
}
