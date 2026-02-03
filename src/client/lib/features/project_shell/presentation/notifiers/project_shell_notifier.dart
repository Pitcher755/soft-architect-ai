// lib/features/project_shell/presentation/notifiers/project_shell_notifier.dart
import 'dart:developer' as developer;

import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

/// State for project shell
class ProjectShellState {
  const ProjectShellState({
    this.projects = const [],
    this.selectedProject,
    this.isLoading = false,
    this.errorMessage,
  });
  final List<Project> projects;
  final Project? selectedProject;
  final bool isLoading;
  final String? errorMessage;

  ProjectShellState copyWith({
    List<Project>? projects,
    Project? selectedProject,
    bool? isLoading,
    String? errorMessage,
  }) =>
      ProjectShellState(
        projects: projects ?? this.projects,
        selectedProject: selectedProject ?? this.selectedProject,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

/// Notifier for project shell state
class ProjectShellNotifier extends StateNotifier<ProjectShellState> {
  ProjectShellNotifier(this.repository) : super(const ProjectShellState()) {
    _init();
  }
  final ProjectRepository repository;

  /// Initialize - load all projects
  Future<void> _init() async {
    developer.log('Initializing ProjectShellNotifier');
    state = state.copyWith(isLoading: true);

    try {
      final projects = await repository.getAllProjects();
      developer.log('Loaded ${projects.length} projects');
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e, st) {
      developer.log('Error loading projects: $e', stackTrace: st);
      state = state.copyWith(
        errorMessage: 'Failed to load projects: $e',
        isLoading: false,
      );
    }
  }

  /// Select project
  Future<void> selectProject(Project project) async {
    developer.log('Selecting project: ${project.id}');
    state = state.copyWith(selectedProject: project);
    // TODO: Update last opened timestamp
  }

  /// Create project
  Future<void> createProject(String name, String path) async {
    developer.log('Creating project: $name at $path');
    try {
      final project = await repository.createProject(name, path);
      state = state.copyWith(
        projects: [...state.projects, project],
        selectedProject: project,
      );
    } catch (e, st) {
      developer.log('Error creating project: $e', stackTrace: st);
      state = state.copyWith(errorMessage: 'Failed to create project: $e');
    }
  }

  /// Delete project
  Future<void> deleteProject(String projectId) async {
    developer.log('Deleting project: $projectId');
    try {
      await repository.deleteProject(projectId);
      final updatedProjects =
          state.projects.where((p) => p.id != projectId).toList();
      final newSelected =
          state.selectedProject?.id == projectId ? null : state.selectedProject;
      state = state.copyWith(
        projects: updatedProjects,
        selectedProject: newSelected,
      );
    } catch (e, st) {
      developer.log('Error deleting project: $e', stackTrace: st);
      state = state.copyWith(errorMessage: 'Failed to delete project: $e');
    }
  }
}
