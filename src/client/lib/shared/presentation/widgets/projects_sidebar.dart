import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../features/settings/presentation/providers/settings_providers.dart';
import 'global_search_dialog.dart';

class ProjectsSidebar extends ConsumerStatefulWidget {
  const ProjectsSidebar({this.onSearchTap, this.onSettingsTap, super.key});

  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  @override
  ConsumerState<ProjectsSidebar> createState() => _ProjectsSidebarState();
}

class _ProjectsSidebarState extends ConsumerState<ProjectsSidebar> {
  @override
  Widget build(BuildContext context) {
    // Obtenemos la ruta actual para resaltar el icono activo
    // En tests sin GoRouter, usa '/' por defecto
    final router = GoRouter.maybeOf(context);
    final location =
        router?.routerDelegate.currentConfiguration.uri.toString() ?? '/';

    // Obtenemos el último proyecto abierto
    final lastProjectPath = ref.watch(lastProjectProvider);

    // Lógica de detección de ruta activa
    final isSettingsActive = location.startsWith('/settings');
    final isProjectShellActive = location.startsWith('/project-shell');
    // Workspace está activo si es exactamente /workspace
    final isWorkspaceActive = location == '/workspace';

    return Container(
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
                // 1. BOTÓN DE WORKSPACE (Proyectos)
                Tooltip(
                  message: 'Explorador de Proyectos',
                  child: _SidebarButton(
                    icon: Icons.folder_copy_outlined,
                    isActive: isWorkspaceActive,
                    color: AppColors.primary,
                    onTap: () => context.go('/workspace'),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. BOTÓN DE PROYECTO ACTIVO (Último proyecto abierto)
                Tooltip(
                  message: lastProjectPath != null
                      ? 'Proyecto: ${_extractProjectName(lastProjectPath)}'
                      : 'Ningún proyecto abierto',
                  child: _SidebarButton(
                    icon: Icons.smart_toy_outlined,
                    isActive: isProjectShellActive,
                    color: AppColors.primary,
                    onTap: lastProjectPath != null && !isProjectShellActive
                        ? () {
                            // Solo navega si NO está ya en un proyecto
                            context.go(
                              Uri(
                                path: '/project-shell',
                                queryParameters: {'path': lastProjectPath},
                              ).toString(),
                            );
                          }
                        : () {}, // Si ya está en proyecto o no hay último, no hace nada
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Search button
                Tooltip(
                  message: 'Búsqueda Global',
                  child: _SidebarButton(
                    icon: Icons.search,
                    isActive: false, // Dialog, no navegación
                    color: AppColors.textSecondary,
                    onTap:
                        widget.onSearchTap ??
                        () => GlobalSearchDialog.show(context),
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
              message: 'Configuración',
              child: _SidebarButton(
                icon: Icons.settings_outlined,
                isActive: isSettingsActive,
                // CAMBIO CLAVE: Usamos primary para que se ilumine en azul
                // al estar activo
                color: AppColors.primary,
                onTap: widget.onSettingsTap ?? () => context.go('/settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Extrae el nombre del proyecto del path completo.
  /// Ejemplo: '/home/user/projects/my-project' -> 'my-project'
  String _extractProjectName(String path) {
    final parts = path.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }
}

/// Widget auxiliar para botones de la sidebar
class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Si está activo, usamos el color pasado (primary).
    // Si no, usamos gris atenuado (textSecondary).
    final finalColor = isActive
        ? color
        : AppColors.textSecondary.withValues(alpha: 0.7);

    // Fondo sutil si está activo
    final bgColor = isActive
        ? color.withValues(alpha: 0.15)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: color.withValues(alpha: 0.3))
                : null,
          ),
          child: Icon(icon, color: finalColor, size: 24),
        ),
      ),
    );
  }
}
