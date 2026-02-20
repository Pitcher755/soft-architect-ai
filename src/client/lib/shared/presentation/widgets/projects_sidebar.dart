import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../features/project_shell/presentation/providers/project_providers.dart';
import '../../../features/settings/presentation/providers/settings_providers.dart'
    show lastProjectProvider;
import 'global_search_dialog.dart';

class ProjectsSidebar extends ConsumerStatefulWidget {
  const ProjectsSidebar({this.onSearchTap, this.onSettingsTap, super.key});

  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  @override
  ConsumerState<ProjectsSidebar> createState() => _ProjectsSidebarState();
}

class _ProjectsSidebarState extends ConsumerState<ProjectsSidebar> {
  /// Show dialog to open a project from directory path using file picker
  Future<void> _showOpenProjectDialog() async {
    // Use file picker to select directory
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '📁 Selecciona el directorio del proyecto',
      lockParentWindow: true,
    );

    // Handle cancellation (result will be null if user cancels)
    if (result == null) {
      return;
    }

    if (result.isNotEmpty) {
      final projectDir = Directory(result);

      if (!projectDir.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ El directorio no existe'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Extract project name from path
      final projectName = result.split('/').last.isEmpty
          ? result.split('/')[result.split('/').length - 2]
          : result.split('/').last;

      // Add project to projects list
      await ref
          .read(projectsProvider.notifier)
          .addProject(projectName, result, 'Proyecto abierto desde $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Proyecto "$projectName" añadido'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to project
        context.go(
          Uri(
            path: '/project-shell',
            queryParameters: {'path': result},
          ).toString(),
        );
      }
    }
  }

  /// Exit application safely
  Future<void> _exitApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Salir de la Aplicación'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar SoftArchitect AI?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Close the application safely
      exit(0);
    }
  }

  /// Close current project (navigate to workspace)
  Future<void> _closeCurrentProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Cerrar Proyecto'),
        content: const Text('¿Estás seguro de que deseas cerrar el proyecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        context.go('/workspace');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Proyecto cerrado'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

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
          // Menu Button (File Menu) - Professional IDE style
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'open') {
                  _showOpenProjectDialog();
                } else if (value == 'settings') {
                  context.go('/settings');
                } else if (value == 'close') {
                  _closeCurrentProject();
                } else if (value == 'exit') {
                  _exitApplication();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'open',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 18),
                      SizedBox(width: 12),
                      Text('Abrir Proyecto'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_rounded, size: 18),
                      SizedBox(width: 12),
                      Text('Ajustes'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'close',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cerrar Proyecto',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'exit',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.exit_to_app_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Salir',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
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
                        : () {},
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
