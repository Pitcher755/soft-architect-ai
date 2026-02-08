import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_node.dart';

/// File tree widget - Displays project directory structure
///
/// Features:
/// - Recursive directory tree rendering with mock data
/// - Expand/collapse directories
/// - File selection with visual feedback
/// - Phase-colored folder icons
/// - Navigable to any file/folder
///
/// This widget is agnostic of data source and accepts file nodes as input.
class FileTreeWidget extends StatefulWidget {
  const FileTreeWidget({
    required this.onFileSelected,
    required this.rootNode,
    super.key,
  });

  /// Callback when a file/folder is selected
  final ValueChanged<FileNode> onFileSelected;

  /// Root file node to display
  final FileNode rootNode;

  @override
  State<FileTreeWidget> createState() => _FileTreeWidgetState();
}

class _FileTreeWidgetState extends State<FileTreeWidget> {
  /// Currently selected file node
  late FileNode _selectedNode;

  /// Expanded folders (by id)
  final Set<String> _expandedFolders = {};

  @override
  void initState() {
    super.initState();
    _selectedNode = widget.rootNode;
    _expandedFolders.add('root');
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(right: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      children: [
        // Header: EXPLORER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'EXPLORER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                color: AppColors.textSecondary,
                iconSize: 16,
                onPressed: () {
                  // Reload from backend
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // File tree content (scrollable)
        Expanded(
          child: SingleChildScrollView(
            child: _buildFileTree(widget.rootNode, 0),
          ),
        ),
      ],
    ),
  );

  /// Build recursive file tree widget
  Widget _buildFileTree(FileNode node, int depth) {
    final isFolder = node.children.isNotEmpty;
    final isExpanded = _expandedFolders.contains(node.id);
    final isSelected = _selectedNode.id == node.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node item
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedNode = node;
              if (isFolder) {
                if (isExpanded) {
                  _expandedFolders.remove(node.id);
                } else {
                  _expandedFolders.add(node.id);
                }
              }
            });
            widget.onFileSelected(node);
          },
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
                // Expand/collapse arrow
                SizedBox(
                  width: 16,
                  child: isFolder
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedFolders.remove(node.id);
                              } else {
                                _expandedFolders.add(node.id);
                              }
                            });
                          },
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(width: 4),

                // Icon with phase color
                _buildFolderIcon(node),
                const SizedBox(width: 6),

                // Name
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontFamily: 'JetBrains Mono',
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Children
        if (isFolder && isExpanded)
          ...node.children.map((child) => _buildFileTree(child, depth + 1)),
      ],
    );
  }

  /// Build folder icon with phase colors
  /// Detects phase from path (e.g., "10-CONTEXT" → dirContext color)
  Widget _buildFolderIcon(FileNode node) {
    if (!node.isDirectory) {
      return const Icon(
        Icons.description,
        size: 14,
        color: AppColors.textSecondary,
      );
    }

    final phaseColor = _getPhaseColorForPath(node.name);

    // Custom folder icon: outline + semi-transparent fill
    return CustomPaint(
      size: const Size(14, 14),
      painter: CustomFolderIconPainter(
        strokeColor: phaseColor,
        fillColor: phaseColor.withValues(alpha: 0.15),
      ),
    );
  }

  /// Get phase color from folder name
  /// Examples: "10-CONTEXT" → dirContext (yellow)
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
    // Default: generic phase color
    return AppColors.dirRoot;
  }
}

/// Custom painter for folder icon with colored outline and transparent fill
class CustomFolderIconPainter extends CustomPainter {
  CustomFolderIconPainter({required this.strokeColor, required this.fillColor});
  final Color strokeColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Folder shape: top tab + main body
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Main folder body (rounded rectangle)
    final bodyRect = Rect.fromLTWH(1, 5, size.width - 2, size.height - 6);

    // Draw filled folder
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(1)),
      paint,
    );

    // Draw folder tab (small rectangle at top)
    const tabRect = Rect.fromLTWH(1, 4, 6, 3);

    canvas.drawRect(tabRect, paint);

    // Draw outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(1)),
      strokePaint,
    );

    canvas.drawRect(tabRect, strokePaint);
  }

  @override
  bool shouldRepaint(CustomFolderIconPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.fillColor != fillColor;
}
