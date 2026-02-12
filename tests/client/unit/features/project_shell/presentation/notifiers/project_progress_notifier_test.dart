// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/services/project_phase_service.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';

void main() {
  group('ProjectProgressNotifier', () {
    test('starts in loading and transitions to data with analyzer result', () async {
      final notifier = ProjectProgressNotifier(
        analyzer: (_) => const ProjectPhaseProgress(
          currentPhase: 2,
          docsCompleted: 9,
          totalDocs: 25,
          progress: 0.36,
        ),
      );

      expect(notifier.state, isA<AsyncLoading<ProjectPhaseProgress>>());

      await notifier.loadProgress('/tmp/project');

      final state = notifier.state;
      expect(state, isA<AsyncData<ProjectPhaseProgress>>());
      expect(state.value?.currentPhase, 2);
      expect(state.value?.docsCompleted, 9);
      expect(state.value?.progress, closeTo(0.36, 0.0001));
    });

    test('returns fully completed state for mock project paths', () async {
      final notifier = ProjectProgressNotifier();

      await notifier.loadProgress('mock://softarchitect-guide');

      final state = notifier.state;
      expect(state, isA<AsyncData<ProjectPhaseProgress>>());
      expect(state.value?.currentPhase, 6);
      expect(state.value?.docsCompleted, 25);
      expect(state.value?.progress, 1);
    });

    test('captures analyzer errors as AsyncError', () async {
      final notifier = ProjectProgressNotifier(
        analyzer: (_) => throw Exception('boom'),
      );

      await notifier.loadProgress('/tmp/project');

      expect(notifier.state, isA<AsyncError<ProjectPhaseProgress>>());
    });
  });
}
