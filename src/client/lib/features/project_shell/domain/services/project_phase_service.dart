// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:io';

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
  /// For real projects, analyzes the project directory structure to determine phase.
  ///
  /// Phase detection logic:
  /// - Root: Only base files present
  /// - Context: context/ directory exists
  /// - Requirements: doc/20-REQUIREMENTS_AND_SPEC/ exists
  /// - Architecture: doc/30-ARCHITECTURE/ or src/ exists
  /// - UI/UX: UI design files detected
  /// - Planning: doc/40-ROADMAP/ or infrastructure/ exists
  /// - Meta: tests/, .github/ or advanced project structure
  static ProjectPhase getProjectPhase(Project project) {
    // Special case: Guide project always in quick start
    if (project.id == 'guide-softarchitect-01') {
      return ProjectPhase.quickStart;
    }

    try {
      final projectDir = Directory(project.path);
      if (!projectDir.existsSync()) {
        return ProjectPhase.root;
      }

      // Check for key indicators of different phases
      final hasContext =
          Directory('${project.path}/context').existsSync();
      final hasRequirements =
          Directory('${project.path}/doc/20-REQUIREMENTS_AND_SPEC')
              .existsSync() ||
          Directory('${project.path}/doc/20-*').listSync().isNotEmpty;
      final hasArchitecture =
          Directory('${project.path}/doc/30-ARCHITECTURE').existsSync() ||
          Directory('${project.path}/doc/30-*').listSync().isNotEmpty ||
          Directory('${project.path}/src').existsSync();
      final hasInfrastructure =
          Directory('${project.path}/infrastructure').existsSync() ||
          Directory('${project.path}/doc/40-ROADMAP').existsSync() ||
          Directory('${project.path}/doc/40-*').listSync().isNotEmpty;
      final hasTests =
          Directory('${project.path}/tests').existsSync() ||
          Directory('${project.path}/test').existsSync();
      final hasCI =
          Directory('${project.path}/.github').existsSync();

      // Return the most advanced phase detected
      if (hasCI || (hasTests && hasInfrastructure)) {
        return ProjectPhase.meta;
      }
      if (hasInfrastructure || hasTests) {
        return ProjectPhase.planning;
      }
      if (hasArchitecture) {
        return ProjectPhase.architecture;
      }
      if (hasRequirements) {
        return ProjectPhase.requirements;
      }
      if (hasContext) {
        return ProjectPhase.context;
      }

      // Default to root if no specific indicators found
      return ProjectPhase.root;
    } catch (e) {
      // If error reading directory, default to root
      return ProjectPhase.root;
    }
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
