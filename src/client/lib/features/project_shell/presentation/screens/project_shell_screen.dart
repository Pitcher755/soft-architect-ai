import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/notifiers/chat_notifier.dart';
import '../../../chat/presentation/widgets/error_banner_widget.dart';
import '../../../chat/presentation/widgets/message_bubble_widget.dart';
import '../../../chat/presentation/widgets/proposal_card_widget.dart';
import '../../../chat/presentation/widgets/streaming_indicator_widget.dart';
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
  const ProjectShellScreen({required this.projectPath, super.key});

  /// Path to the project directory
  final String projectPath;

  @override
  ConsumerState<ProjectShellScreen> createState() => _ProjectShellScreenState();
}

class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  /// Currently selected file node
  FileNode? _selectedNode;

  /// Loaded file content
  String? _fileContent;

  /// Dynamic column widths (left, right)
  late double _leftColumnWidth;
  late double _rightColumnWidth;

  /// Column visibility toggles
  bool _showLeftPanel = true;
  bool _showRightPanel = true;

  @override
  void initState() {
    super.initState();
    developer.log('ProjectShellScreen initialized');
    // Initialize column widths
    _leftColumnWidth = 280;
    _rightColumnWidth = 350;
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

          // Main workspace (3 columns with resizable dividers)
          Expanded(
            child: Row(
              children: [
                // Left: Directory tree (conditional)
                if (_showLeftPanel)
                  SizedBox(width: _leftColumnWidth, child: _buildLeftPanel()),

                // Left divider (resizable - only if left panel visible)
                if (_showLeftPanel)
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _leftColumnWidth += details.delta.dx;
                          // Min width: 180px, Max width: 60% of screen
                          _leftColumnWidth = _leftColumnWidth.clamp(
                            180,
                            MediaQuery.of(context).size.width * 0.6,
                          );
                        });
                      },
                      child: Container(
                        width: 4,
                        color: const Color(0xFF30363d),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drag_indicator,
                              size: 16,
                              color: Color(0xFF444c56),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Center: Chat widget
                Expanded(
                  child: _ChatPanelWidget(onFileSelected: _onFileSelected),
                ),

                // Right divider (resizable - only if right panel visible)
                if (_showRightPanel)
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _rightColumnWidth -= details.delta.dx;
                          // Min width: 180px, Max width: 60% of screen
                          _rightColumnWidth = _rightColumnWidth.clamp(
                            180,
                            MediaQuery.of(context).size.width * 0.6,
                          );
                        });
                      },
                      child: Container(
                        width: 4,
                        color: const Color(0xFF30363d),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drag_indicator,
                              size: 16,
                              color: Color(0xFF444c56),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Right: Preview panel (conditional)
                if (_showRightPanel)
                  SizedBox(width: _rightColumnWidth, child: _buildRightPanel()),
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
    const primary = Color.fromARGB(255, 14, 165, 64);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: [
          // Back button to Projects Dashboard
          IconButton(
            icon: const Icon(Icons.arrow_back, color: primary),
            onPressed: () {
              context.go('/workspace');
            },
            tooltip: 'Back to Projects',
          ),
          const SizedBox(width: 8),

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

          // Path display (from projectPath)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mainBg,
                border: Border.all(color: borderDark),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                widget.projectPath.isEmpty ? '~/projects' : widget.projectPath,
                style: const TextStyle(
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

          // Toggle panels buttons
          IconButton(
            icon: Icon(
              _showLeftPanel ? Icons.visibility : Icons.visibility_off,
              color: _showLeftPanel ? textSecondary : const Color(0xFF444c56),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showLeftPanel = !_showLeftPanel;
              });
            },
            tooltip: 'Toggle Explorer',
          ),
          IconButton(
            icon: Icon(
              _showRightPanel ? Icons.visibility : Icons.visibility_off,
              color: _showRightPanel ? textSecondary : const Color(0xFF444c56),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showRightPanel = !_showRightPanel;
              });
            },
            tooltip: 'Toggle Preview',
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
      decoration: const BoxDecoration(color: sidebarBg),
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
  Widget _buildRightPanel() => Container(
    decoration: const BoxDecoration(color: Color(0xFF0D1117)),
    child: MarkdownPreviewWidget(
      content: _fileContent,
      filename: _selectedNode?.name,
    ),
  );

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

/// Chat panel widget for ProjectShellScreen.
/// Displays conversation, proposals, and message input.
/// Supports sending messages with Enter key.
class _ChatPanelWidget extends ConsumerStatefulWidget {
  const _ChatPanelWidget({required this.onFileSelected});

  final Function(FileNode) onFileSelected;

  @override
  ConsumerState<_ChatPanelWidget> createState() => _ChatPanelWidgetState();
}

class _ChatPanelWidgetState extends ConsumerState<_ChatPanelWidget> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    return Column(
      children: [
        // Error banner
        if (chatState.hasError)
          ErrorBannerWidget(
            message: chatState.errorMessage ?? 'An error occurred',
            onDismiss: chatNotifier.clearError,
          ),

        // Conversation and proposals area
        Expanded(
          child: chatState.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      chatState.messages.length +
                      (chatState.currentProposal != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show proposal card at the top
                    if (index == chatState.messages.length &&
                        chatState.currentProposal != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProposalCardWidget(
                          proposal: chatState.currentProposal!,
                          onValidate: chatNotifier.validateProposal,
                          onRefine: chatNotifier.regenerateProposal,
                          onReject: chatNotifier.rejectProposal,
                        ),
                      );
                    }

                    // Show messages
                    final message = chatState
                        .messages[chatState.messages.length - 1 - index];
                    final messageUI = ChatMessageUI(
                      id: message.id,
                      role: message.role.name,
                      content: message.content,
                      timestamp: DateTime.parse(message.timestamp),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MessageBubbleWidget(message: messageUI),
                    );
                  },
                ),
        ),

        // Streaming indicator
        if (chatState.isStreaming)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: StreamingIndicatorWidget(
              progress: 0.5,
              documentIndex: 1,
              totalDocuments: 3,
            ),
          ),

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.mainBg,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !chatState.isStreaming,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText:
                        'Ask a question or describe what you need... (Press Enter to send)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: chatState.isStreaming
                        ? const SizedBox(
                            width: 40,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty && !chatState.isStreaming) {
                      _sendMessage(chatNotifier);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: chatState.isStreaming
                    ? null
                    : () {
                        if (_messageController.text.isNotEmpty) {
                          _sendMessage(chatNotifier);
                        }
                      },
                tooltip: 'Send message',
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the empty state
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.chat_outlined, size: 64, color: AppColors.border),
        const SizedBox(height: 24),
        Text(
          'Welcome to SoftArchitect AI Chat',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Ask questions or describe what you need.\n'
          'I will generate document proposals for you.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  /// Sends a message
  void _sendMessage(ChatNotifier chatNotifier) {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    _messageController.clear();
    chatNotifier.sendMessage(message);
  }
}
