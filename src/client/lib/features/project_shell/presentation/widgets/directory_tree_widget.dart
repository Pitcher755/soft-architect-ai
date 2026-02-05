// lib/features/project_shell/presentation/widgets/directory_tree_widget.dart
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../domain/entities/file_node.dart';

/// Widget: Expandable directory tree (VS Code style)
/// Displays hierarchical file structure with expand/collapse functionality.
///
/// Design inspiration: GitHub Dark theme with primary accent #0d0df2
/// - Sidebar background: #161B22
/// - Border color: #30363d
/// - Text secondary: #8b949e
class DirectoryTreeWidget extends StatefulWidget {
  const DirectoryTreeWidget({
    required this.root,
    required this.onFileSelected,
    super.key,
    this.selectedNode,
  });

  /// Root node of the file tree
  final FileNode root;

  /// Callback when a file is selected
  final ValueChanged<FileNode> onFileSelected;

  /// Currently selected node
  final FileNode? selectedNode;

  @override
  State<DirectoryTreeWidget> createState() => _DirectoryTreeWidgetState();
}

class _DirectoryTreeWidgetState extends State<DirectoryTreeWidget> {
  /// Tracks expanded directory nodes
  late final Set<String> _expanded;

  @override
  void initState() {
    super.initState();
    developer.log('DirectoryTreeWidget initialized with root expanded');
    _expanded = _getInitiallyExpandedNodes(widget.root);
  }

  /// Recursively collect all directory nodes that should be initially expanded
  Set<String> _getInitiallyExpandedNodes(FileNode node) =>
    <String>{node.id};

  @override
  Widget build(BuildContext context) {
    developer.log(
      'Building DirectoryTreeWidget with root: ${widget.root.name}',
    );

    return SingleChildScrollView(child: _buildTreeNode(widget.root));
  }

  /// Recursively builds tree nodes (directories and files)
  Widget _buildTreeNode(FileNode node) {
    const sidebarBg = Color(0xFF161B22);
    const borderDark = Color(0xFF30363d);
    const primary = Color(0xFF0d0df2);

    if (node.isDirectory && node.children.isNotEmpty) {
      final isExpanded =
          _expanded.contains(node.id) || node.id == widget.root.id;
      developer.log(
        'Building directory node: ${node.name}, '
        'isExpanded: $isExpanded, expanded set: $_expanded',
      );

      return ExpansionTile(
        key: ValueKey(node.id),
        title: _buildNodeTitle(node, isExpanded),
        leading: Icon(
          isExpanded ? Icons.folder_open : Icons.folder,
          size: 18,
          color: primary,
        ),
        backgroundColor: sidebarBg.withValues(alpha: 0.5),
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          developer.log('Directory expanded: ${node.name} = $expanded');
          setState(() {
            if (expanded) {
              _expanded.add(node.id);
            } else {
              _expanded.remove(node.id);
            }
          });
        },
        children: node.children.map(_buildTreeNode).toList(),
      );
    }
    // File node
    final isSelected = widget.selectedNode?.id == node.id;

    return ListTile(
      key: ValueKey(node.id),
      title: _buildNodeTitle(node, false),
      leading: _buildFileIcon(node.name),
      selected: isSelected,
      selectedTileColor: primary.withValues(alpha: 0.2),
      selectedColor: primary,
      tileColor: Colors.transparent,
      hoverColor: borderDark.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        developer.log('File selected: ${node.name}');
        widget.onFileSelected(node);
      },
    );
  }

  /// Builds the title text for a node
  Widget _buildNodeTitle(FileNode node, bool isExpanded) {
    const textSecondary = Color(0xFF8b949e);
    const textWhite = Color(0xFFE6EDF3);

    return Text(
      node.name,
      style: TextStyle(
        color: node.isDirectory ? textWhite : textSecondary,
        fontSize: 13,
        fontWeight: node.isDirectory ? FontWeight.w500 : FontWeight.w400,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Returns appropriate icon for file type
  Widget _buildFileIcon(String filename) {
    const textSecondary = Color(0xFF8b949e);
    final ext = filename.split('.').last.toLowerCase();

    IconData icon;
    var color = textSecondary;

    // Determine icon based on file extension
    switch (ext) {
      case 'md':
        icon = Icons.description;
        break;
      case 'dart':
        icon = Icons.code;
        color = const Color(0xFF00D2FC); // Dart blue
        break;
      case 'py':
        icon = Icons.code;
        color = const Color(0xFF3776AB); // Python blue
        break;
      case 'json':
      case 'yaml':
      case 'yml':
        icon = Icons.settings;
        break;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        icon = Icons.image;
        break;
      default:
        icon = Icons.insert_drive_file;
    }

    return Icon(icon, size: 16, color: color);
  }

  @override
  void dispose() {
    developer.log('DirectoryTreeWidget disposed');
    super.dispose();
  }
}
