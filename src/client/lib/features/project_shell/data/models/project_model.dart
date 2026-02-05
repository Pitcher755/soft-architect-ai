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
    createdAt: DateTime.parse(json['created_at'] as String),
    lastOpened: json['last_opened'] != null
        ? DateTime.parse(json['last_opened'] as String)
        : null,
  );

  /// Convert to JSON (for database)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'created_at': createdAt.toIso8601String(),
    'last_opened': lastOpened?.toIso8601String(),
  };
}
