import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Header section of the workspace screen.
///
/// Displays the title, subtitle, and "New Project" button.
class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({required this.onNewProject, super.key});

  final VoidCallback onNewProject;

  @override
  Widget build(BuildContext context) => Column(
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
            style: TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
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
            onPressed: onNewProject,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nuevo Proyecto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    ],
  );
}
