// lib/features/project_shell/domain/entities/file_node.dart

/// Represents a file or directory in project tree
class FileNode {
  const FileNode({
    required this.id,
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
  });
  final String id;
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;

  /// Get depth in tree (root = 1)
  int get depth {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (!isDirectory && parts.isNotEmpty) {
      return parts.length - 1; // exclude file name for files
    }
    return parts.length;
  }

  /// Check if this node is expanded (has children to show)
  bool get hasChildren => isDirectory && children.isNotEmpty;

  /// Get file extension (empty for directories)
  String get extension => isDirectory ? '' : name.split('.').last;

  /// Get parent path
  String get parentPath {
    final parts = path.split('/');
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Check if this is a hidden file (starts with dot)
  bool get isHidden => name.startsWith('.');

  @override
  String toString() =>
      'FileNode(id: $id, name: $name, isDir: $isDirectory, depth: $depth)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
