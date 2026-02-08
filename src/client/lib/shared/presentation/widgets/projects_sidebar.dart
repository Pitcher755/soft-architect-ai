import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

/// ProjectsSidebar - Global navigation sidebar (64px fixed width)
///
/// Located in: lib/shared/presentation/widgets/ (global, not feature-specific)
///
/// Features:
/// - 64px fixed left navigation bar
/// - Logo with branding
/// - Navigation buttons (Projects, Search, Settings)
/// - Tooltips for accessibility
/// - Bottom-anchored settings button
///
/// Used by: All main screens requiring project context
/// Architecture: Presentation layer, no state management
/// needed (stateful for search dialog)
class ProjectsSidebar extends StatefulWidget {
  const ProjectsSidebar({this.onSearchTap, this.onSettingsTap, super.key});

  /// Callback when search button is tapped
  final VoidCallback? onSearchTap;

  /// Callback when settings button is tapped
  final VoidCallback? onSettingsTap;

  @override
  State<ProjectsSidebar> createState() => _ProjectsSidebarState();
}

class _ProjectsSidebarState extends State<ProjectsSidebar> {
  /// Handle search button tap - shows search dialog
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Global Search'),
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
              // Search input
              TextField(
                controller: searchController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: 'Search documents...',
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
                    // TODO: Implement search logic
                    debugPrint('Searching for: $value');
                    Navigator.pop(dialogContext);
                  }
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Dialog buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (searchController.text.isNotEmpty) {
                        Navigator.pop(dialogContext);
                      }
                    },
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Search'),
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
        // Logo / Brand
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

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // Projects button
              Tooltip(
                message: 'Projects',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/workspace'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder,
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
                message: 'Global Search',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        widget.onSearchTap ?? () => _showSearchDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.search,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
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

        // Settings button (bottom)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Tooltip(
            message: 'Settings',
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
