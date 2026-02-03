// lib/features/project_shell/data/repositories/project_repository_impl.dart
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:crypto/crypto.dart';

import '../../core/exceptions/project_shell_exceptions.dart';
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
    try {
      // 1. Validate name
      ProjectValidationUseCase.validateNameOrThrow(name);

      // 2. Validate path security
      if (path.contains('..') || path.contains('~')) {
        throw PathTraversalException('Path contains suspicious patterns');
      }

      // 3. Create model with deterministic hash ID
      final project = ProjectModel(
        id: _generateId(name, path),
        name: name,
        path: path,
        createdAt: DateTime.now(),
      );

      developer.log('Creating project: ${project.id}', name: 'ProjectRepository');

      // 4. Save to database
      await sqliteDataSource.saveProject(project);

      return project;
    } catch (e) {
      developer.log('Error creating project: $e', name: 'ProjectRepository', error: e);
      rethrow;
    }
  }

  @override
  Future<Project?> getProject(String projectId) =>
      sqliteDataSource.getProject(projectId);

  @override
  Future<List<Project>> getAllProjects() =>
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
  Future<void> updateLastOpened(String projectId) =>
      sqliteDataSource.updateLastOpened(projectId);

  @override
  Future<void> deleteProject(String projectId) =>
      sqliteDataSource.deleteProject(projectId);

  /// Generate deterministic ID from name + path using SHA-256
  String _generateId(String name, String path) {
    final raw = '$name:$path:${DateTime.now().year}';
    final bytes = utf8.encode(raw);
    return 'proj_${sha256.convert(bytes).toString().substring(0, 16)}';
  }
}
