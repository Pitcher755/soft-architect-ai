import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../domain/entities/directory_node.dart';
import '../notifiers/markdown_preview_notifier.dart';

/// FileSystemTreeWidget displays a collapsible directory tree structure.
///
/// Shows folders with expand/collapse functionality and files with selection highlight.
/// Integrates with FileSystemNotifier for state management.
class FileSystemTreeWidget extends ConsumerWidget {
  const FileSystemTreeWidget({
    required this.rootPath,
    required this.initialTree,
    super.key,
  });
  final String rootPath;
  final DirectoryNode initialTree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Root path should always be expanded to show its children
    final state = ref.watch(fileSystemNotifierProvider);
    final expandedPaths = {initialTree.path, ...state.expandedPaths};

    return SingleChildScrollView(
      child: _DirectoryTreeView(
        node: initialTree,
        level: 0,
        onFolderTap: (path) {
          ref.read(fileSystemNotifierProvider.notifier).toggleFolder(path);
        },
        onFileTap: (path) {
          // Select file in file system
          ref.read(fileSystemNotifierProvider.notifier).selectFile(path);
          // Load preview in markdown preview widget
          ref.read(markdownPreviewNotifierProvider.notifier).loadFile(path);
        },
        expandedPaths: expandedPaths,
        selectedFile: state.selectedFile,
      ),
    );
  }
}

/// _DirectoryTreeView is a recursive helper widget for displaying directory tree.
///
/// Renders a single node and its children (if expanded).
class _DirectoryTreeView extends StatelessWidget {
  const _DirectoryTreeView({
    required this.node,
    required this.level,
    required this.onFolderTap,
    required this.onFileTap,
    required this.expandedPaths,
    required this.selectedFile,
  });

  final DirectoryNode node;
  final int level;
  final Function(String) onFolderTap;
  final Function(String) onFileTap;
  final Set<String> expandedPaths;
  final String? selectedFile;

  bool get isExpanded => expandedPaths.contains(node.path);
  bool get isSelected => selectedFile == node.path;

  // Constants for styling
  static const double _indentPerLevel = 16;
  static const double _iconSize = 18;
  static const double _horizontalPadding = 8;
  static const double _verticalPadding = 4;
  static const double _iconSpacing = 8;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildNodeTile(),
      if (node.isDirectory && isExpanded) ...node.children.map(_buildChildNode),
    ],
  );

  Widget _buildNodeTile() => Padding(
    padding: EdgeInsets.only(left: level * _indentPerLevel),
    child: InkWell(
      onTap: _handleNodeTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _verticalPadding,
          horizontal: _horizontalPadding,
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: _iconSpacing),
            _buildNodeName(),
          ],
        ),
      ),
    ),
  );

  Widget _buildIcon() {
    if (node.isDirectory) {
      return Icon(
        isExpanded ? Icons.folder_open : Icons.folder,
        size: _iconSize,
        color: Colors.blue,
      );
    }
    return const Icon(Icons.description, size: _iconSize, color: Colors.grey);
  }

  Widget _buildNodeName() => Flexible(
    child: Text(
      node.name,
      style: TextStyle(
        color: isSelected ? Colors.cyan : Colors.white,
        backgroundColor: isSelected ? Colors.blue.withOpacity(0.3) : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );

  Widget _buildChildNode(DirectoryNode child) => _DirectoryTreeView(
    node: child,
    level: level + 1,
    onFolderTap: onFolderTap,
    onFileTap: onFileTap,
    expandedPaths: expandedPaths,
    selectedFile: selectedFile,
  );

  void _handleNodeTap() {
    if (node.isDirectory) {
      onFolderTap(node.path);
    } else {
      onFileTap(node.path);
    }
  }
}
