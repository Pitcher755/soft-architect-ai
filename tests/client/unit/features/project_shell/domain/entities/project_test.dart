import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';

void main() {
  group('Project entity', () {
    test('displayName returns last path segment', () {
      final project = Project(
        id: 'p1',
        name: 'FallbackName',
        path: '/home/user/workspace/my-project',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(project.displayName, 'my-project');
    });

    test('phase detects architecture segment', () {
      final project = Project(
        id: 'p2',
        name: 'Arch',
        path: '/tmp/arquitectura/demo',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(project.phase, 'Arquitectura');
    });

    test('phase detects implementation segment', () {
      final project = Project(
        id: 'p3',
        name: 'Impl',
        path: '/tmp/desarrollo/demo',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(project.phase, 'Implementación');
    });

    test('phase detects quality and docs segments', () {
      final quality = Project(
        id: 'p4',
        name: 'QA',
        path: '/tmp/calidad/demo',
        createdAt: DateTime(2026, 1, 1),
      );
      final docs = Project(
        id: 'p5',
        name: 'Docs',
        path: '/tmp/doc/demo',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(quality.phase, 'Calidad');
      expect(docs.phase, 'Documentación');
    });

    test('phase defaults to Contexto for unknown paths', () {
      final project = Project(
        id: 'p6',
        name: 'Unknown',
        path: '/tmp/misc/demo',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(project.phase, 'Contexto');
    });

    test('isRecentlyAccessed reflects recency threshold', () {
      final recent = Project(
        id: 'p7',
        name: 'Recent',
        path: '/tmp/recent',
        createdAt: DateTime(2026, 1, 1),
        lastOpened: DateTime.now().subtract(const Duration(days: 5)),
      );
      final old = Project(
        id: 'p8',
        name: 'Old',
        path: '/tmp/old',
        createdAt: DateTime(2026, 1, 1),
        lastOpened: DateTime.now().subtract(const Duration(days: 45)),
      );
      final neverOpened = Project(
        id: 'p9',
        name: 'Never',
        path: '/tmp/never',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(recent.isRecentlyAccessed, isTrue);
      expect(old.isRecentlyAccessed, isFalse);
      expect(neverOpened.isRecentlyAccessed, isFalse);
    });

    test('copyWith updates selected fields and keeps others', () {
      final original = Project(
        id: 'p10',
        name: 'Original',
        path: '/tmp/original',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(name: 'Updated', path: '/tmp/updated');

      expect(updated.id, original.id);
      expect(updated.createdAt, original.createdAt);
      expect(updated.name, 'Updated');
      expect(updated.path, '/tmp/updated');
    });

    test('toString, equality and hashCode are consistent', () {
      final a = Project(
        id: 'same',
        name: 'Name',
        path: '/tmp/path',
        createdAt: DateTime(2026, 1, 1),
      );
      final b = Project(
        id: 'same',
        name: 'Name',
        path: '/tmp/path',
        createdAt: DateTime(2026, 1, 2),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('Project(id: same'));
    });
  });

  group('Project Entity - isMissing Field', () {
    final baseTimestamp = DateTime(2024, 1, 1, 12, 0, 0);

    test('isMissing defaults to false if not specified', () {
      // ACT: Create project without isMissing parameter
      final project = Project(
        id: 'test-id',
        name: 'Test Project',
        path: '/home/user/test',
        createdAt: baseTimestamp,
      );

      // ASSERT: isMissing should default to false
      expect(project.isMissing, false);
    });

    test('isMissing can be explicitly set to true', () {
      // ACT: Create project with isMissing=true
      final project = Project(
        id: 'missing-id',
        name: 'Missing Project',
        path: '/non/existent/path',
        createdAt: baseTimestamp,
        isMissing: true,
      );

      // ASSERT: isMissing should be true
      expect(project.isMissing, true);
    });

    test('isMissing can be explicitly set to false', () {
      // ACT: Create project with isMissing=false
      final project = Project(
        id: 'existing-id',
        name: 'Existing Project',
        path: '/home/user/existing',
        createdAt: baseTimestamp,
        isMissing: false,
      );

      // ASSERT: isMissing should be false
      expect(project.isMissing, false);
    });

    test('copyWith() preserves isMissing flag when not updated', () {
      // ARRANGE: Create project with isMissing=true
      final original = Project(
        id: 'original-id',
        name: 'Original Name',
        path: '/original/path',
        createdAt: baseTimestamp,
        isMissing: true,
      );

      // ACT: Copy with different name but don't specify isMissing
      final copied = original.copyWith(name: 'Updated Name');

      // ASSERT: isMissing should be preserved
      expect(copied.isMissing, true);
      expect(copied.name, 'Updated Name');
      expect(copied.id, 'original-id');
    });

    test('copyWith() can update isMissing flag to true', () {
      // ARRANGE: Create project with isMissing=false
      final original = Project(
        id: 'update-id',
        name: 'Update Project',
        path: '/update/path',
        createdAt: baseTimestamp,
        isMissing: false,
      );

      // ACT: Mark as missing using copyWith
      final marked = original.copyWith(isMissing: true);

      // ASSERT: isMissing should be updated
      expect(marked.isMissing, true);
      expect(marked.id, 'update-id');
      expect(marked.name, 'Update Project');
    });

    test('copyWith() can update isMissing flag to false', () {
      // ARRANGE: Create project with isMissing=true
      final missing = Project(
        id: 'restore-id',
        name: 'Restore Project',
        path: '/restore/path',
        createdAt: baseTimestamp,
        isMissing: true,
      );

      // ACT: Restore using copyWith
      final restored = missing.copyWith(isMissing: false);

      // ASSERT: isMissing should be updated to false
      expect(restored.isMissing, false);
      expect(restored.id, 'restore-id');
      expect(restored.name, 'Restore Project');
    });
  });
}
