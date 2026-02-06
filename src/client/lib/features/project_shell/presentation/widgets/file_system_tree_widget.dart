import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../domain/entities/directory_node.dart';

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
          ref.read(fileSystemNotifierProvider.notifier).selectFile(path);
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

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Node itself (folder or file)
      Padding(
        padding: EdgeInsets.only(left: level * 16.0),
        child: InkWell(
          onTap: () {
            if (node.isDirectory) {
              onFolderTap(node.path);
            } else {
              onFileTap(node.path);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                // Expand/collapse icon (only for directories)
                if (node.isDirectory)
                  Icon(
                    isExpanded ? Icons.folder_open : Icons.folder,
                    size: 18,
                    color: Colors.blue,
                  )
                else
                  const Icon(Icons.description, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                // Node name (highlighted if selected)
                Flexible(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      color: isSelected ? Colors.cyan : Colors.white,
                      backgroundColor: isSelected
                          ? Colors.blue.withOpacity(0.3)
                          : null,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Children (if expanded)
      if (node.isDirectory && isExpanded)
        ...node.children.map(
          (child) => _DirectoryTreeView(
            node: child,
            level: level + 1,
            onFolderTap: onFolderTap,
            onFileTap: onFileTap,
            expandedPaths: expandedPaths,
            selectedFile: selectedFile,
          ),
        ),
    ],
  );
}
