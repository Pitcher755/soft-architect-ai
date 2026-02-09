import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // IMPORT NECESARIO
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../providers/project_providers.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/project_card.dart';
import '../widgets/project_list_view.dart';

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
    // 1. CONEXIÓN CON RIVERPOD (Sustituye a getMockProjectsData)
    // Esto escucha cambios automáticamente, sin FutureBuilder
    final allProjects = ref.watch(projectsProvider);
    final displayedProjects = allProjects.take(8).toList();

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      // 2. ESTRUCTURA ORIGINAL EXACTA (LayoutBuilder -> Row -> ...)
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
                                  // CAMBIO CLAVE: Pasamos 'ref' al diálogo
                                  onPressed: () =>
                                      CreateProjectDialog.show(context, ref),
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

                            // Si la lista está vacía (carga inicial)
                            if (allProjects.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                  'Cargando proyectos...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            else
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
                                        final project =
                                            displayedProjects[index];
                                        // CAMBIO CLAVE: Usamos sintaxis de Objeto (project.name) no Mapa (project['name'])
                                        return ProjectCard(
                                          name: project.name,
                                          icon: Icons.folder,
                                          iconColor: AppColors.primary,
                                          phase: 'Proyecto',
                                          phaseColor: _getPhaseColor(
                                            'Proyecto',
                                          ),
                                          path: project.path,
                                          modified: _formatDate(
                                            project.lastOpened ??
                                                project.createdAt,
                                          ),
                                          onTap: () => context.go(
                                            Uri(
                                              path: '/project-shell',
                                              queryParameters: {
                                                'path': project.path,
                                              },
                                            ).toString(),
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
                                projects: allProjects
                                    .map(
                                      (p) => {
                                        'name': p.name,
                                        'path': p.path,
                                        'phase': 'Proyecto',
                                        'createdAt': p.createdAt,
                                      },
                                    )
                                    .toList(),
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

  // --- HELPERS (Para mantener el diseño sin lógica compleja en el build) ---

  Color _getPhaseColor(String phase) {
    if (phase.toLowerCase().contains('documentación')) return AppColors.info;
    if (phase.toLowerCase().contains('contexto')) return AppColors.dirContext;
    if (phase.toLowerCase().contains('requisitos'))
      return AppColors.dirRequirements;
    if (phase.toLowerCase().contains('arquitectura'))
      return AppColors.dirArchitecture;
    return AppColors.primary;
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
