import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../../../chat/presentation/widgets/chat_panel_widget.dart';
import '../../../chat/presentation/widgets/markdown_preview_widget.dart';
import '../../../chat/presentation/widgets/progress_indicator_widget.dart';
import '../../../filesystem/domain/entities/file_node.dart';
import '../../../filesystem/presentation/widgets/file_tree_widget.dart';
import '../../data/mock_data.dart';

/// Main IDE-like project shell with 4-column layout (+ sidebar).
///
/// Layout Structure (Desktop):
/// ```
/// ┌───┬──────┬──────────────────┬────────────────────┐
/// │   │      │ TopBar (toggle)  │                    │
/// │   │      ├──────────────────┤                    │
/// │SID│Files │  Chat Panel      │  Preview Panel     │
/// │EBA│ Tree │  (4-col layout)  │  (Markdown)        │
/// │R   │      │                  │                    │
/// │   │      │                  │                    │
/// └───┴──────┴──────────────────┴────────────────────┘
/// ```
///
/// Features:
/// - 4 columns: Sidebar + Files Tree + Chat + Markdown Preview
/// - Toggle visibility for Files and Preview panels
/// - Phase-colored directory icons
/// - Real-time chat with proposal cards
/// - Markdown preview with syntax highlighting
///
/// Color Scheme: GitHub Dark Theme
class ProjectShellScreen extends ConsumerStatefulWidget {
  const ProjectShellScreen({required this.projectPath, super.key});

  /// Path to the project directory
  final String projectPath;

  @override
  ConsumerState<ProjectShellScreen> createState() => _ProjectShellScreenState();
}

class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  /// Currently selected file node
  late FileNode _selectedNode;

  /// Loaded file content for preview
  String _fileContent = MockProjectData.mockMarkdownContent;

  /// Column visibility state
  bool _showFilesPanel = true;
  bool _showMarkdownPanel = true;

  /// Dynamic column widths (resizable)
  double _filesColumnWidth = 260;
  double _markdownColumnWidth = 420;

  @override
  void initState() {
    super.initState();
    _selectedNode = MockProjectData.mockProjectRoot;
  }

  /// Handle file selection from tree
  void _onFileSelected(FileNode node) {
    setState(() {
      _selectedNode = node;
      // Update preview content based on selected file
      if (!node.isDirectory) {
        // For demo: use mock markdown content
        _fileContent = MockProjectData.mockMarkdownContent;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.mainBg,
    body: Row(
      children: [
        // Column 0: Activity Sidebar (64px, fixed)
        const ProjectsSidebar(),

        // Column 1: File Explorer (resizable, collapsible)
        if (_showFilesPanel)
          _buildResizableColumn(
            width: _filesColumnWidth,
            minWidth: 200,
            maxWidth: 1000,
            onWidthChanged: (width) =>
                setState(() => _filesColumnWidth = width),
            child: FileTreeWidget(
              onFileSelected: _onFileSelected,
              rootNode: MockProjectData.mockProjectRoot,
            ),
          ),

        // Column 2: Chat Panel (resizable, expanded)
        _buildResizableColumn(
          width: null, // Expanded by default
          minWidth: 300,
          maxWidth: 1200,
          onWidthChanged: (width) => setState(() {
            _filesColumnWidth = _filesColumnWidth;
            _markdownColumnWidth = _markdownColumnWidth;
          }),
          isExpanded: true,
          child: Column(
            children: [
              // Header with toggle buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedNode.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    // Toggle buttons
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showFilesPanel ? Icons.folder_open : Icons.folder,
                          ),
                          tooltip: _showFilesPanel
                              ? 'Ocultar archivos'
                              : 'Mostrar archivos',
                          onPressed: () {
                            setState(() => _showFilesPanel = !_showFilesPanel);
                          },
                          iconSize: 18,
                          splashRadius: 20,
                        ),
                        IconButton(
                          icon: Icon(
                            _showMarkdownPanel
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          tooltip: _showMarkdownPanel
                              ? 'Ocultar preview'
                              : 'Mostrar preview',
                          onPressed: () {
                            setState(
                              () => _showMarkdownPanel = !_showMarkdownPanel,
                            );
                          },
                          iconSize: 18,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress indicator
              const ProgressIndicatorWidget(
                documentsCreated: MockProjectData.mockDocumentsCreated,
                currentPhase: MockProjectData.mockCurrentPhase,
              ),

              // Chat panel (expanded, min 300px width)
              Expanded(
                child: ChatPanelWidget(
                  messages: MockProjectData.mockChatMessages,
                ),
              ),
            ],
          ),
        ),

        // Column 3: Markdown Preview (resizable, collapsible)
        if (_showMarkdownPanel)
          _buildResizableColumn(
            width: _markdownColumnWidth,
            minWidth: 250,
            maxWidth: 1000,
            onWidthChanged: (width) =>
                setState(() => _markdownColumnWidth = width),
            child: MarkdownPreviewWidget(
              content: _fileContent,
              filename: _selectedNode.name,
            ),
          ),
      ],
    ),
  );

  /// Build resizable column with drag handle
  Widget _buildResizableColumn({
    required Widget child,
    required double? width,
    required double minWidth,
    required double maxWidth,
    required ValueChanged<double> onWidthChanged,
    bool isExpanded = false,
  }) {
    if (isExpanded) {
      return Expanded(child: child);
    }

    final currentWidth = width ?? minWidth;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: SizedBox(
        width: currentWidth,
        child: Stack(
          children: [
            // Main content
            child,

            // Right divider (draggable)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newWidth = currentWidth + details.delta.dx;
                    final clampedWidth = newWidth
                        .clamp(minWidth, maxWidth)
                        .toDouble();
                    onWidthChanged(clampedWidth);
                  },
                  child: Container(width: 4, color: const Color(0xFF30363D)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
