// tests/unit/flutter/domain/directory_tree_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/directory_tree_use_case.dart';

void main() {
  group('DirectoryTreeUseCase', () {
    test('toggleNodeExpanded adds node ID when collapsed', () {
      var expanded = <String>{};
      final nodeId = 'node-123';
      expanded = DirectoryTreeUseCase.toggleNodeExpanded(expanded, nodeId);
      expect(expanded.contains(nodeId), true);
    });

    test('toggleNodeExpanded removes node ID when expanded', () {
      final nodeId = 'node-123';
      var expanded = <String>{nodeId};
      expanded = DirectoryTreeUseCase.toggleNodeExpanded(expanded, nodeId);
      expect(expanded.contains(nodeId), false);
    });

    test('expand/collapse and visible nodes traverse depth-first', () {
      const file = FileNode(
        id: 'f1',
        name: 'a.md',
        path: '/root/dir/a.md',
        isDirectory: false,
      );
      const childDir = FileNode(
        id: 'd1',
        name: 'dir',
        path: '/root/dir',
        isDirectory: true,
        children: [file],
      );
      const root = FileNode(
        id: 'root',
        name: 'root',
        path: '/root',
        isDirectory: true,
        children: [childDir],
      );

      final expanded = DirectoryTreeUseCase.expandNodeRecursively({}, root);
      expect(expanded.contains('root'), isTrue);
      expect(expanded.contains('d1'), isTrue);
      expect(expanded.contains('f1'), isTrue);

      final visible = DirectoryTreeUseCase.getVisibleNodes(root, {
        'root',
        'd1',
      });
      expect(visible.map((n) => n.id).toList(), ['root', 'd1', 'f1']);

      final collapsed = DirectoryTreeUseCase.collapseNode({'root', 'd1'}, 'd1');
      final visibleAfterCollapse = DirectoryTreeUseCase.getVisibleNodes(
        root,
        collapsed,
      );
      expect(visibleAfterCollapse.map((n) => n.id).toList(), ['root', 'd1']);

      expect(DirectoryTreeUseCase.countVisibleNodes(root, {'root', 'd1'}), 3);
      expect(DirectoryTreeUseCase.countVisibleNodes(root, {'root'}), 2);
    });
  });
}
