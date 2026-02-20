import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

/// Mock implementation of ProjectRepository for web platform.
///
/// This repository uses in-memory data instead of SQLite,
/// allowing the web version to work without a database.
///
/// On desktop/mobile, the real repository (with SQLite) is used instead.
class WebMockProjectRepository implements ProjectRepository {
  /// Creates a new WebMockProjectRepository instance.
  WebMockProjectRepository() {
    debugPrint('✅ WebMockProjectRepository initialized (web platform)');
  }

  /// In-memory storage for projects
  final List<Project> _projects = [
    Project(
      id: 'demo-001',
      name: 'SoftArchitect AI',
      path: '/home/demo/SoftArchitect AI',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Project(
      id: 'demo-002',
      name: 'Flutter UI Kit',
      path: '/home/demo/Flutter UI Kit',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Project(
      id: 'demo-003',
      name: 'Python FastAPI Backend',
      path: '/home/demo/Python FastAPI Backend',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  @override
  Future<List<Project>> getAllProjects() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_projects);
  }

  @override
  Future<Project?> getProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } on Exception catch (_) {
      return null;
    }
  }

  @override
  Future<Project?> getLastOpenedProject() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _projects.reduce((a, b) {
        final aTime = a.lastOpened ?? a.createdAt;
        final bTime = b.lastOpened ?? b.createdAt;
        return bTime.isAfter(aTime) ? b : a;
      });
    } on Exception catch (_) {
      return null;
    }
  }

  @override
  Future<Project> createProject(String name, String path) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final project = Project(
      id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      path: path,
      createdAt: DateTime.now(),
    );
    _projects.add(project);
    debugPrint('✅ Project created: $name');
    return project;
  }

  @override
  Future<void> updateLastOpened(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index >= 0) {
      _projects[index] = _projects[index].copyWith(lastOpened: DateTime.now());
      debugPrint('✅ Last opened updated: $projectId');
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
      debugPrint('✅ Project updated: ${project.id}');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _projects.removeWhere((p) => p.id == id);
    debugPrint('✅ Project deleted: $id');
  }

  @override
  Future<Project> renameProject(String projectId, String newName) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index < 0) {
      throw Exception('Project not found: $projectId');
    }
    final updatedProject = _projects[index].copyWith(name: newName);
    _projects[index] = updatedProject;
    debugPrint('✅ Project renamed: $projectId -> $newName');
    return updatedProject;
  }
}
