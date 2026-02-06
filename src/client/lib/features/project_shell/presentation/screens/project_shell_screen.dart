import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/file_node.dart';
import '../widgets/directory_tree_widget.dart';
import '../widgets/markdown_preview_widget.dart';

/// Main IDE-like project shell with 3-column layout.
///
/// Layout Structure:
/// ```
/// ┌─────────────────────────────────────────────────┐
/// │ Top Bar: Project Info & Progress               │
/// ├────────┬──────────────────┬────────────────────┤
/// │        │                  │                    │
/// │ Files  │  Chat/Content    │  Preview Panel     │
/// │ Tree   │  (Placeholder)   │  (Markdown)        │
/// │        │                  │                    │
/// └────────┴──────────────────┴────────────────────┘
/// ```
///
/// Color Scheme: GitHub Dark Theme
/// - Background: #0D1117
/// - Sidebar: #161B22
/// - Primary: #0d0df2
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          // Top bar
          _buildAppBar(),

          // Main workspace (3 columns)
          Expanded(
            child: Row(
              children: [
                // Left: Directory tree
                _buildLeftPanel(),

                // Center: Chat placeholder
                Expanded(
                  child: Container(
                    color: const Color(0xFF0D1117),
                    child: const Center(
                      child: Text(
                        '[Chat Area - Sequential Chat Screen]',
                        style: TextStyle(
                          color: Color(0xFF8b949e),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Right: Preview panel
                _buildRightPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar with project info and progress
  Widget _buildAppBar() {
    const mainBg = Color(0xFF0D1117);
    const sidebarBg = Color(0xFF161B22);
    const borderDark = Color(0xFF30363d);
    const textMain = Color(0xFFE6EDF3);
    const textSecondary = Color(0xFF8b949e);
    const primary = Color(0xFF0d0df2);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: [
          // Project title
          const Icon(Icons.terminal, color: primary, size: 20),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SoftArchitect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textMain,
                ),
              ),
              Text(
                'Project Shell',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Path display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mainBg,
                border: Border.all(color: borderDark),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                '~/soft-architect-ai',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar (responsive)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'PROGRESS',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '12/25',
                      style: TextStyle(
                        color: primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    value: 12 / 25,
                    backgroundColor: borderDark,
                    color: primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Action buttons
          IconButton(
            icon: const Icon(
              Icons.chat_outlined,
              color: textSecondary,
              size: 20,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Chat Screen...'),
                  duration: Duration(milliseconds: 500),
                ),
              );
              Future.delayed(const Duration(milliseconds: 200), () {
                GoRouter.of(context).go('/chat');
              });
            },
            tooltip: 'Open Chat (HU-3.3)',
          ),
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: textSecondary,
              size: 20,
            ),
            onPressed: () => developer.log('Export clicked'),
            tooltip: 'Export project',
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: textSecondary,
              size: 20,
            ),
            onPressed: () => developer.log('Info clicked'),
            tooltip: 'Project info',
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Build left panel with directory tree
  Widget _buildLeftPanel() {
    const sidebarBg = Color(0xFF161B22);
    const borderDark = Color(0xFF30363d);
    const primary = Color(0xFF0d0df2);
    const textMain = Color(0xFFE6EDF3);

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(right: BorderSide(color: borderDark)),
      ),
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: borderDark)),
            ),
            child: const Row(
              children: [
                Icon(Icons.folder, size: 18, color: primary),
                SizedBox(width: 8),
                Text(
                  'Explorer',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // File tree
          Expanded(
            child: DirectoryTreeWidget(
              root: _buildMockTree(),
              onFileSelected: _onFileSelected,
              selectedNode: _selectedNode,
            ),
          ),
        ],
      ),
    );
  }

  /// Build right panel with markdown preview
  Widget _buildRightPanel() {
    const borderDark = Color(0xFF30363d);

    return Container(
      width: 350,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: borderDark)),
      ),
      child: MarkdownPreviewWidget(
        content: _fileContent,
        filename: _selectedNode?.name,
      ),
    );
  }

  /// Callback when file is selected
  void _onFileSelected(FileNode node) {
    developer.log('File selected: ${node.name}');
    setState(() {
      _selectedNode = node;
      _fileContent = _loadFileContent(node.name);
    });
  }

  /// Load mock file content
  String _loadFileContent(String filename) {
    if (filename.endsWith('.md')) {
      return '''# $filename

## Welcome to SoftArchitect

This is a demonstration of the **Project Shell** interface.

### Key Features
- 📁 File tree navigation
- 🔍 Full-text search
- 📝 Real-time preview
- 🎨 Syntax highlighting

### Architecture
The system follows **Clean Architecture** principles with:

1. **Domain Layer** - Pure business logic
2. **Data Layer** - Repository implementations
3. **Presentation Layer** - Flutter UI

### Next Steps
1. Implement file I/O
2. Connect to document database
3. Enable full-text search
4. Add code editing capabilities

> **Note:** This is demonstration content for the Project Shell.

```dart
void main() {
  print('Welcome to SoftArchitect!');
}
```

---

**Learn more:** Check the [README.md](../README.md) file.
''';
    }

    return '''# $filename

Select a markdown or text file to preview its contents here.
''';
  }

  /// Build mock file tree
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
        name: 'doc',
        path: '/doc',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file-arch',
            name: 'ARCHITECTURE.md',
            path: '/doc/ARCHITECTURE.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'file-setup',
            name: 'SETUP.md',
            path: '/doc/SETUP.md',
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
                id: 'file-feature',
                name: 'project_shell',
                path: '/src/features/project_shell',
                isDirectory: true,
              ),
            ],
          ),
        ],
      ),
      FileNode(
        id: 'dir-context',
        name: 'context',
        path: '/context',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file-manifesto',
            name: 'PROJECT_MANIFESTO.md',
            path: '/context/PROJECT_MANIFESTO.md',
            isDirectory: false,
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
