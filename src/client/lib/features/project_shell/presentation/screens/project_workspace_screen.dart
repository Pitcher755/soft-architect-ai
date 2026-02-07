import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          Container(
            width: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(right: BorderSide(color: Color(0xFF30363d))),
            ),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0d0df2).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.terminal,
                      color: Color(0xFF0d0df2),
                      size: 24,
                    ),
                  ),
                ),
                // Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      // Projects button (active)
                      Tooltip(
                        message: 'Proyectos',
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0d0df2,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.folder_open,
                            color: Color(0xFF0d0df2),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search button
                      Tooltip(
                        message: 'Búsqueda Global',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.search,
                                color: Color(0xFF8b949e),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Settings button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Tooltip(
                    message: 'Configuración',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/settings'),
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.settings,
                            color: Color(0xFF8b949e),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mis Proyectos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE6EDF3),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gestión local de arquitectura',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8b949e),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateProjectDialog(context),
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
                          : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return _buildProjectCard(
                            context: context,
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

  Widget _buildProjectCard({
    required BuildContext context,
    required String name,
    required IconData icon,
    required Color iconColor,
    required String phase,
    required Color phaseColor,
    required String path,
    required String modified,
    required VoidCallback onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363d)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and phase badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: phaseColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: phaseColor.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        phase,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Courier',
                          color: phaseColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Project name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE6EDF3),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Project path
                Row(
                  children: [
                    const Icon(
                      Icons.folder,
                      size: 14,
                      color: Color(0xFF8b949e),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        path,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Courier',
                          color: Color(0xFF8b949e),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Bottom section with metadata
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF30363d), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modificado: $modified',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8b949e),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Color(0xFF8b949e),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final pathController = TextEditingController(
      text: '~/Documents/SoftArchitectProjects',
    );
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nuevo Proyecto',
              style: TextStyle(
                color: Color(0xFFE6EDF3),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close, color: Color(0xFF8b949e)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Project name
                const Text(
                  'Nombre del Proyecto',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Ej: MySuperApp',
                    hintStyle: const TextStyle(color: Color(0xFF444c56)),
                    filled: true,
                    fillColor: const Color(0xFF0D1117),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF30363d)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF30363d)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0d0df2),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFE6EDF3)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Solo caracteres alfanuméricos, guiones y guiones bajos.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8b949e)),
                ),
                const SizedBox(height: 24),

                // Base path
                const Text(
                  'Ruta Base (Local)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: pathController,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF0D1117),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF30363d),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF30363d),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF444c56),
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.folder_open, size: 18),
                      label: const Text('Examinar...'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF21262d),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF30363d)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Se creará la carpeta automáticamente.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8b949e)),
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  'Descripción Corta',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '¿Qué vamos a construir hoy?',
                    hintStyle: const TextStyle(color: Color(0xFF444c56)),
                    filled: true,
                    fillColor: const Color(0xFF0D1117),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF30363d)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF30363d)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0d0df2),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFE6EDF3)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFE6EDF3)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final projectName = nameController.text.trim();
              if (projectName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un nombre de proyecto'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              // Navigate to ProjectShellScreen with the project path
              context.go(
                '/project-shell?path=${Uri.encodeComponent(pathController.text)}',
              );
            },
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: const Text('Crear Proyecto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0d0df2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
