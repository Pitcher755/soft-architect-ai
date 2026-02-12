import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../../domain/services/project_phase_service.dart';
import '../providers/project_providers.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/project_list_view.dart';
import '../widgets/projects_grid.dart';
import '../widgets/show_all_projects_button.dart';
import '../widgets/workspace_header.dart';

/// ProjectWorkspaceScreen - Dashboard for managing projects
/// Shows projects in a grid with options to expand and view all projects
class ProjectWorkspaceScreen extends ConsumerStatefulWidget {
  const ProjectWorkspaceScreen({super.key});

  @override
  ConsumerState<ProjectWorkspaceScreen> createState() =>
      _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState
    extends ConsumerState<ProjectWorkspaceScreen> {
  bool showAllProjects = false;

  @override
  Widget build(BuildContext context) {
    final allProjects = ref.watch(projectsProvider);
    final displayedProjects = allProjects.take(8).toList();

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: LayoutBuilder(
        builder: (context, windowConstraints) {
          const minWindowHeight = 500.0;
          final needsVerticalScroll =
              windowConstraints.maxHeight < minWindowHeight;
          final effectiveHeight = needsVerticalScroll
              ? minWindowHeight
              : windowConstraints.maxHeight;

          final Widget screenContent = SizedBox(
            height: effectiveHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 64,
                  height: double.infinity,
                  child: ProjectsSidebar(),
                ),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, contentConstraints) {
                      const minDashboardWidth = 500.0;
                      final needsHorizontalScroll =
                          contentConstraints.maxWidth < minDashboardWidth;

                      final Widget verticalContent = SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            WorkspaceHeader(
                              onNewProject: () =>
                                  CreateProjectDialog.show(context, ref),
                            ),
                            const SizedBox(height: 40),
                            ProjectsGrid(projects: displayedProjects),
                            const SizedBox(height: 24),
                            ShowAllProjectsButton(
                              totalProjects: allProjects.length,
                              isExpanded: showAllProjects,
                              onToggle: () {
                                setState(() {
                                  showAllProjects = !showAllProjects;
                                });
                              },
                            ),
                            if (showAllProjects)
                              ProjectListView(
                                projects: allProjects.map((p) {
                                  final phase =
                                      ProjectPhaseService.getProjectPhase(p);
                                  return {
                                    'name': p.name,
                                    'path': p.path,
                                    'icon': phase.icon,
                                    'iconColor': phase.color,
                                    'phaseColor': phase.color,
                                  };
                                }).toList(),
                                onClose: () {
                                  setState(() {
                                    showAllProjects = false;
                                  });
                                },
                              ),
                          ],
                        ),
                      );

                      if (needsHorizontalScroll) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: minDashboardWidth,
                            height: effectiveHeight,
                            child: verticalContent,
                          ),
                        );
                      }

                      return verticalContent;
                    },
                  ),
                ),
              ],
            ),
          );

          if (needsVerticalScroll) {
            return SingleChildScrollView(child: screenContent);
          }

          return screenContent;
        },
      ),
    );
  }
}
