// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Represents a project phase with its associated metadata.
///
/// Each phase has a unique name, icon, and color scheme.
/// Phases are used throughout the application to indicate
/// project progress and organize workflow.
class ProjectPhase {
  const ProjectPhase({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.fileCount,
    required this.order,
  });

  /// Unique identifier for the phase
  final String id;

  /// Display name of the phase
  final String name;

  /// Icon representing the phase
  final IconData icon;

  /// Color associated with the phase
  final Color color;

  /// Expected number of files/documents in this phase
  final int fileCount;

  /// Order of the phase in the workflow (0-based)
  final int order;

  // ────────────────────────────────────────────────────────────
  // PREDEFINED PHASES
  // ────────────────────────────────────────────────────────────

  /// Quick start phase - for guide and tutorials
  static const quickStart = ProjectPhase(
    id: 'QUICK_START',
    name: 'Quick start',
    icon: Icons.play_circle_outline,
    color: AppColors.primaryLight,
    fileCount: 0,
    order: -1,
  );

  /// Root phase - initial project setup
  static const root = ProjectPhase(
    id: 'ROOT',
    name: 'Raíz',
    icon: Icons.home_outlined,
    color: AppColors.dirRoot,
    fileCount: 4,
    order: 0,
  );

  /// Context phase - business context and scope
  static const context = ProjectPhase(
    id: 'CONTEXT',
    name: 'Contexto',
    icon: Icons.settings_outlined,
    color: AppColors.dirContext,
    fileCount: 3,
    order: 1,
  );

  /// Requirements phase - functional and non-functional requirements
  static const requirements = ProjectPhase(
    id: 'REQUIREMENTS',
    name: 'Requisitos',
    icon: Icons.checklist_rtl,
    color: AppColors.dirRequirements,
    fileCount: 4,
    order: 2,
  );

  /// Architecture phase - system architecture and design
  static const architecture = ProjectPhase(
    id: 'ARCHITECTURE',
    name: 'Arquitectura',
    icon: Icons.account_tree_outlined,
    color: AppColors.dirArchitecture,
    fileCount: 6,
    order: 3,
  );

  /// UI/UX phase - user interface and experience design
  static const uiUx = ProjectPhase(
    id: 'UI_UX',
    name: 'UI/UX',
    icon: Icons.palette_outlined,
    color: AppColors.dirUiUx,
    fileCount: 3,
    order: 4,
  );

  /// Planning phase - project roadmap and milestones
  static const planning = ProjectPhase(
    id: 'PLANNING',
    name: 'Planificación',
    icon: Icons.calendar_today_outlined,
    color: AppColors.dirPlanning,
    fileCount: 4,
    order: 5,
  );

  /// Meta phase - project metadata and documentation
  static const meta = ProjectPhase(
    id: 'META',
    name: 'Meta',
    icon: Icons.info_outline,
    color: AppColors.dirMeta,
    fileCount: 1,
    order: 6,
  );

  // ────────────────────────────────────────────────────────────
  // PHASE COLLECTIONS
  // ────────────────────────────────────────────────────────────

  /// All available phases in order
  static const List<ProjectPhase> all = [
    root,
    context,
    requirements,
    architecture,
    uiUx,
    planning,
    meta,
  ];

  /// Total number of expected files across all phases
  static int get totalFileCount =>
      all.fold(0, (sum, phase) => sum + phase.fileCount);

  // ────────────────────────────────────────────────────────────
  // UTILITY METHODS
  // ────────────────────────────────────────────────────────────

  /// Gets a phase by its ID
  static ProjectPhase? getById(String id) {
    try {
      return all.firstWhere((phase) => phase.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets a phase by its order index
  static ProjectPhase? getByOrder(int order) {
    try {
      return all.firstWhere((phase) => phase.order == order);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPhase &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProjectPhase($id: $name)';
}
