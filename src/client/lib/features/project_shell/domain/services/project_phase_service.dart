import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/constants/project_structure_constants.dart';
import '../../core/security/path_validator.dart';
import '../../domain/entities/project.dart';
import '../../domain/models/project_phase.dart';

class ProjectPhaseProgress {
  const ProjectPhaseProgress({
    required this.currentPhase,
    required this.docsCompleted,
    required this.totalDocs,
    required this.progress,
  });

  final int currentPhase;
  final int docsCompleted;
  final int totalDocs;
  final double progress;
}

typedef ProjectFileScanner = List<String> Function(String projectPath);

class LocalProjectFileScanner {
  const LocalProjectFileScanner();

  List<String> getProjectFiles(String projectPath) {
    try {
      final root = Directory(projectPath);
      if (!root.existsSync()) {
        return const [];
      }

      final normalizedRootPath = ProjectPhaseService.normalizePath(projectPath);

      return root
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .map((file) {
            final normalizedFilePath = ProjectPhaseService.normalizePath(
              file.path,
            );
            if (!normalizedFilePath.startsWith('$normalizedRootPath/')) {
              return '';
            }

            final relativePath = p.relative(
              normalizedFilePath,
              from: normalizedRootPath,
            );

            return ProjectPhaseService.normalizePath(relativePath);
          })
          .where(
            (relativePath) =>
                relativePath.isNotEmpty && !relativePath.endsWith('.DS_Store'),
          )
          .toList();
    } on Exception {
      return const [];
    }
  }
}

/// Service for managing project phase state and progress calculation.
///
/// Provides methods to determine current phase of a project,
/// calculate progress, and track completed documents.
class ProjectPhaseService {
  ProjectPhaseService({ProjectFileScanner? fileScanner})
    : _fileScanner =
          fileScanner ?? const LocalProjectFileScanner().getProjectFiles;

  final ProjectFileScanner _fileScanner;
  static final ProjectPhaseService _defaultInstance = ProjectPhaseService();

  static String getPhaseNameFromIndex(int phaseIndex) {
    switch (phaseIndex) {
      case 6:
        return 'Meta';
      case 5:
        return 'Planificación';
      case 4:
        return 'UI/UX';
      case 3:
        return 'Arquitectura';
      case 2:
        return 'Requisitos';
      case 1:
        return 'Contexto';
      default:
        return 'Raíz';
    }
  }

  static ProjectPhaseProgress analyzeProject(String projectPath) =>
      _defaultInstance.analyzeProjectPath(projectPath);

  ProjectPhaseProgress analyzeProjectPath(String projectPath) {
    try {
      PathValidator.validateProjectPath(projectPath);
    } on Exception {
      return const ProjectPhaseProgress(
        currentPhase: 0,
        docsCompleted: 0,
        totalDocs: ProjectStructureConstants.totalExpectedDocs,
        progress: 0,
      );
    }

    final files = _fileScanner(projectPath);
    return calculateProgressForFiles(files);
  }

  ProjectPhaseProgress calculateProgressForFiles(List<String> filePaths) =>
      calculateProgressFromFiles(filePaths);

  static ProjectPhaseProgress calculateProgressFromFiles(
    List<String> filePaths,
  ) {
    final normalizedFiles = filePaths
        .map(normalizePath)
        .where((path) => path.isNotEmpty)
        .toSet();

    var docsCompleted = 0;
    var currentPhase = 0;

    for (final phase in ProjectStructureConstants.phaseDefinitions) {
      final index = phase['index'] as int;
      final folders = (phase['folders'] as List<Object>).cast<String>();
      final mandatoryDocs = (phase['mandatoryDocs'] as List<Object>)
          .cast<String>();
      final optionalDocs =
          ((phase['optionalDocs'] as List<Object>?) ?? const []).cast<String>();

      var isPhaseComplete = true;

      for (final doc in mandatoryDocs) {
        final exists = _documentExists(
          normalizedFiles,
          folders: folders,
          documentName: doc,
        );
        if (exists) {
          docsCompleted++;
        } else {
          isPhaseComplete = false;
        }
      }

      for (final doc in optionalDocs) {
        final exists = _documentExists(
          normalizedFiles,
          folders: folders,
          documentName: doc,
        );
        if (exists) {
          docsCompleted++;
        }
      }

      if (isPhaseComplete && index > currentPhase - 1) {
        currentPhase = index;
      } else if (!isPhaseComplete) {
        break;
      }
    }

    final progress =
        (docsCompleted / ProjectStructureConstants.totalExpectedDocs).clamp(
          0.0,
          1.0,
        );

    return ProjectPhaseProgress(
      currentPhase: currentPhase,
      docsCompleted: docsCompleted,
      totalDocs: ProjectStructureConstants.totalExpectedDocs,
      progress: progress,
    );
  }

  /// Determines the current phase of a project.
  ///
  /// For the guide project, always returns [ProjectPhase.quickStart].
  /// For real projects, analyzes the project directory structure
  /// to determine phase.
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
      final phaseProgress = analyzeProject(project.path);
      return _mapPhaseIndexToModel(phaseProgress.currentPhase);
    } on Exception {
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

    const totalFiles = ProjectStructureConstants.totalExpectedDocs;
    if (totalFiles == 0) {
      return 0;
    }

    return (documentsCreated / totalFiles).clamp(0.0, 1.0);
  }

  /// Gets the current phase name for display.
  static String getCurrentPhaseName(Project project, int documentsCreated) {
    if (project.id == 'guide-softarchitect-01') {
      return 'Quick start';
    }

    var accumulated = 0;
    for (final phase in ProjectStructureConstants.phaseDefinitions) {
      final phaseName = phase['name'] as String;
      final mandatoryDocs = (phase['mandatoryDocs'] as List<Object>)
          .cast<String>()
          .length;
      final optionalDocs =
          ((phase['optionalDocs'] as List<Object>?) ?? const []).length;
      accumulated += mandatoryDocs + optionalDocs;
      if (documentsCreated < accumulated) {
        return phaseName;
      }
    }

    return 'Meta';
  }

  /// Gets the number of documents completed in the current phase.
  static int getDocumentsInCurrentPhase(Project project, int documentsCreated) {
    if (project.id == 'guide-softarchitect-01') {
      return 0;
    }

    var accumulated = 0;
    for (final phase in ProjectStructureConstants.phaseDefinitions) {
      final mandatoryDocs = (phase['mandatoryDocs'] as List<Object>)
          .cast<String>()
          .length;
      final optionalDocs =
          ((phase['optionalDocs'] as List<Object>?) ?? const []).length;
      final phaseCount = mandatoryDocs + optionalDocs;

      final phaseStart = accumulated;
      accumulated += phaseCount;

      if (documentsCreated < accumulated) {
        return documentsCreated - phaseStart;
      }
    }

    return 0;
  }

  /// Checks if a project is the guide project.
  static bool isGuideProject(Project project) =>
      project.id == 'guide-softarchitect-01';

  static String normalizePath(String path) =>
      path.replaceAll(RegExp(r'\\'), '/').replaceAll(RegExp(r'/+'), '/').trim();

  static bool _documentExists(
    Set<String> normalizedFiles, {
    required List<String> folders,
    required String documentName,
  }) {
    for (final folder in folders) {
      final normalizedFolder = normalizePath(folder);
      final candidate = normalizedFolder.isEmpty
          ? normalizePath(documentName)
          : normalizePath('$normalizedFolder/$documentName');
      if (normalizedFiles.contains(candidate)) {
        return true;
      }
    }
    return false;
  }

  static ProjectPhase _mapPhaseIndexToModel(int phaseIndex) {
    switch (phaseIndex) {
      case 6:
        return ProjectPhase.meta;
      case 5:
        return ProjectPhase.planning;
      case 4:
        return ProjectPhase.uiUx;
      case 3:
        return ProjectPhase.architecture;
      case 2:
        return ProjectPhase.requirements;
      case 1:
        return ProjectPhase.context;
      default:
        return ProjectPhase.root;
    }
  }
}
