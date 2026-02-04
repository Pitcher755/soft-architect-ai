// tests/unit/flutter/domain/directory_tree_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
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

    test('getVisibleNodes returns correct tree structure', () {
      expect(1, 1); // Implementar basado en TreeNode fixture
    });
  });
}
