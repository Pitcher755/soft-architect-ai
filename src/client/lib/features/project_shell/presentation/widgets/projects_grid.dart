import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../../gen/app_localizations.dart';
import '../../../../../shared/utils/navigation_utils.dart';
import '../../domain/entities/project.dart';
import '../../domain/services/project_phase_service.dart';
import '../providers/project_providers.dart';
import 'project_card.dart';

/// Grid view displaying recent project cards with Quick Start option.
///
/// Displays the most recently used 7 projects sorted by last opened date,
/// plus a Quick Start card for creating new projects.
/// Handles responsive layout and project card generation.
class ProjectsGrid extends ConsumerWidget {
  const ProjectsGrid({required this.projects, super.key});

  final List<Project> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          l10n.loadingProjects,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
      );
    }

    // Sort projects by last opened date (most recent first)
    // and take only the last 8 projects
    final sortedProjects = List<Project>.from(projects)
      ..sort((a, b) {
        final aDate = a.lastOpened ?? a.createdAt;
        final bDate = b.lastOpened ?? b.createdAt;
        return bDate.compareTo(aDate); // Descending order
      });

    final recentProjects = sortedProjects.take(8).toList();

    return LayoutBuilder(
      builder: (context, gridConstraints) {
        const double minCardWidth = 280;
        final calculatedColumns = (gridConstraints.maxWidth / minCardWidth)
            .floor();
        final effectiveColumns = calculatedColumns.clamp(1, 4);
        const childAspectRatio = 1.9;

        return SizedBox(
          width: double.infinity,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: effectiveColumns,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: recentProjects.length,
            itemBuilder: (context, index) {
              final project = recentProjects[index];
              final phase = ProjectPhaseService.getProjectPhase(project);
              final progressState = ref.watch(
                projectProgressProvider(project.path),
              );
              final cardProgress = progressState.maybeWhen(
                data: (progress) => progress.progress,
                orElse: () => null,
              );

              return ProjectCard(
                name: project.name,
                icon: phase.icon,
                iconColor: phase.color,
                phase: phase.name,
                phaseColor: phase.color,
                progress: cardProgress,
                path: project.path,
                projectId: project.id,
                isMissing: project.isMissing,
                modified: _formatDate(
                  context,
                  project.lastOpened ?? project.createdAt,
                ),
                onTap: () => navigateToProjectShell(context, ref, project.path),
              );
            },
          ),
        );
      },
    );
  }

  /// Formats a date into a human-readable relative string.
  ///
  /// Returns localized strings like "Today", "Yesterday", or formatted dates.
  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return l10n.today;
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}
