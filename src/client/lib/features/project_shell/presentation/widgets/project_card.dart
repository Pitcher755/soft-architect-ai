import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/models/project_phase.dart';
import '../providers/project_providers.dart';

/// ProjectCard - Displays a single project in the dashboard grid
/// Shows project icon, name, phase badge, path, and modification date
///
/// Features:
/// - Left click: Open project
/// - Right click: Delete project (with confirmation)
/// - Visual indicator for missing projects (grayed out)
/// - Real-time progress tracking from .softarchitect/status.json
class ProjectCard extends ConsumerWidget {
  const ProjectCard({
    required this.name,
    required this.icon,
    required this.path,
    required this.modified,
    required this.onTap,
    required this.projectId,
    required this.isMissing,
    // Deprecated: these parameters are calculated from the provider
    this.iconColor,
    this.phase,
    this.phaseColor,
    this.progress,
    super.key,
  });

  final String name;
  final IconData icon;
  @Deprecated('Use projectStatusProvider to get phase color')
  final Color? iconColor;
  @Deprecated('Use projectStatusProvider to get phase name')
  final String? phase;
  @Deprecated('Use projectStatusProvider to get phase color')
  final Color? phaseColor;
  @Deprecated('Use projectStatusProvider to get progress')
  final double? progress;
  final String path;
  final String modified;
  final VoidCallback onTap;
  final String projectId;
  final bool isMissing;

  /// Shortens the path showing only the folder name or last segments
  String _getShortPath(String fullPath) {
    if (fullPath.isEmpty) {
      return '';
    }

    // If it contains /, take the last segment (folder name)
    final segments = fullPath.split('/');
    final lastSegment = segments.lastWhere(
      (s) => s.isNotEmpty,
      orElse: () => fullPath,
    );

    // If the last segment is too long, abbreviate
    if (lastSegment.length > 20) {
      return '${lastSegment.substring(0, 17)}...';
    }

    return lastSegment;
  }

  /// Gets the ProjectPhase based on the phase name
  /// Returns ProjectPhase.root by default if not found
  ProjectPhase _getPhaseByName(String phaseName) {
    // Search in all phases
    for (final phase in ProjectPhase.all) {
      if (phase.name.toLowerCase() == phaseName.toLowerCase()) {
        return phase;
      }
    }

    // For "Proyecto Completado" or phases not found
    if (phaseName.toLowerCase().contains('completado')) {
      // Return the last phase with appropriate color
      return ProjectPhase.all.last;
    }

    // By default return the root phase
    return ProjectPhase.root;
  }

  /// Maps project phase to appropriate icon
  /// Returns different icons based on development stage
  IconData _getIconForPhase(ProjectPhase phase) => phase.icon;

  /// Shows a context menu with project options
  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    // Protect guide projects (mock://)
    final isGuideProject = path.startsWith('mock://');
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay == null) {
      return;
    }

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        // Rename option (disabled for guide projects)
        PopupMenuItem<String>(
          value: 'rename',
          enabled: !isGuideProject,
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 18,
                color: isGuideProject
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                'Cambiar Nombre',
                style: TextStyle(
                  color: isGuideProject
                      ? AppColors.textSecondary.withValues(alpha: 0.5)
                      : AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
        // Delete option (disabled for guide projects)
        PopupMenuItem<String>(
          value: 'delete',
          enabled: !isGuideProject,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: isGuideProject
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : Colors.redAccent,
              ),
              const SizedBox(width: 12),
              Text(
                'Eliminar',
                style: TextStyle(
                  color: isGuideProject
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'rename' && context.mounted) {
      await _showRenameDialog(context, ref);
    } else if (result == 'delete' && context.mounted) {
      await _showDeleteConfirmationDialog(context, ref);
    }
  }

  /// Shows a dialog to rename the project
  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: name);
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✏️ Cambiar Nombre'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ingrese el nuevo nombre del proyecto:'),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre del proyecto',
                  hintText: 'Ej: mi-proyecto',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  if (value.length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
                    return 'Solo letras, números, guiones y guiones bajos';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName != null && newName != name && context.mounted) {
      try {
        // Rename in the repository
        await ref
            .read(projectsProvider.notifier)
            .renameProject(projectId, newName);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Proyecto renombrado a "$newName"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } on Exception catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al renombrar: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  /// Shows a confirmation dialog to delete the project
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Eliminar Proyecto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Eliminar proyecto "$name"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se eliminará el directorio y todos sus archivos.',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Delete project directory (forced delete - ignore if doesn't exist)
      try {
        final directory = Directory(path);
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      } on FileSystemException catch (e) {
        // Log warning but continue with database deletion
        // (cleanup ghost projects)
        debugPrint('⚠️ Warning: Could not delete directory: $e');
      }

      // Remove project from state
      // (always execute, even if directory delete failed)
      try {
        await ref.read(projectsProvider.notifier).deleteProject(projectId);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Proyecto "$name" eliminado'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } on Exception catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al eliminar de la base de datos: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the project status provider
    final statusAsync = ref.watch(projectStatusProvider(path));

    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine sizing based on screen width
    late double padding;
    late double iconSize;
    late double iconContainerSize;
    late double nameFontSize;
    late double pathFontSize;
    late double dateFontSize;
    late double pathIconSize;
    late double badgeFontSize;

    if (screenWidth < 500) {
      // Very small screens
      padding = 10;
      iconContainerSize = 24;
      iconSize = 14;
      nameFontSize = 11;
      pathFontSize = 8;
      dateFontSize = 7;
      pathIconSize = 10;
      badgeFontSize = 8;
    } else if (screenWidth < 800) {
      // Small to medium screens
      padding = 12;
      iconContainerSize = 28;
      iconSize = 16;
      nameFontSize = 13;
      pathFontSize = 9;
      dateFontSize = 8;
      pathIconSize = 11;
      badgeFontSize = 9;
    } else {
      // Large screens (default)
      padding = 16;
      iconContainerSize = 32;
      iconSize = 18;
      nameFontSize = 16;
      pathFontSize = 11;
      dateFontSize = 10;
      pathIconSize = 12;
      badgeFontSize = 10;
    }

    // Obtener fase y progreso del provider o usar valores por defecto
    final currentPhase = statusAsync.maybeWhen(
      data: (progress) => _getPhaseByName(progress.faseActual),
      orElse: () => _getPhaseByName(phase ?? ProjectPhase.root.name),
    );

    final actualPhaseColor = currentPhase.color;
    final actualIconColor = currentPhase.color; // Always use phase color

    // For guide projects, show "Quick Start" instead of phase name
    final isGuideProject = path.startsWith('mock://');
    final actualPhaseName = isGuideProject
        ? ProjectPhase.quickStart.name
        : statusAsync.maybeWhen(
            data: (progress) => progress.faseActual,
            orElse: () => phase ?? ProjectPhase.root.name,
          );

    final actualProgress = statusAsync.maybeWhen(
      data: (progress) => progress.porcentajeCompletado / 100,
      orElse: () => progress ?? 0.0,
    );

    return AspectRatio(
      aspectRatio: 1.9,
      child: GestureDetector(
        onSecondaryTapDown: (details) =>
            _showContextMenu(context, ref, details.globalPosition),
        child: Tooltip(
          message: isMissing
              ? '⚠️ Directorio faltante. Clic derecho para eliminar.'
              : 'Clic derecho para opciones | Clic izquierdo para abrir',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isMissing ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isMissing
                      ? AppColors.surfaceBg.withValues(alpha: 0.5)
                      : AppColors.surfaceBg,
                  border: Border.all(
                    color: isMissing
                        ? actualPhaseColor.withValues(alpha: 0.2)
                        : actualPhaseColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(padding),
                child: Opacity(
                  opacity: isMissing ? 0.6 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- Top section ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon and phase badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: iconContainerSize,
                                  height: iconContainerSize,
                                  decoration: BoxDecoration(
                                    color: actualIconColor.withValues(
                                      alpha: isMissing ? 0.05 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    _getIconForPhase(currentPhase),
                                    color: isMissing
                                        ? actualIconColor.withValues(alpha: 0.5)
                                        : actualIconColor,
                                    size: iconSize,
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: actualPhaseColor.withValues(
                                          alpha: isMissing ? 0.05 : 0.1,
                                        ),
                                        border: Border.all(
                                          color: actualPhaseColor.withValues(
                                            alpha: isMissing ? 0.2 : 0.4,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        actualPhaseName,
                                        style: TextStyle(
                                          fontSize: badgeFontSize,
                                          fontFamily: 'Courier',
                                          color: actualPhaseColor.withValues(
                                            alpha: isMissing ? 0.5 : 1.0,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Missing indicator badge
                                    if (isMissing)
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.warning,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (actualProgress > 0) ...[
                              const SizedBox(height: 4),
                              Builder(
                                builder: (context) {
                                  final progressPercent =
                                      (actualProgress.clamp(0.0, 1.0) * 100)
                                          .toInt();
                                  return Text(
                                    'Doc $progressPercent%',
                                    style: TextStyle(
                                      fontSize: badgeFontSize,
                                      fontFamily: 'Courier',
                                      color:
                                          AppColors.textSecondary.withValues(
                                        alpha: isMissing ? 0.5 : 1.0,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                            const Spacer(),
                            // Project name
                            Text(
                              isMissing ? '$name (faltante)' : name,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.w600,
                                color: isMissing
                                    ? AppColors.textMain.withValues(alpha: 0.5)
                                    : AppColors.textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      // --- Bottom metadata bar ---
                      Container(
                        padding: EdgeInsets.only(
                          top: screenWidth < 500
                              ? 6
                              : screenWidth < 800
                              ? 8
                              : 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: actualPhaseColor.withValues(
                                alpha: isMissing ? 0.15 : 0.3,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Path (left side)
                            Expanded(
                              flex: 2,
                              child: Tooltip(
                                message: path,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: pathIconSize,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: isMissing ? 0.3 : 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _getShortPath(path),
                                        style: TextStyle(
                                          fontSize: pathFontSize,
                                          fontFamily: 'Courier',
                                          color: AppColors.textSecondary
                                              .withValues(
                                                alpha: isMissing ? 0.3 : 1.0,
                                              ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Modified date (right side)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: pathIconSize,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: isMissing ? 0.3 : 1.0,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  modified,
                                  style: TextStyle(
                                    fontSize: dateFontSize,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: isMissing ? 0.3 : 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
