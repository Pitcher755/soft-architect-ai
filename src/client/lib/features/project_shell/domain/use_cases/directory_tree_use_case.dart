// lib/features/project_shell/domain/use_cases/directory_tree_use_case.dart
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

/// Use case: Directory tree operations (expand/collapse, filtering)
class DirectoryTreeUseCase {
  /// Toggle node expansion state
  static Set<String> toggleNodeExpanded(Set<String> expanded, String nodeId) {
    final newExpanded = Set<String>.from(expanded);
    if (newExpanded.contains(nodeId)) {
      newExpanded.remove(nodeId);
    } else {
      newExpanded.add(nodeId);
    }
    return newExpanded;
  }

  /// Get visible nodes based on expansion state
  static List<FileNode> getVisibleNodes(
    FileNode root,
    Set<String> expanded,
  ) {
    final visible = <FileNode>[root];
    _addVisibleChildren(root, expanded, visible);
    return visible;
  }

  static void _addVisibleChildren(
    FileNode node,
    Set<String> expanded,
    List<FileNode> visible,
  ) {
    if (!expanded.contains(node.id)) return;

    for (final child in node.children) {
      visible.add(child);
      if (child.isDirectory) {
        _addVisibleChildren(child, expanded, visible);
      }
    }
  }
}
