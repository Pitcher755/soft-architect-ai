// lib/features/project_shell/presentation/screens/project_shell_screen.dart
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/file_node.dart';
import '../notifiers/project_shell_notifier.dart';
import '../providers/project_providers.dart';
import '../widgets/directory_tree_widget.dart';
import '../widgets/markdown_preview_widget.dart';

/// Main screen: IDE-like project shell
///
/// Layout:
/// - Top header with app title and controls
/// - Left sidebar: Directory tree view
/// - Right panel: Markdown/file preview
/// - Bottom: Status bar (optional)
///
/// Design inspiration: GitHub/VS Code dark interface
class ProjectShellScreen extends ConsumerStatefulWidget {
  const ProjectShellScreen({super.key});

  @override
  ConsumerState<ProjectShellScreen> createState() => _ProjectShellScreenState();
}

class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  /// Currently selected file node
  FileNode? _selectedNode;

  /// Loaded file content
  String? _fileContent;

  @override
  void initState() {
    super.initState();
    developer.log('ProjectShellScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building ProjectShellScreen');

    final projectState = ref.watch(projectShellProvider);

    return Scaffold(
      appBar: _buildAppBar(projectState),
      body: projectState.selectedProject == null
          ? _buildNoProjectView()
          : _buildProjectView(projectState),
    );
  }

  /// Builds app bar with title and controls
  PreferredSizeWidget _buildAppBar(ProjectShellState state) {
    const mainBg = Color(0xFF0D1117);
    const borderDark = Color(0xFF30363d);
    const textMain = Color(0xFFE6EDF3);
    const primary = Color(0xFF0d0df2);

    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.terminal, color: primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SoftArchitect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textMain,
                ),
              ),
              if (state.selectedProject != null)
                Text(
                  state.selectedProject!.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8b949e),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: mainBg,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: borderDark, height: 1),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => developer.log('Info button pressed'),
          color: const Color(0xFF8b949e),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// View when no project is selected
  Widget _buildNoProjectView() {
    const textSecondary = Color(0xFF8b949e);

    developer.log('Displaying no project selected view');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No project selected',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Select or create a project to begin',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }

  /// Main project view with sidebar and preview
  Widget _buildProjectView(ProjectShellState state) {
    const sidebarBg = Color(0xFF161B22);
    const mainBg = Color(0xFF0D1117);
    const borderDark = Color(0xFF30363d);

    return Container(
      color: mainBg,
      child: Row(
        children: [
          // Left sidebar: Directory tree
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: sidebarBg,
              border: Border(right: BorderSide(color: borderDark)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.folder,
                        size: 18,
                        color: Color(0xFF0d0df2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.selectedProject!.name,
                          style: const TextStyle(
                            color: Color(0xFFE6EDF3),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Directory tree
                Expanded(
                  child: DirectoryTreeWidget(
                    root: _buildMockTree(),
                    onFileSelected: _onFileSelected,
                    selectedNode: _selectedNode,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(width: 1, color: borderDark),
          // Right panel: Preview
          Expanded(
            child: Container(
              color: mainBg,
              child: MarkdownPreviewWidget(
                content: _fileContent,
                filename: _selectedNode?.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Callback when file is selected
  void _onFileSelected(FileNode node) {
    developer.log('File selected: ${node.name} (${node.path})');

    setState(() {
      _selectedNode = node;
      // TODO: Load file content asynchronously
      // In real implementation, call repository to read file
      _fileContent = _getMockContent(node.name);
    });
  }

  /// Mock content for demonstration
  String _getMockContent(String filename) {
    if (filename.endsWith('.md')) {
      return '''# $filename

## Introduction
This is a mock markdown preview for **$filename**.

### Features
- 📁 File tree navigation
- 🔍 Full-text search
- 📝 Real-time editing
- 🎨 Syntax highlighting

> **Note:** This is demonstration content.

```dart
void main() {
  print('Hello from SoftArchitect!');
}
```

## Next Steps
1. Implement file I/O
2. Connect to database
3. Add search functionality
4. Enable code editing
''';
    }

    return '''# $filename

## Empty File
Select a text or markdown file to preview its content.
''';
  }

  /// Mock file tree structure (replace with real data from repository)
  FileNode _buildMockTree() => const FileNode(
        id: 'root',
        name: 'Project Root',
        path: '/',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file-readme',
            name: 'README.md',
            path: '/README.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'dir-docs',
            name: 'docs',
            path: '/docs',
            isDirectory: true,
            children: [
              FileNode(
                id: 'file-arch',
                name: 'ARCHITECTURE.md',
                path: '/docs/ARCHITECTURE.md',
                isDirectory: false,
              ),
              FileNode(
                id: 'file-setup',
                name: 'SETUP.md',
                path: '/docs/SETUP.md',
                isDirectory: false,
              ),
            ],
          ),
          FileNode(
            id: 'dir-src',
            name: 'src',
            path: '/src',
            isDirectory: true,
            children: [
              FileNode(
                id: 'file-main',
                name: 'main.dart',
                path: '/src/main.dart',
                isDirectory: false,
              ),
              FileNode(
                id: 'dir-features',
                name: 'features',
                path: '/src/features',
                isDirectory: true,
                children: [
                  FileNode(
                    id: 'file-feature1',
                    name: 'feature.dart',
                    path: '/src/features/feature.dart',
                    isDirectory: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  @override
  void dispose() {
    developer.log('ProjectShellScreen disposed');
    super.dispose();
  }
}
