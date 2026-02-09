import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/project_shell/domain/entities/project.dart';
import '../../../features/project_shell/domain/services/project_phase_service.dart';
import '../../../features/project_shell/presentation/providers/project_providers.dart';
import '../../../features/project_shell/presentation/widgets/project_card.dart';

/// Global search dialog for finding projects.
///
/// Searches projects by name, phase, and date range.
/// Shows results in a clean, filterable list.
class GlobalSearchDialog extends ConsumerStatefulWidget {
  const GlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => const GlobalSearchDialog(),
    );
  }

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  late TextEditingController _searchController;
  List<Project> _filteredProjects = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterProjects();
    });
  }

  void _filterProjects() {
    final allProjects = ref.read(projectsProvider);

    if (_searchQuery.isEmpty) {
      _filteredProjects = allProjects;
      return;
    }

    _filteredProjects = allProjects.where((project) {
      final nameMatch = project.name.toLowerCase().contains(_searchQuery);
      final phase = ProjectPhaseService.getProjectPhase(project);
      final phaseMatch = phase.name.toLowerCase().contains(_searchQuery);

      // Date range search (e.g., "2026", "enero", "feb")
      final dateStr = project.createdAt.toString().toLowerCase();
      final dateMatch = dateStr.contains(_searchQuery);

      return nameMatch || phaseMatch || dateMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Update filtered projects when provider changes
    final allProjects = ref.watch(projectsProvider);
    if (_searchQuery.isEmpty) {
      _filteredProjects = allProjects;
    }

    return Dialog(
      backgroundColor: AppColors.surfaceBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Búsqueda Global',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Input
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textMain, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Buscar por nombre, fase, o fecha (ej: "Alpha", "Root", "2026")...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results count
            Text(
              _searchQuery.isEmpty
                  ? '${allProjects.length} proyectos totales'
                  : '${_filteredProjects.length} resultados encontrados',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // Results List
            Expanded(
              child: _filteredProjects.isEmpty && _searchQuery.isNotEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: _filteredProjects.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final project = _filteredProjects[index];
                        final phase = ProjectPhaseService.getProjectPhase(
                          project,
                        );

                        // Format date
                        final now = DateTime.now();
                        final diff = now.difference(project.createdAt);
                        String modified;
                        if (diff.inDays == 0) {
                          modified = 'Hoy';
                        } else if (diff.inDays == 1) {
                          modified = 'Ayer';
                        } else if (diff.inDays < 7) {
                          modified = 'Hace ${diff.inDays} días';
                        } else if (diff.inDays < 30) {
                          modified = 'Hace ${diff.inDays ~/ 7} semanas';
                        } else {
                          modified = 'Hace ${diff.inDays ~/ 30} meses';
                        }

                        return ProjectCard(
                          name: project.name,
                          icon: phase.icon,
                          iconColor: phase.color,
                          phase: phase.name,
                          phaseColor: phase.color,
                          path: project.path,
                          modified: modified,
                          onTap: () {
                            Navigator.of(context).pop();
                            // Navigation is handled by the card itself
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 64,
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'No se encontraron resultados',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Intenta con otro término de búsqueda',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );
}
