import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/project_shell/presentation/screens/project_shell_screen.dart';
import '../../features/project_shell/presentation/screens/project_workspace_screen.dart';

/// Central routing configuration for the application.
/// Uses GoRouter for declarative navigation.
///
/// Routes:
/// - `/` → Project Selection/Dashboard
/// - `/workspace/:projectId` → ProjectWorkspaceScreen with project context
/// - `/project-shell` → Legacy ProjectShellScreen (for testing)
/// - `/chat` → Chat screen
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
      path: '/workspace/:projectId',
      name: 'workspace',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId'] ?? 'unknown';
        return ProjectWorkspaceScreen(projectPath: projectId);
      },
    ),
    GoRoute(
      path: '/project-shell',
      name: 'project-shell',
      builder: (context, state) => const ProjectShellScreen(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
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
                  _buildQuickNavCard(
                    context,
                    icon: Icons.chat,
                    title: 'Chat',
                    onTap: () => context.go('/chat'),
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
        'desc': 'AI Architecture Assistant'
      },
      {
        'id': 'proj-002',
        'name': 'Document Generator',
        'desc': 'Generate technical docs'
      },
      {'id': 'proj-003', 'name': 'Test Project', 'desc': 'Demo project for testing'},
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
  }) =>
      Padding(
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
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
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
  }) =>
      Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Project name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final projectId = 'proj-${DateTime.now().millisecondsSinceEpoch}';
              Navigator.pop(context);
              context.go('/workspace/$projectId');
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SoftArchitect AI - Main Navigation'),
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                '🎯 Welcome to SoftArchitect AI',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'An interactive workspace for document generation',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 32),

              // Navigation buttons
              Text(
                'Available Screens:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Project Shell
              _buildNavButton(
                context,
                icon: Icons.folder,
                title: 'Project Shell (Basic)',
                description: 'File tree view with preview panel',
                onPressed: () => context.go('/project-shell'),
              ),
              const SizedBox(height: 12),

              // Workspace (3-column IDE)
              _buildNavButton(
                context,
                icon: Icons.dashboard,
                title: '3-Column Workspace (Main)',
                description: 'IDE-like interface with chat, files, and preview',
                onPressed: () => context.go('/workspace'),
              ),
              const SizedBox(height: 12),

              // Chat
              _buildNavButton(
                context,
                icon: Icons.chat,
                title: 'Chat Screen',
                description: 'Sequential document generation chat',
                onPressed: () => context.go('/chat'),
              ),
              const SizedBox(height: 12),

              // Settings
              _buildNavButton(
                context,
                icon: Icons.settings,
                title: 'Settings',
                description: 'Application configuration',
                onPressed: () => context.go('/settings'),
              ),
              const SizedBox(height: 32),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 About This Project',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HU-3.3 implements a complete interactive IDE-like interface.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  static Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      );
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: const Center(child: Text('Settings Feature - Coming Soon')),
  );
}
