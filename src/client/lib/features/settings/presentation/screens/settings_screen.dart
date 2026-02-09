import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../widgets/accessibility_section.dart';
import '../widgets/appearance_section.dart';
import '../widgets/performance_section.dart';
import '../widgets/profile_section.dart';
import '../widgets/storage_section.dart';

/// Settings screen - Application settings and configuration.
///
/// Refactored following SOLID principles with modular section widgets.
/// All settings are persistent via SettingsNotifier/SharedPreferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
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
                          'Personaliza tu experiencia en SoftArchitect AI',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8b949e),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Settings Sections (Modular Widgets)
                    const ProfileSection(),
                    const SizedBox(height: 32),
                    const StorageSection(),
                    const SizedBox(height: 32),
                    const AppearanceSection(),
                    const SizedBox(height: 32),
                    const AccessibilitySection(),
                    const SizedBox(height: 32),
                    const PerformanceSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
