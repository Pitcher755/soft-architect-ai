import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';

void main() {
  group('Project Entity', () {
    group('Construction', () {
      test('creates project with all required fields', () {
        final now = DateTime.now();
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        expect(project.id, 'proj_123');
        expect(project.name, 'MyProject');
        expect(project.path, '/home/user/projects/MyProject');
        expect(project.createdAt, now);
        expect(project.lastOpened, isNull);
      });

      test('creates project with lastOpened timestamp', () {
        final created = DateTime(2026, 1, 1);
        final opened = DateTime(2026, 2, 3);

        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: created,
          lastOpened: opened,
        );

        expect(project.lastOpened, opened);
      });
    });

    group('Equality and Hashcode', () {
      test('two projects with same values are equal', () {
        final now = DateTime.now();
        final project1 = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        final project2 = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        expect(project1, equals(project2));
      });

      test('two projects with different ids are not equal', () {
        final now = DateTime.now();
        final project1 = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        final project2 = Project(
          id: 'proj_456',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        expect(project1, isNot(equals(project2)));
      });

      test('projects with same values have same hashcode', () {
        final now = DateTime.now();
        final project1 = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        final project2 = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        expect(project1.hashCode, project2.hashCode);
      });
    });

    group('String representation', () {
      test('toString contains project name', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.toString(), contains('MyProject'));
      });

      test('toString contains project id', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.toString(), contains('proj_123'));
      });

      test('toString is readable', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        final str = project.toString();
        expect(str, isNotEmpty);
        expect(str.length, greaterThan(0));
      });
    });

    group('ID format validation', () {
      test('project id follows expected format', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.id, startsWith('proj_'));
      });
    });

    group('Timestamp validation', () {
      test('createdAt is in the past or present', () {
        final now = DateTime.now();
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: now,
        );

        expect(project.createdAt.isBefore(now.add(Duration(seconds: 1))), isTrue);
      });

      test('lastOpened can be after createdAt', () {
        final created = DateTime(2026, 1, 1);
        final opened = DateTime(2026, 2, 1);

        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: created,
          lastOpened: opened,
        );

        expect(project.lastOpened!.isAfter(project.createdAt), isTrue);
      });
    });

    group('Field constraints', () {
      test('id is not empty', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.id.isEmpty, isFalse);
      });

      test('name is not empty', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.name.isEmpty, isFalse);
      });

      test('path is not empty', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.path.isEmpty, isFalse);
      });

      test('name preserves case sensitivity', () {
        final project1 = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        final project2 = Project(
          id: 'proj_123',
          name: 'myproject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project1.name, isNot(equals(project2.name)));
      });
    });

    group('Path handling', () {
      test('accepts absolute paths', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: '/home/user/projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.path, startsWith('/'));
      });

      test('accepts relative paths', () {
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: 'projects/MyProject',
          createdAt: DateTime.now(),
        );

        expect(project.path, isNotEmpty);
      });

      test('preserves path as-is', () {
        const testPath = '/home/user/Projects/My Project';
        final project = Project(
          id: 'proj_123',
          name: 'MyProject',
          path: testPath,
          createdAt: DateTime.now(),
        );

        expect(project.path, testPath);
      });
    });
  });
}
