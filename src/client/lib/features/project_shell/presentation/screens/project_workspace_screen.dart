import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/create_project_dialog.dart';
import '../widgets/project_card.dart';
import '../widgets/projects_sidebar.dart';

/// ProjectWorkspaceScreen - Dashboard for managing projects
/// Shows all projects in a grid with options to create new ones or open existing
class ProjectWorkspaceScreen extends StatelessWidget {
  const ProjectWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock projects data
    final projects = [
      {
        'id': 'proj-ecommerce',
        'name': 'E-Commerce Platform',
        'icon': Icons.domain,
        'iconColor': const Color(0xFF3B82F6),
        'phase': 'Fase 2: Requisitos',
        'phaseColor': const Color(0xFF10B981),
        'path': '~/Dev/Clients/ShopifyKiller',
        'modified': 'Hace 2h',
      },
      {
        'id': 'proj-uber-dogs',
        'name': 'Uber for Dogs',
        'icon': Icons.smartphone,
        'iconColor': const Color(0xFFA855F7),
        'phase': 'Fase 1: Contexto',
        'phaseColor': const Color(0xFFFCD34D),
        'path': '~/Personal/UberDogs',
        'modified': 'Ayer',
      },
      {
        'id': 'proj-fintech',
        'name': 'FinTech Core API',
        'icon': Icons.api,
        'iconColor': const Color(0xFFFB923C),
        'phase': 'Fase 3: Arquitectura',
        'phaseColor': const Color(0xFF60A5FA),
        'path': '~/Work/Bank/Core_API',
        'modified': '03/02/2026',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Row(
        children: [
          // Left Sidebar
          const SizedBox(
            width: 64,
            height: double.infinity,
            child: ProjectsSidebar(),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Header text
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

                  // Title Section
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
                        onPressed: () => CreateProjectDialog.show(context),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Nuevo Proyecto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d0df2),
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

                  // Projects Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1200
                          ? 3
                          : constraints.maxWidth > 800
                          ? 2
                          : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return ProjectCard(
                            name: project['name'] as String,
                            icon: project['icon'] as IconData,
                            iconColor: project['iconColor'] as Color,
                            phase: project['phase'] as String,
                            phaseColor: project['phaseColor'] as Color,
                            path: project['path'] as String,
                            modified: project['modified'] as String,
                            onTap: () => context.go(
                              '/project-shell?path=${Uri.encodeComponent(project['path'] as String)}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
