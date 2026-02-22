import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../gen/app_localizations.dart';

/// Header section of the workspace screen.
///
/// Displays the title, subtitle, and "New Project" button.
class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({required this.onNewProject, super.key});

  final VoidCallback onNewProject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Logo1.png', height: 75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.workspaceSectionTitle,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE6EDF3),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.workspaceSubtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8b949e),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myProjects,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE6EDF3),
                letterSpacing: -0.5,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onNewProject,
              icon: const Icon(Icons.add, size: 20),
              label: Text(l10n.newProjectButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      ],
    );
  }
}
