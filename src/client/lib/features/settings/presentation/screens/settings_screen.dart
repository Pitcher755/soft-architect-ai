import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../../gen/app_localizations.dart';
import '../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../widgets/accessibility_section.dart';
import '../widgets/appearance_section.dart';
import '../widgets/language_section.dart';
import '../widgets/performance_section.dart';
import '../widgets/profile_section.dart';
import '../widgets/storage_section.dart';

/// Settings screen - Application settings and configuration.
///
/// Refactored following SOLID principles with modular section widgets.
/// All settings are persistent via SettingsNotifier/SharedPreferences.
///
/// NOTE: This screen maintains its position in the navigation stack.
/// Changes to settings (theme, zoom, font, etc.) do NOT navigate away.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for locale changes only (not triggering navigation changes)
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsTitle,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsSubtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 14),
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
                  const LanguageSection(),
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
}
