import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../../domain/services/project_phase_service.dart';
import 'project_card.dart';

/// Grid view displaying project cards.
///
/// Handles responsive layout and project card generation.
class ProjectsGrid extends StatelessWidget {
  const ProjectsGrid({required this.projects, super.key});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'Cargando proyectos...',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
      );
    }

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
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final phase = ProjectPhaseService.getProjectPhase(project);

              return ProjectCard(
                name: project.name,
                icon: phase.icon,
                iconColor: phase.color,
                phase: phase.name,
                phaseColor: phase.color,
                path: project.path,
                modified: _formatDate(project.lastOpened ?? project.createdAt),
                onTap: () => context.go(
                  Uri(
                    path: '/project-shell',
                    queryParameters: {'path': project.path},
                  ).toString(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}
