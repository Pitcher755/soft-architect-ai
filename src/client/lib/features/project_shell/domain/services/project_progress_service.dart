import 'dart:io';

import '../models/project_phase.dart';

/// Service for calculating real project progress.
///
/// Analyzes project files and structure to determine the current
/// phase and number of completed documents.
class ProjectProgressService {
  /// Calculates the number of documents created in a project.
  ///
  /// For mock projects, returns mock data.
  /// For real projects, scans the directory structure.
  static Future<int> calculateDocumentsCreated(String projectPath) async {
    // Mock project: return fixed value
    if (projectPath.startsWith('mock://')) {
      return 12; // Mock value for guide
    }

    // Real project: count markdown files
    try {
      final projectDir = Directory(projectPath);
      if (!await projectDir.exists()) {
        return 0;
      }

      var count = 0;
      await for (final entity in projectDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.md')) {
          count++;
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  /// Gets the current phase name for display.
  ///
  /// Determines phase based on documents created.
  static String getCurrentPhase(int documentsCreated, String projectPath) {
    // Mock project: fixed phase
    if (projectPath.startsWith('mock://')) {
      return 'Guía Completa';
    }

    // Real project: calculate based on progress
    var accumulated = 0;
    for (final phase in ProjectPhase.all) {
      accumulated += phase.fileCount;
      if (documentsCreated < accumulated) {
        return phase.name;
      }
    }

    return ProjectPhase.all.last.name;
  }

  /// Checks if a project path is a mock/guide project.
  static bool isMockProject(String projectPath) =>
      projectPath.startsWith('mock://');
}
