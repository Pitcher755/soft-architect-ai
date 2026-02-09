// lib/features/project_shell/data/models/project_model.dart
import '../../domain/entities/project.dart';

/// DTO for Project (database/network transfer)
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.path,
    required super.createdAt,
    super.lastOpened,
  });

  /// Convert from JSON (from database)
  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'] as String,
    name: json['name'] as String,
    path: json['path'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastOpened: json['lastOpened'] != null
        ? DateTime.parse(json['lastOpened'] as String)
        : null,
  );

  /// Convert to JSON (for database)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
    'lastOpened': lastOpened?.toIso8601String(),
  };
}
