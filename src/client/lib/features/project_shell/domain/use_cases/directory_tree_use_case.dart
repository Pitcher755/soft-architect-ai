// lib/features/project_shell/domain/use_cases/directory_tree_use_case.dart
import '../entities/file_node.dart';

/// Use case: Directory tree operations (expand/collapse, filtering)
class DirectoryTreeUseCase {
  /// Toggle node expansion state (immutable)
  static Set<String> toggleNodeExpanded(Set<String> expanded, String nodeId) {
    final newExpanded = Set<String>.from(expanded);
    newExpanded.contains(nodeId)
        ? newExpanded.remove(nodeId)
        : newExpanded.add(nodeId);
    return newExpanded;
  }

  /// Expand node and all its children recursively
  static Set<String> expandNodeRecursively(
      Set<String> expanded, FileNode node) {
    final newExpanded = Set<String>.from(expanded);
    _addNodeAndChildren(node, newExpanded);
    return newExpanded;
  }

  /// Collapse node (children stay expanded)
  static Set<String> collapseNode(Set<String> expanded, String nodeId) {
    final newExpanded = Set<String>.from(expanded);
    newExpanded.remove(nodeId);
    return newExpanded;
  }

  /// Get visible nodes based on expansion state (depth-first)
  static List<FileNode> getVisibleNodes(
    FileNode root,
    Set<String> expanded,
  ) {
    final visible = <FileNode>[root];
    _addVisibleChildren(root, expanded, visible);
    return visible;
  }

  /// Count total visible nodes for performance tracking
  static int countVisibleNodes(FileNode root, Set<String> expanded) {
    var count = 1; // root
    if (expanded.contains(root.id)) {
      for (final child in root.children) {
        count += countVisibleNodes(child, expanded);
      }
    }
    return count;
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

  static void _addNodeAndChildren(FileNode node, Set<String> expanded) {
    expanded.add(node.id);
    if (node.isDirectory) {
      for (final child in node.children) {
        _addNodeAndChildren(child, expanded);
      }
    }
  }
}
