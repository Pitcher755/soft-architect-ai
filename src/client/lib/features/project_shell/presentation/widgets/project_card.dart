import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// ProjectCard - Displays a single project in the dashboard grid
/// Shows project icon, name, phase badge, path, and modification date
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.phase,
    required this.phaseColor,
    required this.path,
    required this.modified,
    required this.onTap,
    super.key,
  });
  final String name;
  final IconData icon;
  final Color iconColor;
  final String phase;
  final Color phaseColor;
  final String path;
  final String modified;
  final VoidCallback onTap;

  /// Acorta la ruta mostrando solo el nombre de la carpeta o últimos segmentos
  String _getShortPath(String fullPath) {
    if (fullPath.isEmpty) return '';

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

  @override
  Widget build(BuildContext context) {
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
    late double arrowIconSize;
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
      arrowIconSize = 14;
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
      arrowIconSize = 15;
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
      arrowIconSize = 16;
      badgeFontSize = 10;
    }

    // AspectRatio asegura que la tarjeta mantenga la forma apaisada internamente
    return AspectRatio(
      aspectRatio: 1.9,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(padding),
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
                              color: iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(icon, color: iconColor, size: iconSize),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: phaseColor.withValues(alpha: 0.1),
                              border: Border.all(
                                color: phaseColor.withValues(alpha: 0.4),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              phase,
                              style: TextStyle(
                                fontSize: badgeFontSize,
                                fontFamily: 'Courier',
                                color: phaseColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(), // Empuja el título al centro visual
                      // Project name
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Project path with tooltip
                      Tooltip(
                        message: path,
                        child: SizedBox(
                          height: pathFontSize + 4,
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: pathIconSize,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _getShortPath(path),
                                  style: TextStyle(
                                    fontSize: pathFontSize,
                                    fontFamily: 'Courier',
                                    color: AppColors.textSecondary,
                                    height: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                // --- Bottom section with metadata ---
                Container(
                  padding: EdgeInsets.only(
                    top: screenWidth < 500
                        ? 4
                        : screenWidth < 800
                        ? 6
                        : 8,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Mod: $modified',
                          style: TextStyle(
                            fontSize: dateFontSize,
                            color: AppColors.textSecondary,
                            height: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: arrowIconSize,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
