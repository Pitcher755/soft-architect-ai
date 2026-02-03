// lib/features/project_shell/domain/entities/project.dart

/// Core project entity - represents a SoftArchitect project.
///
/// A project is the main container for organizing architectural analysis,
/// consisting of a directory structure, configuration files, and related documents.
///
/// **Properties:**
/// - [id]: Unique identifier (format: proj_<timestamp>)
/// - [name]: User-friendly project name (3-50 alphanumeric chars)
/// - [path]: Absolute filesystem path to project root
/// - [createdAt]: Project creation timestamp
/// - [lastOpened]: Last access timestamp (nullable)
///
/// **Example:**
/// ```dart
/// final project = Project(
///   id: 'proj_1234567890',
///   name: 'my-architecture',
///   path: '/home/user/SoftArchitect/projects/my-architecture',
///   createdAt: DateTime.now(),
/// );
/// ```
class Project {
  /// Unique project identifier
  final String id;

  /// User-friendly project name (validated: [a-zA-Z0-9_-]{3,50})
  final String name;

  /// Absolute filesystem path to project root directory
  final String path;

  /// Project creation timestamp
  final DateTime createdAt;

  /// Last time project was opened (nullable if never opened)
  final DateTime? lastOpened;

  const Project({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.lastOpened,
  });

  /// Get project directory name for display purposes
  ///
  /// Returns the last path component if available, otherwise the name.
  String get displayName =>
      path.split('/').last.isEmpty ? name : path.split('/').last;

  /// Check if project was recently accessed (within last 30 days)
  ///
  /// Returns `true` if [lastOpened] is within 30 days, `false` otherwise.
  bool get isRecentlyAccessed {
    if (lastOpened == null) return false;
    return DateTime.now().difference(lastOpened!).inDays <= 30;
  }

  /// Create copy with optional field overrides
  ///
  /// Useful for immutable updates:
  /// ```dart
  /// final updated = project.copyWith(lastOpened: DateTime.now());
  /// ```
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
