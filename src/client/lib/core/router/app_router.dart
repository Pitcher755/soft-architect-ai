import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/project_shell/presentation/screens/project_shell_screen.dart';

/// Central routing configuration for the application.
/// Uses GoRouter for declarative navigation.
GoRouter createAppRouter() => GoRouter(
  initialLocation: '/project-shell',
  routes: [
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

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: const Center(child: Text('Settings Feature - Coming Soon')),
  );
}
