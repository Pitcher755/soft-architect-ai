import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../domain/entities/file_node.dart';

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
  final Set<String> _expandedDirs = {};

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(child: _buildTreeNode(widget.root));

  /// Recursively build tree nodes
  Widget _buildTreeNode(FileNode node) {
    const hoverBg = Color(0xFF21262d);
    const selectedBg = Color(0xFF388bfd);
    const selectedFg = Color(0xFFFFFFFF);
    const textPrimary = Color(0xFFE6EDF3);
    const textSecondary = Color(0xFF8b949e);
    const iconColor = Color(0xFF79c0ff);
    const folderColor = Color(0xFF79c0ff);

    final isSelected = widget.selectedNode?.id == node.id;
    final isExpanded = _expandedDirs.contains(node.id);

    if (!node.isDirectory) {
      // File node
      return Container(
        color: isSelected ? selectedBg : Colors.transparent,
        child: InkWell(
          onTap: () {
            developer.log('File selected: ${node.name}');
            widget.onFileSelected(node);
          },
          hoverColor: hoverBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: _getFileIcon(
                    node.name,
                    color: isSelected ? selectedFg : iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      color: isSelected ? selectedFg : textPrimary,
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
          hoverColor: hoverBg,
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
                    color: textSecondary,
                  ),
                ),
                // Folder icon
                const Icon(Icons.folder, size: 16, color: folderColor),
                const SizedBox(width: 8),
                // Folder name
                Expanded(
                  child: Text(
                    node.name,
                    style: const TextStyle(
                      color: textPrimary,
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
