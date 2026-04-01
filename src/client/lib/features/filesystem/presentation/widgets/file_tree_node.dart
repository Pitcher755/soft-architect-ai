import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../domain/entities/file_node.dart';

/// A widget representing a single node in the file tree.
///
/// Displays a file or directory with proper
/// indentation, icon, and selection state.
/// Handles expand/collapse for directories and selection for files.
class FileTreeNode extends StatelessWidget {
  /// Creates a file tree node widget.
  const FileTreeNode({
    required this.node,
    required this.depth,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.onToggle,
    super.key,
  });

  /// The file or directory node to render.
  final FileNode node;

  /// Depth in the tree (for indentation).
  final int depth;

  /// Whether this node is currently selected.
  final bool isSelected;

  /// Whether this directory node is expanded.
  final bool isExpanded;

  /// Callback when this node is tapped (select or expand/collapse).
  final VoidCallback onTap;

  /// Callback when the expand/collapse arrow is tapped (only for directories).
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 6 + (depth * 18),
          right: 6,
          top: 2,
          bottom: 2,
        ),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : null,
        child: Row(
          children: [
            // Expand/collapse arrow for directories
            SizedBox(
              width: 16,
              child: node.isDirectory
                  ? GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 16,
                        color: c.textSecondary,
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: 4),
            // File or folder icon
            _buildFolderIcon(node, c.textSecondary),
            const SizedBox(width: 6),
            // Node name
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.primary : c.textSecondary,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the icon widget for a file or folder node.
  Widget _buildFolderIcon(FileNode node, Color fileIconColor) {
    if (!node.isDirectory) {
      return Icon(Icons.description, size: 14, color: fileIconColor);
    }
    final phaseColor = _getPhaseColorForPath(node.name);
    return CustomPaint(
      size: const Size(14, 14),
      painter: CustomFolderIconPainter(
        strokeColor: phaseColor,
        fillColor: phaseColor.withValues(alpha: 0.15),
      ),
    );
  }

  /// Returns the phase color for a folder name based on naming convention.
  Color _getPhaseColorForPath(String folderName) {
    final name = folderName.toUpperCase();
    if (name.contains('ROOT') || name.startsWith('00-')) {
      return AppColors.dirRoot;
    } else if (name.contains('CONTEXT') || name.startsWith('10-')) {
      return AppColors.dirContext;
    } else if (name.contains('REQUIREMENTS') || name.startsWith('20-')) {
      return AppColors.dirRequirements;
    } else if (name.contains('ARCHITECTURE') || name.startsWith('30-')) {
      return AppColors.dirArchitecture;
    } else if (name.contains('UI_UX') ||
        name.contains('UI') ||
        name.startsWith('35-')) {
      return AppColors.dirUiUx;
    } else if (name.contains('PLANNING') || name.startsWith('40-')) {
      return AppColors.dirPlanning;
    } else if (name.contains('META') || name.startsWith('99-')) {
      return AppColors.dirMeta;
    }
    return AppColors.dirRoot;
  }
}

/// Custom painter for folder icon with colored outline and transparent fill.
class CustomFolderIconPainter extends CustomPainter {
  /// Creates a painter for folder icons.
  CustomFolderIconPainter({required this.strokeColor, required this.fillColor});

  /// Outline color.
  final Color strokeColor;

  /// Fill color.
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final bodyRect = Rect.fromLTWH(1, 5, size.width - 2, size.height - 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(1)),
      paint,
    );
    const tabRect = Rect.fromLTWH(1, 4, 6, 3);
    canvas
      ..drawRect(tabRect, paint)
      ..drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(1)),
        strokePaint,
      )
      ..drawRect(tabRect, strokePaint);
  }

  @override
  bool shouldRepaint(CustomFolderIconPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.fillColor != fillColor;
}
