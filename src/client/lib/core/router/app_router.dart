import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/project_shell/presentation/screens/project_shell_screen.dart';
import '../../features/project_shell/presentation/screens/project_workspace_screen.dart';

/// Central routing configuration for the application.
/// Uses GoRouter for declarative navigation.
///
/// Routes:
/// - `/` → Project Selection/Dashboard
/// - `/workspace` → Projects Management Dashboard
/// - `/project-shell?path=...` → ProjectShellScreen for active project editing with path
/// - `/settings` → Settings screen
GoRouter createAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const _ProjectSelectionScreen(),
    ),
    GoRoute(
      path: '/workspace',
      name: 'workspace',
      builder: (context, state) => const ProjectWorkspaceScreen(),
    ),
    GoRoute(
      path: '/project-shell',
      name: 'project-shell',
      builder: (context, state) {
        final path = state.uri.queryParameters['path'] ?? '';
        return ProjectShellScreen(projectPath: path);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const _SettingsScreen(),
    ),
  ],
);

/// Project Selection Screen - Main dashboard with available projects.
class _ProjectSelectionScreen extends StatelessWidget {
  const _ProjectSelectionScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SoftArchitect AI - Projects'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.go('/settings'),
          tooltip: 'Settings',
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                '🎯 SoftArchitect AI Workspace',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Interactive workspace for document generation',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 32),

              // Section: Available Projects
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Projects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCreateProjectDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Project'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mock Projects
              ..._buildMockProjects(context),

              const SizedBox(height: 32),

              // Quick Navigation
              Text(
                'Quick Navigation',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Navigation cards for other screens
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildQuickNavCard(
                    context,
                    icon: Icons.folder_open,
                    title: 'Project Shell',
                    onTap: () => context.go('/project-shell'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Build mock project cards for testing.
  List<Widget> _buildMockProjects(BuildContext context) {
    final mockProjects = [
      {
        'id': 'proj-001',
        'name': 'SoftArchitect - Main',
        'desc': 'AI Architecture Assistant',
      },
      {
        'id': 'proj-002',
        'name': 'Document Generator',
        'desc': 'Generate technical docs',
      },
      {
        'id': 'proj-003',
        'name': 'Test Project',
        'desc': 'Demo project for testing',
      },
    ];

    return mockProjects
        .map(
          (project) => _buildProjectCard(
            context,
            id: project['id'] as String,
            name: project['name'] as String,
            description: project['desc'] as String,
            onTap: () {
              context.go('/workspace/${project['id']}');
            },
          ),
        )
        .toList();
  }

  /// Build a single project card.
  Widget _buildProjectCard(
    BuildContext context, {
    required String id,
    required String name,
    required String description,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $id',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    ),
  );

  /// Build quick navigation card.
  Widget _buildQuickNavCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => SizedBox(
    width: 120,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Show create project dialog.
  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    const selectedPath = '/home/Documents/SoftArchitectProjects';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuevo Proyecto'),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project name field
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
                const SizedBox(height: 8),
                const Text(
                  'Solo caracteres alfanuméricos, guiones y guiones bajos.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8b949e)),
                ),
                const SizedBox(height: 24),

                // Base path field
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
                        readOnly: true,
                        controller: TextEditingController(text: selectedPath),
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
                          color: Color(0xFF8b949e),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement file picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File picker coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_open, size: 18),
                      label: const Text('Examinar...'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF21262d),
                        foregroundColor: const Color(0xFFE6EDF3),
                        side: const BorderSide(color: Color(0xFF30363d)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Se creará la carpeta automáticamente.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8b949e)),
                ),
                const SizedBox(height: 24),

                // Description field
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
              context.go('/project-shell');
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

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: const Center(child: Text('Settings Feature - Coming Soon')),
  );
}
