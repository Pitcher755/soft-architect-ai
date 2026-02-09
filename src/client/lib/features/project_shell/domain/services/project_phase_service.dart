import '../../domain/entities/project.dart';
import '../../domain/models/project_phase.dart';

/// Service for managing project phase state and progress calculation.
///
/// Provides methods to determine current phase of a project,
/// calculate progress, and track completed documents.
class ProjectPhaseService {
  /// Determines the current phase of a project.
  ///
  /// For the guide project, always returns [ProjectPhase.quickStart].
  /// For real projects, analyzes the project state to determine phase.
  static ProjectPhase getProjectPhase(Project project) {
    // Special case: Guide project always in quick start
    if (project.id == 'guide-softarchitect-01') {
      return ProjectPhase.quickStart;
    }

    // TODO: Implement real logic based on project files/state
    // For now, return root phase as default for new projects
    return ProjectPhase.root;
  }

  /// Calculates the total progress of a project as a percentage.
  ///
  /// Returns a value between 0.0 and 1.0 representing completion.
  static double calculateProgress(Project project, int documentsCreated) {
    // Guide project doesn't track progress
    if (project.id == 'guide-softarchitect-01') {
      return 1;
    }

    final totalFiles = ProjectPhase.totalFileCount;
    if (totalFiles == 0) return 0;

    return (documentsCreated / totalFiles).clamp(0.0, 1.0);
  }

  /// Gets the current phase name for display.
  static String getCurrentPhaseName(Project project, int documentsCreated) {
    if (project.id == 'guide-softarchitect-01') {
      return 'Quick start';
    }

    // Determine phase based on document count
    var accumulated = 0;
    for (final phase in ProjectPhase.all) {
      accumulated += phase.fileCount;
      if (documentsCreated < accumulated) {
        return phase.name;
      }
    }

    return ProjectPhase.all.last.name;
  }

  /// Gets the number of documents completed in the current phase.
  static int getDocumentsInCurrentPhase(Project project, int documentsCreated) {
    if (project.id == 'guide-softarchitect-01') {
      return 0;
    }

    var accumulated = 0;
    for (final phase in ProjectPhase.all) {
      final phaseStart = accumulated;
      accumulated += phase.fileCount;

      if (documentsCreated < accumulated) {
        return documentsCreated - phaseStart;
      }
    }

    return 0;
  }

  /// Checks if a project is the guide project.
  static bool isGuideProject(Project project) =>
      project.id == 'guide-softarchitect-01';
}
