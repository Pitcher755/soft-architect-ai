// tests/unit/presentation/project_shell_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/notifiers/project_shell_notifier.dart';

import '../../test_helper.dart';

void main() {
  group('ProjectShellNotifier', () {
    late MockProjectRepository mockRepo;
    late ProjectShellNotifier notifier;

    setUp(() {
      mockRepo = MockProjectRepository();
      notifier = ProjectShellNotifier(mockRepo);
    });

    test('selectProject updates state', () async {
      final project = Project(
        id: '1',
        name: 'proj',
        path: '/p',
        createdAt: DateTime.now(),
      );
      when(mockRepo.updateLastOpened('1')).thenAnswer((_) async => {});

      await notifier.selectProject(project);

      expect(notifier.state.selectedProject?.id, '1');
    });
  });
}
