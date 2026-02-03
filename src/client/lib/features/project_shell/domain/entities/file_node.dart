// lib/features/project_shell/domain/entities/file_node.dart

/// Represents a file or directory in project tree
class FileNode {
  final String id;
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;

  const FileNode({
    required this.id,
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
  });

  /// Get depth in tree (root = 0)
  int get depth => path.split('/').length - 1;

  /// Check if this node is expanded (has children to show)
  bool get hasChildren => isDirectory && children.isNotEmpty;

  @override
  String toString() => 'FileNode(id: $id, name: $name, isDir: $isDirectory)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
