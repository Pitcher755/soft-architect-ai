import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../data/mock_projects_data.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/project_card.dart';
import '../widgets/project_list_view.dart';
import '../widgets/projects_sidebar.dart';

/// ProjectWorkspaceScreen - Dashboard for managing projects
/// Shows projects in a grid with options to expand and view all projects
class ProjectWorkspaceScreen extends StatefulWidget {
  const ProjectWorkspaceScreen({super.key});

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
  bool showAllProjects = false;

  @override
  Widget build(BuildContext context) {
    // Get mock projects data
    final allProjects = getMockProjectsData();
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
                            const Column(
                              children: [
                                Text(
                                  '🎯 SoftArchitect AI Workspace',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE6EDF3),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Interactive workspace for document generation',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8b949e),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mis Proyectos',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE6EDF3),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      CreateProjectDialog.show(context),
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('Nuevo Proyecto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            LayoutBuilder(
                              builder: (context, gridConstraints) {
                                const double minCardWidth = 280;
                                final calculatedColumns =
                                    (gridConstraints.maxWidth / minCardWidth)
                                        .floor();
                                final effectiveColumns = calculatedColumns
                                    .clamp(1, 4);
                                const childAspectRatio = 1.9;

                                return SizedBox(
                                  width: double.infinity,
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: effectiveColumns,
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 24,
                                          childAspectRatio: childAspectRatio,
                                        ),
                                    itemCount: displayedProjects.length,
                                    itemBuilder: (context, index) {
                                      final project = displayedProjects[index];
                                      return ProjectCard(
                                        name: project['name'] as String,
                                        icon: project['icon'] as IconData,
                                        iconColor:
                                            project['iconColor'] as Color,
                                        phase: project['phase'] as String,
                                        phaseColor:
                                            project['phaseColor'] as Color,
                                        path: project['path'] as String,
                                        modified: project['modified'] as String,
                                        onTap: () => context.go(
                                          '/project-shell?path=${Uri.encodeComponent(project['path'] as String)}',
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            if (allProjects.length > 8)
                              Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.5,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          showAllProjects = !showAllProjects;
                                        });
                                      },
                                      icon: Icon(
                                        showAllProjects
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 20,
                                      ),
                                      label: Text(
                                        showAllProjects
                                            ? 'Ocultar proyectos'
                                            : 'Ver todos los proyectos (${allProjects.length})',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            if (showAllProjects)
                              ProjectListView(
                                projects: allProjects,
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
