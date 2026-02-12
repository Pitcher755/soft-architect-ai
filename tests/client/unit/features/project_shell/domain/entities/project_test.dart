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
}
