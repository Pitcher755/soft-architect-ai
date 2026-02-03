// lib/features/project_shell/domain/entities/project.dart

/// Core project entity - represents a SoftArchitect project
class Project {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime? lastOpened;

  const Project({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.lastOpened,
  });

  /// Create copy with optional field overrides
  Project copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
    DateTime? lastOpened,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      lastOpened: lastOpened ?? this.lastOpened,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name, path: $path)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          path == other.path;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ path.hashCode;
}
