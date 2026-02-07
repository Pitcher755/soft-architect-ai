import 'package:go_router/go_router.dart';

import '../../features/project_shell/presentation/screens/project_shell_screen.dart';
import '../../features/project_shell/presentation/screens/project_workspace_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// Central routing configuration for the application.
/// Uses GoRouter for declarative navigation.
///
/// Routes:
/// - `/workspace` → Projects Management Dashboard (home)
/// - `/project-shell?path=...` → ProjectShellScreen for active project editing with path
/// - `/settings` → Settings screen
GoRouter createAppRouter() => GoRouter(
  initialLocation: '/workspace',
  routes: [
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
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
