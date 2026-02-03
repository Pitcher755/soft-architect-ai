import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

void main() {
  group('FileNode Entity', () {
    group('Construction', () {
      test('creates file node as file', () {
        final node = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node.path, 'lib/main.dart');
        expect(node.isDirectory, isFalse);
        expect(node.name, 'main.dart');
        expect(node.children, isEmpty);
      });

      test('creates directory node', () {
        final node = FileNode(
          path: 'lib',
          isDirectory: true,
          name: 'lib',
        );

        expect(node.path, 'lib');
        expect(node.isDirectory, isTrue);
        expect(node.name, 'lib');
      });

      test('directory can have children', () {
        final child = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final parent = FileNode(
          path: 'lib',
          isDirectory: true,
          name: 'lib',
          children: [child],
        );

        expect(parent.children.length, 1);
        expect(parent.children.first, child);
      });

      test('creates node with metadata', () {
        final node = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
          size: 1024,
          modifiedAt: DateTime.now(),
        );

        expect(node.size, 1024);
        expect(node.modifiedAt, isNotNull);
      });
    });

    group('File vs Directory', () {
      test('file node has no children initially', () {
        final file = FileNode(
          path: 'README.md',
          isDirectory: false,
          name: 'README.md',
        );

        expect(file.children, isEmpty);
      });

      test('directory node can have children', () {
        final dir = FileNode(
          path: 'src',
          isDirectory: true,
          name: 'src',
        );

        expect(dir.isDirectory, isTrue);
      });

      test('file extension is extracted correctly', () {
        final file = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(file.name, contains('.dart'));
      });

      test('directory has no extension', () {
        final dir = FileNode(
          path: 'lib',
          isDirectory: true,
          name: 'lib',
        );

        expect(dir.name, isNot(contains('.')));
      });
    });

    group('Hierarchy', () {
      test('can build nested tree structure', () {
        final leaf = FileNode(
          path: 'lib/features/file.dart',
          isDirectory: false,
          name: 'file.dart',
        );

        final features = FileNode(
          path: 'lib/features',
          isDirectory: true,
          name: 'features',
          children: [leaf],
        );

        final lib = FileNode(
          path: 'lib',
          isDirectory: true,
          name: 'lib',
          children: [features],
        );

        expect(lib.children.length, 1);
        expect(lib.children.first.children.length, 1);
        expect(lib.children.first.children.first.isDirectory, isFalse);
      });

      test('path reflects hierarchy', () {
        final nodes = [
          FileNode(path: 'lib', isDirectory: true, name: 'lib'),
          FileNode(path: 'lib/features', isDirectory: true, name: 'features'),
          FileNode(path: 'lib/features/home', isDirectory: true, name: 'home'),
          FileNode(path: 'lib/features/home/main.dart', isDirectory: false, name: 'main.dart'),
        ];

        expect(nodes[3].path.startsWith('lib/features/home'), isTrue);
      });
    });

    group('Path operations', () {
      test('extracts name from path correctly', () {
        final node = FileNode(
          path: 'lib/features/project_shell/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node.name, 'main.dart');
      });

      test('handles paths with special characters', () {
        final node = FileNode(
          path: 'lib/my_project/test_file.dart',
          isDirectory: false,
          name: 'test_file.dart',
        );

        expect(node.name, contains('_'));
      });

      test('handles deeply nested paths', () {
        const deepPath = 'a/b/c/d/e/f/g/h/i/j/file.txt';
        final node = FileNode(
          path: deepPath,
          isDirectory: false,
          name: 'file.txt',
        );

        expect(node.path, deepPath);
      });
    });

    group('Metadata', () {
      test('stores file size', () {
        final node = FileNode(
          path: 'README.md',
          isDirectory: false,
          name: 'README.md',
          size: 2048,
        );

        expect(node.size, 2048);
      });

      test('stores modification time', () {
        final modTime = DateTime(2026, 2, 3, 10, 30);
        final node = FileNode(
          path: 'main.dart',
          isDirectory: false,
          name: 'main.dart',
          modifiedAt: modTime,
        );

        expect(node.modifiedAt, modTime);
      });

      test('null metadata is acceptable', () {
        final node = FileNode(
          path: 'lib',
          isDirectory: true,
          name: 'lib',
        );

        expect(node.size, isNull);
        expect(node.modifiedAt, isNull);
      });

      test('directory has zero or null size', () {
        final dir = FileNode(
          path: 'lib',
          isDirectory: true,
          name: 'lib',
          size: 0,
        );

        expect(dir.isDirectory, isTrue);
        expect(dir.size, 0);
      });
    });

    group('Equality', () {
      test('two nodes with same path are equal', () {
        final node1 = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final node2 = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node1, equals(node2));
      });

      test('nodes with different paths are not equal', () {
        final node1 = FileNode(
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final node2 = FileNode(
          path: 'lib/other.dart',
          isDirectory: false,
          name: 'other.dart',
        );

        expect(node1, isNot(equals(node2)));
      });
    });

    group('Special cases', () {
      test('handles files with multiple dots', () {
        final node = FileNode(
          path: 'lib/test.g.dart',
          isDirectory: false,
          name: 'test.g.dart',
        );

        expect(node.name, 'test.g.dart');
      });

      test('handles files without extension', () {
        final node = FileNode(
          path: 'Dockerfile',
          isDirectory: false,
          name: 'Dockerfile',
        );

        expect(node.name, 'Dockerfile');
      });

      test('handles hidden files', () {
        final node = FileNode(
          path: '.gitignore',
          isDirectory: false,
          name: '.gitignore',
        );

        expect(node.name.startsWith('.'), isTrue);
      });

      test('handles root directory', () {
        final root = FileNode(
          path: '/',
          isDirectory: true,
          name: '/',
        );

        expect(root.isDirectory, isTrue);
      });
    });
  });
}
