import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_node.dart';
import 'file_tree_node.dart';

/// A widget that displays a hierarchical file tree structure.
///
/// Features:
/// - Recursive directory tree rendering
/// - Expand/collapse directories
/// - File/folder selection with visual feedback
/// - Phase-colored folder icons
/// - Scrollable and responsive layout
///
/// This widget is agnostic to the data source and accepts a root FileNode.
class FileTreeWidget extends StatefulWidget {
  const FileTreeWidget({
    required this.onFileSelected,
    required this.rootNode,
    super.key,
  });

  /// Callback triggered when a file or folder is selected.
  final ValueChanged<FileNode> onFileSelected;

  /// The root node of the file tree to display.
  final FileNode rootNode;

  @override
  State<FileTreeWidget> createState() => _FileTreeWidgetState();
}

/// State for FileTreeWidget. Manages selection and expansion state.
class _FileTreeWidgetState extends State<FileTreeWidget> {
  /// Currently selected file node.
  late FileNode _selectedNode;
  /// Set of expanded folder IDs.
  final Set<String> _expandedFolders = {};

  @override
  void initState() {
    super.initState();
    _selectedNode = widget.rootNode;
    _expandedFolders.add('root');
  }

  /// Builds the main widget tree.
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
                  // TODO: Implement reload from backend
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

  /// Recursively builds the file tree.
  Widget _buildFileTree(FileNode node, int depth) {
    final isFolder = node.children.isNotEmpty;
    final isExpanded = _expandedFolders.contains(node.id);
    final isSelected = _selectedNode.id == node.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FileTreeNode(
          node: node,
          depth: depth,
          isSelected: isSelected,
          isExpanded: isExpanded,
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
          onToggle: isFolder
              ? () {
                  setState(() {
                    if (isExpanded) {
                      _expandedFolders.remove(node.id);
                    } else {
                      _expandedFolders.add(node.id);
                    }
                  });
                }
              : null,
        ),
        if (isFolder && isExpanded)
          ...node.children.map((child) => _buildFileTree(child, depth + 1)),
      ],
    );
  }
}
