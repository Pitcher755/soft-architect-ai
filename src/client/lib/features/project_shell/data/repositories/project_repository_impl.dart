// lib/features/project_shell/data/repositories/project_repository_impl.dart
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/use_cases/project_validation_use_case.dart';
import '../data_sources/sqlite_data_source.dart';
import '../models/project_model.dart';

/// Repository implementation for projects
class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this.sqliteDataSource);
  final SQLiteDataSource sqliteDataSource;

  @override
  Future<Project> createProject(String name, String path) async {
    // 1. Validate name
    ProjectValidationUseCase.validateNameOrThrow(name);

    // 2. Create model
    final project = ProjectModel(
      id: _generateId(),
      name: name,
      path: path,
      createdAt: DateTime.now(),
    );

    // 3. Save to database
    await sqliteDataSource.saveProject(project);

    return project;
  }

  @override
  Future<Project?> getProject(String projectId) async =>
      sqliteDataSource.getProject(projectId);

  @override
  Future<List<Project>> getAllProjects() async =>
      sqliteDataSource.getAllProjects();

  @override
  Future<Project?> getLastOpenedProject() async {
    final projects = await getAllProjects();
    if (projects.isEmpty) return null;

    projects.sort(
      (a, b) =>
          (b.lastOpened ?? DateTime(1)).compareTo(a.lastOpened ?? DateTime(1)),
    );
    return projects.first;
  }

  @override
  Future<void> updateLastOpened(String projectId) async =>
      sqliteDataSource.updateLastOpened(projectId);

  @override
  Future<void> deleteProject(String projectId) async =>
      sqliteDataSource.deleteProject(projectId);

  /// Generate unique ID
  String _generateId() => 'proj_${DateTime.now().millisecondsSinceEpoch}';
}
