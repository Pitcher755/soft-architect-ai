import 'package:flutter/foundation.dart';

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
      lastOpened: DateTime.now(),
    ),
    Project(
      id: 'demo-002',
      name: 'Flutter UI Kit',
      path: '/home/demo/Flutter UI Kit',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastOpened: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Project(
      id: 'demo-003',
      name: 'Python FastAPI Backend',
      path: '/home/demo/Python FastAPI Backend',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastOpened: DateTime.now().subtract(const Duration(days: 10)),
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
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Project?> getLastOpenedProject() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _projects.reduce(
        (a, b) => (a.lastOpened ?? DateTime(1970)).isAfter(
          b.lastOpened ?? DateTime(1970),
        )
            ? a
            : b,
      );
    } catch (_) {
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
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _projects.removeWhere((p) => p.id == id);
    debugPrint('✅ Project deleted: $id');
  }
}
