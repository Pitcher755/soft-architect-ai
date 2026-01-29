import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central routing configuration for the application.
/// Uses GoRouter for declarative navigation.
GoRouter createAppRouter() => GoRouter(
  initialLocation: '/chat',
  routes: [
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const _ChatScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const _SettingsScreen(),
    ),
  ],
);

// TODO: Replace with actual screens from presentation layers
class _ChatScreen extends StatelessWidget {
  const _ChatScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chat')),
    body: const Center(child: Text('Chat Feature - Coming Soon')),
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
