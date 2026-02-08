import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

/// ProjectsSidebar - Left navigation sidebar for the projects dashboard
/// Contains logo, navigation buttons, and settings
class ProjectsSidebar extends StatefulWidget {
  const ProjectsSidebar({this.onSearchTap, this.onSettingsTap, super.key});
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  @override
  State<ProjectsSidebar> createState() => _ProjectsSidebarState();
}

class _ProjectsSidebarState extends State<ProjectsSidebar> {
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Búsqueda Global'),
        backgroundColor: AppColors.surfaceBg,
        titleTextStyle: const TextStyle(
          color: AppColors.textMain,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input field
              TextField(
                controller: searchController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: 'Escribe el término a buscar...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.mainBg,
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
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    // TODO: Implement search logic with the search term
                    debugPrint('Searching for: $value');
                    Navigator.pop(dialogContext);
                  }
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final searchTerm = searchController.text.trim();
                      if (searchTerm.isNotEmpty) {
                        // TODO: Implement search logic with the search term
                        debugPrint('Searching for: $searchTerm');
                        Navigator.pop(dialogContext);
                      }
                    },
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Buscar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 64,
    decoration: const BoxDecoration(
      color: AppColors.surfaceBg,
      border: Border(right: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      children: [
        // Logo
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.terminal,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        // Navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // Projects button (active)
              Tooltip(
                message: 'Proyectos',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/workspace'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder_open,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Search button
              Tooltip(
                message: 'Búsqueda Global',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        widget.onSearchTap ??
                        () {
                          _showSearchDialog(context);
                        },
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Settings button
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Tooltip(
            message: 'Configuración',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSettingsTap ?? () => context.go('/settings'),
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.settings,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
