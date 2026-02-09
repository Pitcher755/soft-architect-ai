import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Button to toggle showing all projects in a list view.
///
/// Displays when there are more projects than the grid can show.
class ShowAllProjectsButton extends StatelessWidget {
  const ShowAllProjectsButton({
    required this.totalProjects,
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final int totalProjects;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    if (totalProjects <= 8) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onToggle,
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
            label: Text(
              isExpanded
                  ? 'Ocultar proyectos'
                  : 'Ver todos los proyectos ($totalProjects)',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
