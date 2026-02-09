import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Header bar for project shell with file name and panel toggles.
///
/// Displays the current file name and provides buttons to toggle
/// the visibility of the file explorer and markdown preview panels.
class ProjectHeaderBar extends StatelessWidget {
  const ProjectHeaderBar({
    required this.fileName,
    required this.showFilesPanel,
    required this.showMarkdownPanel,
    required this.onToggleFiles,
    required this.onToggleMarkdown,
    super.key,
  });

  final String fileName;
  final bool showFilesPanel;
  final bool showMarkdownPanel;
  final VoidCallback onToggleFiles;
  final VoidCallback onToggleMarkdown;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!showFilesPanel)
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_right, size: 16),
                tooltip: 'Mostrar Explorador',
                onPressed: onToggleFiles,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            const SizedBox(width: 8),
            Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                showFilesPanel ? Icons.width_normal : Icons.width_wide,
                size: 16,
                color: showFilesPanel
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              tooltip: 'Alternar Panel Archivos',
              onPressed: onToggleFiles,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                showMarkdownPanel ? Icons.visibility : Icons.visibility_off,
                size: 16,
                color: showMarkdownPanel
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              tooltip: 'Alternar Vista Previa',
              onPressed: onToggleMarkdown,
            ),
          ],
        ),
      ],
    ),
  );
}
