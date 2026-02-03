// tests/unit/domain/directory_tree_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/directory_tree_use_case.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

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

    test('getVisibleNodes returns correct tree structure', () {
      // Define test tree structure
      final root = FileNode(
        id: 'root',
        name: 'root',
        path: '/',
        isDirectory: true,
        children: [
          FileNode(
            id: 'dir1',
            name: 'dir1',
            path: '/dir1',
            isDirectory: true,
            children: [
              FileNode(
                id: 'file1',
                name: 'file1.md',
                path: '/dir1/file1.md',
                isDirectory: false,
              ),
            ],
          ),
        ],
      );

      final expanded = <String>{'dir1'};
      final visible = DirectoryTreeUseCase.getVisibleNodes(root, expanded);

      expect(visible.length, 3); // root + dir1 + file1
      expect(visible[0].id, 'root');
      expect(visible[1].id, 'dir1');
      expect(visible[2].id, 'file1');
    });
  });
}
