import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/project_progress.dart';
import '../../domain/models/project_phase.dart';

/// Service for managing project progress persistence
///
/// This service handles creation and updates of `.softarchitect/status.json`
/// file tracking project completion state.
class ProjectProgressService {
  /// Path to the hidden folder containing progress data
  static const String _progressFolderName = '.softarchitect';

  /// Name of the status file
  static const String _statusFileName = 'status.json';

  /// Total number of documents expected across all phases
  static int get _totalDocuments =>
      ProjectPhase.all.fold(0, (sum, phase) => sum + phase.fileCount);

  /// Calculate current progress based on document count in context folder
  ///
  /// Scans the [projectRoot]/context directory recursively and counts
  /// all .md files excluding README.md and untitled documents.
  ///
  /// Returns [ProjectProgress] with updated metrics.
  /// Throws [FileSystemException] if projectRoot doesn't exist.
  static Future<ProjectProgress> calculateProgress(String projectRoot) async {
    final projectDir = Directory(projectRoot);

    if (!projectDir.existsSync()) {
      throw FileSystemException('Project root does not exist', projectRoot);
    }

    // Count markdown files in context/ folder
    final contextPath = p.join(projectRoot, 'context');
    final contextDir = Directory(contextPath);

    var documentCount = 0;

    if (contextDir.existsSync()) {
      await for (final entity in contextDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.md')) {
          final filename = p.basename(entity.path).toLowerCase();
          // Exclude README and untitled documents
          if (!filename.contains('readme') && !filename.contains('untitled')) {
            documentCount++;
          }
        }
      }
    }

    // Determine current phase
    final currentPhase = _determinePhase(documentCount);

    // Calculate completion percentage
    final percentage = _calculatePercentage(documentCount);

    return ProjectProgress(
      documentosCreados: documentCount,
      faseActual: currentPhase,
      porcentajeCompletado: percentage,
      lastUpdated: DateTime.now(),
    );
  }

  /// Persists progress data to `.softarchitect/status.json`
  ///
  /// Creates the hidden folder if it doesn't exist.
  /// Overwrites existing status file with new data.
  ///
  /// Throws [FileSystemException] on write errors.
  static Future<void> saveProgress({
    required String projectRoot,
    required ProjectProgress progress,
  }) async {
    // Create .softarchitect folder if doesn't exist
    final progressDir = Directory(p.join(projectRoot, _progressFolderName));
    if (!progressDir.existsSync()) {
      await progressDir.create(recursive: true);
    }

    // Write status.json
    final statusFile = File(p.join(progressDir.path, _statusFileName));
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(progress.toJson());

    await statusFile.writeAsString(jsonString, flush: true);
  }

  /// Loads progress data from `.softarchitect/status.json`
  ///
  /// Returns [ProjectProgress] if file exists and is valid JSON.
  /// Returns null if file doesn't exist.
  ///
  /// Returns null if file doesn't exist or JSON is malformed.
  static Future<ProjectProgress?> loadProgress(String projectRoot) async {
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
  ///
  /// Recalculates metrics and persists to disk.
  /// This should be called after any document save operation.
  ///
  /// Example:
  /// ```dart
  /// await FileSystemService.saveDocument(...);
  /// await ProjectProgressService.updateAfterDocumentSave(projectRoot);
  /// ```
  static Future<ProjectProgress> updateAfterDocumentSave(
    String projectRoot,
  ) async {
    final progress = await calculateProgress(projectRoot);
    await saveProgress(projectRoot: projectRoot, progress: progress);
    return progress;
  }

  // Private helper methods

  static String _determinePhase(int documentCount) {
    var accumulator = 0;
    for (final phase in ProjectPhase.all) {
      accumulator += phase.fileCount;
      if (documentCount < accumulator) {
        return phase.name;
      }
    }
    return 'Proyecto Completado';
  }

  static double _calculatePercentage(int documentCount) {
    if (_totalDocuments == 0) {
      return 0;
    }
    final percentage = (documentCount / _totalDocuments) * 100;
    return percentage.clamp(0.0, 100.0);
  }
}
