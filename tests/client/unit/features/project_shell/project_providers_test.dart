// tests/client/unit/features/project_shell/project_providers_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';

void main() {
  group('Project Entity - Missing Flag Tests', () {
    test('Project isMissing defaults to false', () {
      final project = Project(
        id: 'test-123',
        name: 'Test Project',
        path: '/home/user/test',
        createdAt: DateTime.now(),
      );

      expect(project.isMissing, false);
    });

    test('Project can be marked as missing', () {
      final project = Project(
        id: 'missing-123',
        name: 'Missing Project',
        path: '/non/existent',
        createdAt: DateTime.now(),
        isMissing: true,
      );

      expect(project.isMissing, true);
    });

    test('copyWith updates isMissing flag', () {
      final original = Project(
        id: 'copy-123',
        name: 'Copy Project',
        path: '/home/user/copy',
        createdAt: DateTime.now(),
        isMissing: false,
      );

      final marked = original.copyWith(isMissing: true);

      expect(marked.isMissing, true);
      expect(marked.id, original.id);
      expect(marked.name, original.name);
    });

  });
}
