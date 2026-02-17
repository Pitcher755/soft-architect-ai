import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../filesystem/domain/entities/file_node.dart';

/// A hierarchical file tree widget styled like VS Code Explorer.
///
/// Features:
/// - Expandable/collapsible directories
/// - File/folder icons
/// - Selection highlighting
/// - Context menu support (future)
class DirectoryTreeWidget extends StatefulWidget {
  const DirectoryTreeWidget({
    required this.root,
    required this.onFileSelected,
    this.selectedNode,
    super.key,
  });

  /// Root node of the file tree
  final FileNode root;

  /// Callback when file is selected
  final void Function(FileNode) onFileSelected;

  /// Currently selected node
  final FileNode? selectedNode;

  @override
  State<DirectoryTreeWidget> createState() => _DirectoryTreeWidgetState();
}

class _DirectoryTreeWidgetState extends State<DirectoryTreeWidget> {
  /// Track expanded directories
  late final Set<String> _expandedDirs;

  @override
  void initState() {
    super.initState();
    // Expand root by default
    _expandedDirs = {widget.root.id};
  }

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(child: _buildTreeNode(widget.root));

  /// Recursively build tree nodes
  Widget _buildTreeNode(FileNode node) {
    final isSelected = widget.selectedNode?.id == node.id;
    final isExpanded = _expandedDirs.contains(node.id);

    if (!node.isDirectory) {
      // File node
      return Container(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.3)
            : Colors.transparent,
        child: InkWell(
          onTap: () {
            developer.log('File selected: ${node.name}');
            widget.onFileSelected(node);
          },
          hoverColor: AppColors.surfaceLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: _getFileIcon(
                    node.name,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : AppColors.textMain,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Directory node
    final phaseColor = _getPhaseColor(node.name);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (_expandedDirs.contains(node.id)) {
                _expandedDirs.remove(node.id);
              } else {
                _expandedDirs.add(node.id);
              }
            });
            developer.log('Directory toggled: ${node.name}');
          },
          hoverColor: AppColors.surfaceLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Expand/collapse icon
                SizedBox(
                  width: 20,
                  child: Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                // Folder icon with phase color
                Icon(Icons.folder, size: 16, color: phaseColor),
                const SizedBox(width: 8),
                // Folder name
                Expanded(
                  child: Text(
                    node.name,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Children (if expanded)
        if (isExpanded && node.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: node.children.map(_buildTreeNode).toList(),
            ),
          ),
      ],
    );
  }

  /// Get phase color based on directory name
  Color _getPhaseColor(String dirName) {
    if (dirName.startsWith('00-')) {
      return AppColors.dirRoot;
    } else if (dirName.startsWith('10-')) {
      return AppColors.dirContext;
    } else if (dirName.startsWith('20-')) {
      return AppColors.dirRequirements;
    } else if (dirName.startsWith('30-')) {
      return AppColors.dirArchitecture;
    } else if (dirName.startsWith('35-')) {
      return AppColors.dirUiUx;
    } else if (dirName.startsWith('40-')) {
      return AppColors.dirPlanning;
    } else if (dirName.startsWith('99-')) {
      return AppColors.dirMeta;
    }
    return AppColors.primaryLight;
  }

  /// Get icon for file type
  Widget _getFileIcon(String filename, {required Color color}) {
    var icon = Icons.description;

    if (filename.endsWith('.md')) {
      icon = Icons.description;
    } else if (filename.endsWith('.dart')) {
      icon = Icons.code;
    } else if (filename.endsWith('.py')) {
      icon = Icons.code;
    } else if (filename.endsWith('.json')) {
      icon = Icons.data_object;
    } else if (filename.endsWith('.yaml') || filename.endsWith('.yml')) {
      icon = Icons.settings;
    } else if (filename.endsWith('.txt')) {
      icon = Icons.description;
    }

    return Icon(icon, size: 14, color: color);
  }
}
