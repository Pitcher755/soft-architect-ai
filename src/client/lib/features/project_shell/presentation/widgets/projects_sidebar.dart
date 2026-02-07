import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ProjectsSidebar - Left navigation sidebar for the projects dashboard
/// Contains logo, navigation buttons, and settings
class ProjectsSidebar extends StatelessWidget {
  const ProjectsSidebar({this.onSearchTap, this.onSettingsTap, super.key});
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) => Container(
    width: 64,
    decoration: const BoxDecoration(
      color: Color(0xFF161B22),
      border: Border(right: BorderSide(color: Color(0xFF30363d))),
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
              color: const Color(0xFF0d0df2).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.terminal,
              color: Color(0xFF0d0df2),
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
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: const Color(0xFF0d0df2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_open,
                    color: Color(0xFF0d0df2),
                    size: 24,
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
                    onTap: onSearchTap,
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF8b949e),
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
                onTap: onSettingsTap ?? () => context.go('/settings'),
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.settings,
                    color: Color(0xFF8b949e),
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
