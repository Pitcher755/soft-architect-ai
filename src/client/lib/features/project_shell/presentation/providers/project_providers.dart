// lib/features/project_shell/presentation/providers/project_providers.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/database_helper.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_progress.dart';
import '../../domain/models/project_phase.dart';
import '../../domain/services/project_phase_service.dart';
import '../../infrastructure/services/project_progress_service.dart';

// ╔════════════════════════════════════════════════╗
// ║      PROJECTS NOTIFIER (STATE MANAGEMENT)      ║
// ╚════════════════════════════════════════════════╝

/// Notifier for managing the projects list
/// - Loads projects from SharedPreferences (persistence)
/// - Always includes the SoftArchitect mock guide
/// - Allows dynamically adding new projects
class ProjectsNotifier extends Notifier<List<Project>> {
  static const String _storageKey = 'user_projects_v2';

  @override
  List<Project> build() {
    // Iniciar carga asíncrona
    _loadProjects();
    return [];
  }

  /// ✅ CRITICAL FIX: Mark missing projects instead of deleting them
  ///
  /// This allows users to:
  /// 1. See missing projects in the UI (grayed out)
  /// 2. Restore the directory later
  /// 3. Manually delete if desired
  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load projects from SharedPreferences
    final savedJson = prefs.getStringList(_storageKey) ?? [];
    final userProjects = <Project>[];

    for (final str in savedJson) {
      try {
        final Map<String, dynamic> json = jsonDecode(str);
        final projectPath = json['path'] as String;

        // ✅ CRITICAL: Check if directory exists (but DON'T delete)
        final directory = Directory(projectPath);
        final exists = directory.existsSync();

        if (!exists) {
          debugPrint('⚠️ Project directory missing: $projectPath');
        }

        // ✅ Add project with isMissing flag instead of skipping
        userProjects.add(
          Project(
            id: json['id'] as String,
            name: json['name'] as String,
            path: projectPath,
            createdAt: DateTime.parse(json['createdAt'] as String),
            lastOpened: json['lastOpened'] != null
                ? DateTime.parse(json['lastOpened'] as String)
                : null,
            isMissing: !exists, // ✅ Mark as missing, don't delete
          ),
        );
      } on Exception catch (e) {
        debugPrint('❌ Error loading project: $e');
      }
    }

    // 2. Add guide project (always available)
    final guideProject = Project(
      id: 'guide-softarchitect-01',
      name: 'Guía SoftArchitect',
      path: 'mock://softarchitect-guide',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastOpened: DateTime.now(),
    );

    // 3. Combine and sort (most recent first)
    state = [guideProject, ...userProjects]
      ..sort((a, b) {
        final aTime = a.lastOpened ?? a.createdAt;
        final bTime = b.lastOpened ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
  }

  /// Adds a new project to the list and persists it
  Future<void> addProject(String name, String path, String description) async {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      path: path,
      createdAt: DateTime.now(),
      lastOpened: DateTime.now(),
    );

    // Update state (optimistic UI)
    state = [newProject, ...state];

    // Persistir cambios
    await _saveToPrefs();
  }

  /// ✅ NEW: Manually delete a project (user-initiated only)
  ///
  /// This should ONLY be called when user explicitly clicks "Delete" button.
  /// It will:
  /// 1. Remove from UI state
  /// 2. Remove from SharedPreferences
  /// 3. Purge chat history from SQLite
  Future<void> deleteProject(String projectId) async {
    // Remove from state
    state = state.where((p) => p.id != projectId).toList();

    // Persist changes
    await _saveToPrefs();

    // Purge chat history for this project
    await _purgeChatHistory(projectId);

    debugPrint('🗑️ Project deleted: $projectId');
  }

  /// ✅ NEW: Rename a project
  ///
  /// Updates the project name in:
  /// 1. Physical directory (if exists)
  /// 2. UI state (immediate feedback)
  /// 3. SharedPreferences (persistence)
  ///
  /// Throws exception if project not found or name is invalid.
  Future<void> renameProject(String projectId, String newName) async {
    try {
      // Find the project
      final projectIndex = state.indexWhere((p) => p.id == projectId);
      if (projectIndex == -1) {
        throw Exception('Project not found: $projectId');
      }

      final project = state[projectIndex];

      // Protection: Cannot rename guide projects
      if (project.path.startsWith('mock://')) {
        throw Exception('Cannot rename guide projects');
      }

      debugPrint('✏️ Renaming project: ${project.name} -> $newName');

      // Rename physical directory
      var newPath = project.path;
      try {
        final currentDir = Directory(project.path);
        if (currentDir.existsSync()) {
          // Get parent directory
          final parentDir = currentDir.parent.path;
          // Create new path with new name
          newPath = '$parentDir/$newName';

          // Check if target directory already exists
          final newDir = Directory(newPath);
          if (newDir.existsSync()) {
            throw Exception('A directory with name "$newName" already exists');
          }

          // Rename directory
          await currentDir.rename(newPath);
          debugPrint('📁 Directory renamed: ${project.path} -> $newPath');
        } else {
          debugPrint('⚠️ Directory does not exist, only updating state');
        }
      } on FileSystemException catch (e) {
        debugPrint('❌ Error renaming directory: $e');
        throw Exception('Failed to rename project directory: ${e.message}');
      }

      // Update state immutably with new name and path
      final updatedProject = project.copyWith(name: newName, path: newPath);
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == projectIndex) updatedProject else state[i],
      ];

      // Persist changes
      await _saveToPrefs();

      debugPrint('✅ Project renamed successfully');
    } catch (e) {
      debugPrint('❌ Error renaming project: $e');
      rethrow;
    }
  }

  /// ✅ NEW: Restore a missing project (mark as found)
  ///
  /// Call this when user restores the directory or wants to retry.
  Future<void> restoreProject(String projectId) async {
    final project = state.firstWhere((p) => p.id == projectId);
    final directory = Directory(project.path);

    if (directory.existsSync()) {
      // Update state to mark as found
      state = state
          .map((p) => p.id == projectId ? p.copyWith(isMissing: false) : p)
          .toList();

      await _saveToPrefs();
      debugPrint('✅ Project restored: $projectId');
    } else {
      debugPrint('⚠️ Cannot restore, directory still missing: ${project.path}');
    }
  }

  /// Saves real projects to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Solo guardamos proyectos que NO sean mock
    final realProjects = state
        .where((p) => !p.path.startsWith('mock://'))
        .toList();

    final encoded = realProjects
        .map(
          (p) => jsonEncode({
            'id': p.id,
            'name': p.name,
            'path': p.path,
            'createdAt': p.createdAt.toIso8601String(),
            'lastOpened': p.lastOpened?.toIso8601String(),
            'isMissing': p.isMissing, // ✅ NEW: Persist missing flag
          }),
        )
        .toList();

    await prefs.setStringList(_storageKey, encoded);
    debugPrint('✅ Projects saved: ${realProjects.length}');
  }

  /// Purges chat history for a deleted project.
  Future<void> _purgeChatHistory(String projectId) async {
    try {
      final dbHelper = DatabaseHelper();
      final deletedCount = await dbHelper.deleteChatMessagesForProject(
        projectId,
      );
      debugPrint('🗑️ Chat history purged: $deletedCount messages');
    } on Exception catch (e) {
      debugPrint('❌ Error purging chat history: $e');
    }
  }
}

// ╔════════════════════════════════════════════════╗
// ║              PROVIDER DEFINITION                ║
// ╚════════════════════════════════════════════════╝

/// Main provider for the projects list
/// Usage: ref.watch(projectsProvider)
final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  ProjectsNotifier.new,
);

class ProjectProgressNotifier
    extends legacy.StateNotifier<AsyncValue<ProjectPhaseProgress>> {
  ProjectProgressNotifier({
    ProjectPhaseProgress Function(String projectPath)? analyzer,
  }) : _analyzer = analyzer ?? ProjectPhaseService.analyzeProject,
       super(const AsyncLoading());

  final ProjectPhaseProgress Function(String projectPath) _analyzer;

  Future<void> loadProgress(String projectPath) async {
    state = const AsyncLoading();

    try {
      if (projectPath.startsWith('mock://')) {
        state = AsyncData(
          ProjectPhaseProgress(
            currentPhase: 6,
            docsCompleted: ProjectPhase.totalFileCount,
            totalDocs: ProjectPhase.totalFileCount,
            progress: 1,
          ),
        );
        return;
      }

      final progress = _analyzer(projectPath);
      state = AsyncData(progress);
    } on Exception catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final projectProgressProvider =
    legacy.StateNotifierProvider.family<
      ProjectProgressNotifier,
      AsyncValue<ProjectPhaseProgress>,
      String
    >((ref, projectPath) {
      final notifier = ProjectProgressNotifier();
      return notifier..loadProgress(projectPath);
    });

// ╔════════════════════════════════════════════════╗
// ║      PROJECT STATUS PROVIDER (.json FILE)      ║
// ╚════════════════════════════════════════════════╝

/// Provider that reads the .softarchitect/status.json file
///
/// Returns ProjectProgress with the persisted project data:
/// - documentosCreados
/// - faseActual
/// - porcentajeCompletado
/// - lastUpdated
///
/// If the file doesn't exist, returns an initial state with 0%.
///
/// Usage:
/// ```dart
/// final status = ref.watch(projectStatusProvider(projectPath));
/// status.when(
///   data: (progress) => Text('${progress.porcentajeCompletado}%'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error'),
/// );
/// ```
final projectStatusProvider = FutureProvider.family<ProjectProgress, String>((
  ref,
  projectPath,
) async {
  // For mock projects (guide), return a completed state
  if (projectPath.startsWith('mock://')) {
    return ProjectProgress(
      documentosCreados: ProjectPhase.totalFileCount,
      faseActual: 'Proyecto Completado',
      porcentajeCompletado: 100,
      lastUpdated: DateTime.now(),
    );
  }

  // Try to load the status.json file
  final progress = await ProjectProgressService.loadProgress(projectPath);

  // If the file doesn't exist, return initial state
  if (progress == null) {
    return ProjectProgress(
      documentosCreados: 0,
      faseActual: ProjectPhase.root.name,
      porcentajeCompletado: 0,
      lastUpdated: DateTime.now(),
    );
  }

  return progress;
});
