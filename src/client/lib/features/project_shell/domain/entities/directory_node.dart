/// Represents a node in the directory tree
class DirectoryNode {
  const DirectoryNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
  });

  /// Display name of the node (file or folder name)
  final String name;

  /// Full path to the node
  final String path;

  /// Whether this node is a directory (true) or file (false)
  final bool isDirectory;

  /// Children nodes if this is a directory
  final List<DirectoryNode> children;

  /// Create a copy with modified fields
  DirectoryNode copyWith({
    String? name,
    String? path,
    bool? isDirectory,
    List<DirectoryNode>? children,
  }) => DirectoryNode(
    name: name ?? this.name,
    path: path ?? this.path,
    isDirectory: isDirectory ?? this.isDirectory,
    children: children ?? this.children,
  );

  @override
  String toString() =>
      'DirectoryNode(name: $name, path: $path, isDirectory: $isDirectory, '
      'children: ${children.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryNode &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path &&
          isDirectory == other.isDirectory &&
          children == other.children;

  @override
  int get hashCode => Object.hash(name, path, isDirectory, children);
}
