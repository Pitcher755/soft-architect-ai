import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// ProjectListView - Displays all projects in a scrollable list format
/// Shows mini cards with project name, path, and phase color accent
class ProjectListView extends StatefulWidget {
  const ProjectListView({
    required this.projects,
    required this.onClose,
    super.key,
  });

  final List<Map<String, dynamic>> projects;
  final VoidCallback onClose;

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  late List<Map<String, dynamic>> sortedProjects;

  @override
  void initState() {
    super.initState();
    // Sort projects alphabetically by name
    sortedProjects = List.from(widget.projects);
    sortedProjects.sort(
      (a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 24),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Close button in top-right
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(4),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Scrollable projects list
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: List.generate(sortedProjects.length, (index) {
                    final project = sortedProjects[index];
                    return _ProjectMiniCard(
                      name: project['name'] as String,
                      path: project['path'] as String,
                      icon: project['icon'] as IconData,
                      iconColor: project['iconColor'] as Color,
                      phaseColor: project['phaseColor'] as Color,
                      onTap: () {
                        // TODO: Navigate to project
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Mini card for project list - displays name,
/// path, icon with phase color border
class _ProjectMiniCard extends StatelessWidget {
  const _ProjectMiniCard({
    required this.name,
    required this.path,
    required this.icon,
    required this.iconColor,
    required this.phaseColor,
    required this.onTap,
  });

  final String name;
  final String path;
  final IconData icon;
  final Color iconColor;
  final Color phaseColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: phaseColor.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              // Name (left side)
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Path (right side)
              Expanded(
                child: Text(
                  path,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier',
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              // Arrow icon
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: phaseColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
