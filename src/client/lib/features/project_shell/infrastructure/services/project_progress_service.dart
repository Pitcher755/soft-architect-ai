import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/project_progress.dart';
import '../../domain/models/project_phase.dart';

/// Service for managing project progress persistence
/// Merged version: handles both real filesystem scanning and mock projects.
class ProjectProgressService {
  static const String _progressFolderName = '.softarchitect';
  static const String _statusFileName = 'status.json';

  static int get _totalDocuments =>
      ProjectPhase.all.fold(0, (sum, phase) => sum + phase.fileCount);

  // --- MÉTODOS DE LA VERSIÓN 2 (Comprobaciones dinámicas y Mocks) ---

  /// Checks if a project path is a mock/guide project.
  static bool isMockProject(String projectPath) =>
      projectPath.startsWith('mock://');

  /// Calculates the number of documents created in a project.
  static Future<int> calculateDocumentsCreated(String projectPath) async {
    if (isMockProject(projectPath)) {
      return 12;
    }

    try {
      final contextDir = Directory(p.join(projectPath, 'context'));
      if (!contextDir.existsSync()) {
        return 0;
      }

      var count = 0;
      await for (final entity in contextDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          // 🎯 FIX: Ahora permitimos tanto .md como .json
          // para que el paso 5 cuente
          if (path.endsWith('.md') || path.endsWith('.json')) {
            final filename = p.basename(path);
            if (!filename.contains('readme') &&
                !filename.contains('untitled')) {
              count++;
            }
          }
        }
      }
      return count;
    } on FileSystemException {
      return 0;
    } on Exception {
      return 0;
    }
  }

  /// Gets the current phase name for display.
  static String getCurrentPhase(int documentsCreated, String projectPath) {
    if (isMockProject(projectPath)) {
      return 'Guía Completa';
    }

    var accumulated = 0;
    for (final phase in ProjectPhase.all) {
      accumulated += phase.fileCount;
      if (documentsCreated < accumulated) {
        return phase.name;
      }
    }
    return ProjectPhase.all.last.name;
  }

  // --- MÉTODOS DE LA VERSIÓN 1 (Persistencia en status.json) ---

  /// Calculate current progress based on document count in context folder
  static Future<ProjectProgress> calculateProgress(String projectRoot) async {
    if (isMockProject(projectRoot)) {
      return ProjectProgress(
        documentosCreados: 12,
        faseActual: 'Guía Completa',
        porcentajeCompletado: 50,
        lastUpdated: DateTime.now(),
      );
    }

    final projectDir = Directory(projectRoot);
    if (!projectDir.existsSync()) {
      throw FileSystemException('Project root does not exist', projectRoot);
    }

    final documentCount = await calculateDocumentsCreated(projectRoot);
    final currentPhase = getCurrentPhase(documentCount, projectRoot);
    final percentage = _calculatePercentage(documentCount);

    return ProjectProgress(
      documentosCreados: documentCount,
      faseActual: currentPhase,
      porcentajeCompletado: percentage,
      lastUpdated: DateTime.now(),
    );
  }

  /// Persists progress data to `.softarchitect/status.json`
  static Future<void> saveProgress({
    required String projectRoot,
    required ProjectProgress progress,
  }) async {
    if (isMockProject(projectRoot)) {
      return;
    }

    final progressDir = Directory(p.join(projectRoot, _progressFolderName));
    if (!progressDir.existsSync()) {
      await progressDir.create(recursive: true);
    }

    final statusFile = File(p.join(progressDir.path, _statusFileName));
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(progress.toJson());

    await statusFile.writeAsString(jsonString, flush: true);
  }

  /// Loads progress data from `.softarchitect/status.json`
  static Future<ProjectProgress?> loadProgress(String projectRoot) async {
    if (isMockProject(projectRoot)) {
      return null;
    }

    final statusFile = File(
      p.join(projectRoot, _progressFolderName, _statusFileName),
    );

    if (!statusFile.existsSync()) {
      return null;
    }

    try {
      final jsonString = await statusFile.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProjectProgress.fromJson(json);
    } on FormatException catch (e) {
      debugPrint('⚠️ Error parsing progress JSON: $e');
      return null;
    }
  }

  /// Updates progress after a new document is saved
  static Future<ProjectProgress> updateAfterDocumentSave(
    String projectRoot,
  ) async {
    if (isMockProject(projectRoot)) {
      return calculateProgress(projectRoot);
    }
    final progress = await calculateProgress(projectRoot);
    await saveProgress(projectRoot: projectRoot, progress: progress);
    return progress;
  }

  static double _calculatePercentage(int documentCount) {
    if (_totalDocuments == 0) {
      return 0;
    }
    final percentage = (documentCount / _totalDocuments) * 100;
    return percentage.clamp(0.0, 100.0);
  }
}
