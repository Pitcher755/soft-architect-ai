import 'package:flutter/material.dart';

import '../../../../../../features/project_shell/presentation/widgets/projects_sidebar.dart';

/// SettingsScreen - Application settings and configuration
/// Features left sidebar for navigation
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE6EDF3),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ajustes de la aplicación (próximamente)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8b949e),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Placeholder content
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    border: Border.all(color: const Color(0xFF30363d)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚙️ Configuración en desarrollo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE6EDF3),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Las opciones de configuración estarán disponibles próximamente.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8b949e),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
