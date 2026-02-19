// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../providers/project_providers.dart';

/// ProjectCard - Displays a single project in the dashboard grid
/// Shows project icon, name, phase badge, path, and modification date
///
/// Features:
/// - Left click: Open project
/// - Right click: Delete project (with confirmation)
/// - Visual indicator for missing projects (grayed out)
class ProjectCard extends ConsumerWidget {
  const ProjectCard({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.phase,
    required this.phaseColor,
    required this.path,
    required this.modified,
    required this.onTap,
    required this.projectId,
    required this.isMissing,
    this.progress,
    super.key,
  });

  final String name;
  final IconData icon;
  final Color iconColor;
  final String phase;
  final Color phaseColor;
  final double? progress;
  final String path;
  final String modified;
  final VoidCallback onTap;
  final String projectId;
  final bool isMissing;

  /// Acorta la ruta mostrando solo el nombre de la carpeta o últimos segmentos
  String _getShortPath(String fullPath) {
    if (fullPath.isEmpty) {
      return '';
    }

    // Si contiene /, toma el último segmento (nombre de carpeta)
    final segments = fullPath.split('/');
    final lastSegment = segments.lastWhere(
      (s) => s.isNotEmpty,
      orElse: () => fullPath,
    );

    // Si el último segmento es muy largo, abrevia
    if (lastSegment.length > 20) {
      return '${lastSegment.substring(0, 17)}...';
    }

    return lastSegment;
  }

  /// Muestra un diálogo de confirmación para eliminar el proyecto
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
      // Delete project directory
      try {
        final directory = Directory(path);
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }

        // Remove project from state
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
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al eliminar: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return AspectRatio(
      aspectRatio: 1.9,
      child: GestureDetector(
        onSecondaryTap: isMissing
            ? null
            : () => _showDeleteConfirmationDialog(context, ref),
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
                        ? phaseColor.withValues(alpha: 0.2)
                        : phaseColor.withValues(alpha: 0.5),
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
                                    color: iconColor.withValues(
                                      alpha: isMissing ? 0.05 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isMissing
                                        ? iconColor.withValues(alpha: 0.5)
                                        : iconColor,
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
                                        color: phaseColor.withValues(
                                          alpha: isMissing ? 0.05 : 0.1,
                                        ),
                                        border: Border.all(
                                          color: phaseColor.withValues(
                                            alpha: isMissing ? 0.2 : 0.4,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        phase,
                                        style: TextStyle(
                                          fontSize: badgeFontSize,
                                          fontFamily: 'Courier',
                                          color: phaseColor.withValues(
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
                            if (progress != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Doc '
                                '${(progress!.clamp(0.0, 1.0) * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: badgeFontSize,
                                  fontFamily: 'Courier',
                                  color: AppColors.textSecondary.withValues(
                                    alpha: isMissing ? 0.5 : 1.0,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
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
                              color: phaseColor.withValues(
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
