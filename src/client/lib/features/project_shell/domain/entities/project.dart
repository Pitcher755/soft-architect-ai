// lib/features/project_shell/domain/entities/project.dart

/// Core project entity - represents a SoftArchitect project
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.lastOpened,
  });
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime? lastOpened;

  /// Get project directory name for display
  String get displayName =>
      path.split('/').last.isEmpty ? name : path.split('/').last;

  /// Check if project was recently accessed (last 30 days)
  bool get isRecentlyAccessed {
    if (lastOpened == null) return false;
    return DateTime.now().difference(lastOpened!).inDays <= 30;
  }

  /// Create copy with optional field overrides
  Project copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
    DateTime? lastOpened,
  }) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        path: path ?? this.path,
        createdAt: createdAt ?? this.createdAt,
        lastOpened: lastOpened ?? this.lastOpened,
      );

  @override
  String toString() =>
      'Project(id: $id, name: $name, path: $path, recent: $isRecentlyAccessed)';

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
