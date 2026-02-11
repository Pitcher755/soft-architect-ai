// lib/features/project_shell/domain/repositories/project_repository.dart
import '../entities/project.dart';

/// Repository interface for project operations
abstract class ProjectRepository {
  /// Create new project
  Future<Project> createProject(String name, String path);

  /// Get project by ID
  Future<Project?> getProject(String projectId);

  /// Get all projects
  Future<List<Project>> getAllProjects();

  /// Get last opened project
  Future<Project?> getLastOpenedProject();

  /// Update a project
  Future<void> updateProject(Project project);

  /// Update last opened timestamp
  Future<void> updateLastOpened(String projectId);

  /// Delete project
  Future<void> deleteProject(String projectId);
}
