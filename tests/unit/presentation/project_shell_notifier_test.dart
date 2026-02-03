// tests/unit/presentation/project_shell_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/notifiers/project_shell_notifier.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import '../../test_helper.dart';

void main() {
  group('ProjectShellNotifier', () {
    late MockProjectRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockProjectRepository();
      container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    test('loadProjects fetches and updates state', () async {
      final mockProjects = [
        Project(
          id: 'proj-1',
          name: 'Project 1',
          path: '/proj1',
          createdAt: DateTime(2026, 2, 3),
        ),
      ];

      when(mockRepository.getAllProjects())
          .thenAnswer((_) async => mockProjects);

      final notifier = container.read(projectShellNotifierProvider.notifier);
      await notifier.loadProjects();

      final state = container.read(projectShellNotifierProvider);
      expect(state.projects.length, 1);
      expect(state.projects[0].name, 'Project 1');
    });

    test('createProject creates new project', () async {
      final newProject = Project(
        id: 'proj-new',
        name: 'New Project',
        path: '/new',
        createdAt: DateTime(2026, 2, 3),
      );

      when(mockRepository.createProject(any, any))
          .thenAnswer((_) async => newProject);

      final notifier = container.read(projectShellNotifierProvider.notifier);
      await notifier.createProject('New Project', '/new');

      verify(mockRepository.createProject('New Project', '/new')).called(1);
    });

    test('setSelectedProject updates selected project', () {
      final project = Project(
        id: 'proj-sel',
        name: 'Selected',
        path: '/sel',
        createdAt: DateTime(2026, 2, 3),
      );

      final notifier = container.read(projectShellNotifierProvider.notifier);
      notifier.setSelectedProject(project);

      final state = container.read(projectShellNotifierProvider);
      expect(state.selectedProject?.id, 'proj-sel');
    });

    test('deleteProject removes project from state', () async {
      when(mockRepository.deleteProject('proj-del'))
          .thenAnswer((_) async => {});

      final notifier = container.read(projectShellNotifierProvider.notifier);
      await notifier.deleteProject('proj-del');

      verify(mockRepository.deleteProject('proj-del')).called(1);
    });
  });
}
