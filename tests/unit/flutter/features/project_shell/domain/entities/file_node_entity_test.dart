import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

void main() {
  group('FileNode Entity', () {
    group('Construction', () {
      test('creates file node as file', () {
        final node = FileNode(
          id: 'file-1',
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
          id: 'dir-1',
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
          id: 'file-2',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final parent = FileNode(
          id: 'dir-2',
          path: 'lib',
          isDirectory: true,
          name: 'lib',
          children: [child],
        );

        expect(parent.children.length, 1);
        expect(parent.children.first, child);
      });
    });

    group('File vs Directory', () {
      test('file node has no children initially', () {
        final file = FileNode(
          id: 'file-3',
          path: 'README.md',
          isDirectory: false,
          name: 'README.md',
        );

        expect(file.children, isEmpty);
      });

      test('directory node can have children', () {
        final dir = FileNode(
          id: 'dir-3',
          path: 'src',
          isDirectory: true,
          name: 'src',
        );

        expect(dir.isDirectory, isTrue);
      });

      test('file extension is extracted correctly', () {
        final file = FileNode(
          id: 'file-4',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(file.extension, 'dart');
      });

      test('directory has no extension', () {
        final dir = FileNode(
          id: 'dir-4',
          path: 'lib',
          isDirectory: true,
          name: 'lib',
        );

        expect(dir.extension, isEmpty);
      });
    });

    group('Hierarchy', () {
      test('can build nested tree structure', () {
        final leaf = FileNode(
          id: 'file-5',
          path: 'lib/features/file.dart',
          isDirectory: false,
          name: 'file.dart',
        );

        final features = FileNode(
          id: 'dir-5',
          path: 'lib/features',
          isDirectory: true,
          name: 'features',
          children: [leaf],
        );

        final lib = FileNode(
          id: 'dir-6',
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
          FileNode(id: 'dir-7', path: 'lib', isDirectory: true, name: 'lib'),
          FileNode(
            id: 'dir-8',
            path: 'lib/features',
            isDirectory: true,
            name: 'features',
          ),
          FileNode(
            id: 'dir-9',
            path: 'lib/features/home',
            isDirectory: true,
            name: 'home',
          ),
          FileNode(
            id: 'file-6',
            path: 'lib/features/home/main.dart',
            isDirectory: false,
            name: 'main.dart',
          ),
        ];

        expect(nodes[3].path.startsWith('lib/features/home'), isTrue);
      });

      test('depth is calculated correctly', () {
        final root = FileNode(
          id: 'dir-10',
          path: 'lib',
          isDirectory: true,
          name: 'lib',
        );
        final child = FileNode(
          id: 'dir-11',
          path: 'lib/features',
          isDirectory: true,
          name: 'features',
        );
        final grandchild = FileNode(
          id: 'file-7',
          path: 'lib/features/home/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(root.depth, 1);
        expect(child.depth, 2);
        expect(grandchild.depth, 3);
      });
    });

    group('Path operations', () {
      test('extracts name from path correctly', () {
        final node = FileNode(
          id: 'file-8',
          path: 'lib/features/project_shell/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node.name, 'main.dart');
      });

      test('handles paths with special characters', () {
        final node = FileNode(
          id: 'file-9',
          path: 'lib/my_project/test_file.dart',
          isDirectory: false,
          name: 'test_file.dart',
        );

        expect(node.name, contains('_'));
      });

      test('handles deeply nested paths', () {
        const deepPath = 'a/b/c/d/e/f/g/h/i/j/file.txt';
        final node = FileNode(
          id: 'file-10',
          path: deepPath,
          isDirectory: false,
          name: 'file.txt',
        );

        expect(node.path, deepPath);
      });

      test('parent path is calculated correctly', () {
        final node = FileNode(
          id: 'file-11',
          path: 'lib/features/project_shell/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node.parentPath, 'lib/features/project_shell');
      });
    });

    group('Properties', () {
      test('hasChildren returns true for directory with children', () {
        final child = FileNode(
          id: 'file-12',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final parent = FileNode(
          id: 'dir-12',
          path: 'lib',
          isDirectory: true,
          name: 'lib',
          children: [child],
        );

        expect(parent.hasChildren, isTrue);
      });

      test('hasChildren returns false for directory without children', () {
        final dir = FileNode(
          id: 'dir-13',
          path: 'lib',
          isDirectory: true,
          name: 'lib',
        );

        expect(dir.hasChildren, isFalse);
      });

      test('isHidden detects hidden files', () {
        final hidden = FileNode(
          id: 'file-13',
          path: '.gitignore',
          isDirectory: false,
          name: '.gitignore',
        );

        expect(hidden.isHidden, isTrue);
      });

      test('isHidden returns false for normal files', () {
        final normal = FileNode(
          id: 'file-14',
          path: 'README.md',
          isDirectory: false,
          name: 'README.md',
        );

        expect(normal.isHidden, isFalse);
      });
    });

    group('Equality', () {
      test('two nodes with same id are equal', () {
        final node1 = FileNode(
          id: 'node-1',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final node2 = FileNode(
          id: 'node-1',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node1, equals(node2));
      });

      test('nodes with different ids are not equal', () {
        final node1 = FileNode(
          id: 'node-1',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final node2 = FileNode(
          id: 'node-2',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        expect(node1, isNot(equals(node2)));
      });

      test('equality is based on id only', () {
        final node1 = FileNode(
          id: 'same-id',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final node2 = FileNode(
          id: 'same-id',
          path: 'different/path.dart',
          isDirectory: true,
          name: 'different.dart',
        );

        expect(node1, equals(node2));
      });
    });

    group('String representation', () {
      test('toString includes id, name, and directory status', () {
        final node = FileNode(
          id: 'test-id',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final str = node.toString();
        expect(str, contains('test-id'));
        expect(str, contains('main.dart'));
        expect(str, contains('isDir: false'));
      });
    });

    group('Special cases', () {
      test('handles files with multiple dots', () {
        final node = FileNode(
          id: 'file-15',
          path: 'lib/test.g.dart',
          isDirectory: false,
          name: 'test.g.dart',
        );

        expect(node.name, 'test.g.dart');
        expect(node.extension, 'dart');
      });

      test('handles files without extension', () {
        final node = FileNode(
          id: 'file-16',
          path: 'Dockerfile',
          isDirectory: false,
          name: 'Dockerfile',
        );

        expect(node.name, 'Dockerfile');
        expect(node.extension, 'Dockerfile');
      });

      test('handles hidden files', () {
        final node = FileNode(
          id: 'file-17',
          path: '.gitignore',
          isDirectory: false,
          name: '.gitignore',
        );

        expect(node.name.startsWith('.'), isTrue);
        expect(node.isHidden, isTrue);
      });

      test('handles root directory', () {
        final root = FileNode(
          id: 'root',
          path: '/',
          isDirectory: true,
          name: '/',
        );

        expect(root.isDirectory, isTrue);
        expect(root.path, '/');
      });

      test('hashCode is based on id', () {
        final node1 = FileNode(
          id: 'same-id',
          path: 'lib/main.dart',
          isDirectory: false,
          name: 'main.dart',
        );

        final node2 = FileNode(
          id: 'same-id',
          path: 'different/path.dart',
          isDirectory: true,
          name: 'different.dart',
        );

        expect(node1.hashCode, equals(node2.hashCode));
      });
    });
  });
}
