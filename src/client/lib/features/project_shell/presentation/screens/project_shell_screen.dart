import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../../../chat/presentation/widgets/chat_panel_widget.dart';
import '../../../chat/presentation/widgets/progress_indicator_widget.dart';
import '../../../filesystem/domain/entities/file_node.dart';
import '../../../filesystem/presentation/widgets/file_tree_widget.dart';
import '../../data/mock_data.dart';
import '../widgets/markdown_preview_widget.dart';
import '../widgets/project_header_bar.dart';
import '../widgets/resize_handle.dart';

/// Project shell screen - main IDE-like interface for project work.
///
/// Provides a three-panel layout:
/// - File explorer (left, resizable/hideable)
/// - Chat/progress panel (center, always visible)
/// - Markdown preview (right, resizable/hideable)
///
/// This screen orchestrates layout only. Logic delegated to child widgets.
class ProjectShellScreen extends ConsumerStatefulWidget {
  const ProjectShellScreen({required this.projectPath, super.key});

  final String projectPath;

  @override
  ConsumerState<ProjectShellScreen> createState() =>
      _ProjectShellScreenState();
}

class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  // File selection state
  FileNode? _selectedNode;
  String _fileContent = '';

  // Panel visibility state
  bool _showFilesPanel = true;
  bool _showMarkdownPanel = true;

  // Layout constants
  static const double _sidebarWidth = 62;
  static const double _minChatWidth = 300;
  static const double _minScreenHeight = 400;
  static const double _minFilesWidth = 170;
  static const double _minMarkdownWidth = 270;
  static const double _snapThreshold = 30;

  // Panel widths
  double _filesPanelWidth = 220;
  double _markdownPanelWidth = 420;

  @override
  void initState() {
    super.initState();
    _initializeWelcomeMessage();
  }

  void _initializeWelcomeMessage() {
    final projectName = widget.projectPath.startsWith('mock://')
        ? 'Guía SoftArchitect'
        : widget.projectPath.split(Platform.pathSeparator).last;
    _fileContent = '# Proyecto: $projectName\n\n'
        'Selecciona un archivo para ver su contenido.';
  }

  Future<void> _onFileSelected(FileNode node) async {
    setState(() => _selectedNode = node);

    if (node.isDirectory) return;

    // Mock project
    if (node.path.startsWith('mock://')) {
      final content = MockProjectData.guideFileContents[node.path] ?? '# Vacío';
      setState(() => _fileContent = content);
      return;
    }

    // Real project
    try {
      final file = File(node.path);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (mounted) {
          setState(() => _fileContent = content);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fileContent = 'Error leyendo archivo:\n$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.mainBg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final layout = _calculateLayout(constraints);
            final content = _buildContent(layout);

            return layout.needsVerticalScroll
                ? SingleChildScrollView(child: content)
                : content;
          },
        ),
      );

  _LayoutMetrics _calculateLayout(BoxConstraints constraints) {
    final needsVerticalScroll = constraints.maxHeight < _minScreenHeight;
    final effectiveHeight =
        needsVerticalScroll ? _minScreenHeight : constraints.maxHeight;

    var requiredWidth = _sidebarWidth;
    if (_showFilesPanel) {
      requiredWidth += math.max(_filesPanelWidth, _minFilesWidth);
    }
    requiredWidth += _minChatWidth;
    if (_showMarkdownPanel) {
      requiredWidth += math.max(_markdownPanelWidth, _minMarkdownWidth);
    }

    final needsHorizontalScroll = constraints.maxWidth < requiredWidth;
    final contentWidth =
        needsHorizontalScroll ? requiredWidth : constraints.maxWidth;

    return _LayoutMetrics(
      effectiveHeight: effectiveHeight,
      contentWidth: contentWidth,
      needsVerticalScroll: needsVerticalScroll,
      needsHorizontalScroll: needsHorizontalScroll,
    );
  }

  Widget _buildContent(_LayoutMetrics layout) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: layout.needsHorizontalScroll
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: layout.contentWidth,
          height: layout.effectiveHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                width: _sidebarWidth,
                child: ProjectsSidebar(),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_showFilesPanel) ..._buildFilesPanel(),
                    _buildChatPanel(),
                    if (_showMarkdownPanel) ..._buildMarkdownPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> _buildFilesPanel() => [
        Opacity(
          opacity: _filesPanelWidth < _minFilesWidth ? 0.5 : 1.0,
          child: SizedBox(
            width: math.max(_filesPanelWidth, _minFilesWidth),
            child: FileTreeWidget(
              projectPath: widget.projectPath,
              onFileSelected: _onFileSelected,
            ),
          ),
        ),
        ResizeHandle(
          onDragUpdate: (dx) => setState(
            () => _filesPanelWidth =
                (_filesPanelWidth + dx).clamp(50.0, 600.0),
          ),
          onDragEnd: () => setState(() {
            if (_filesPanelWidth < (_minFilesWidth - _snapThreshold)) {
              _showFilesPanel = false;
              _filesPanelWidth = 220;
            } else if (_filesPanelWidth < _minFilesWidth) {
              _filesPanelWidth = _minFilesWidth;
            }
          }),
        ),
      ];

  Widget _buildChatPanel() => Expanded(
        child: _ChatPanelSection(
          projectPath: widget.projectPath,
          selectedNode: _selectedNode,
          showFilesPanel: _showFilesPanel,
          showMarkdownPanel: _showMarkdownPanel,
          onToggleFiles: () =>
              setState(() => _showFilesPanel = !_showFilesPanel),
          onToggleMarkdown: () =>
              setState(() => _showMarkdownPanel = !_showMarkdownPanel),
        ),
      );

  List<Widget> _buildMarkdownPanel() => [
        ResizeHandle(
          onDragUpdate: (dx) => setState(
            () => _markdownPanelWidth =
                (_markdownPanelWidth - dx).clamp(50.0, 1000.0),
          ),
          onDragEnd: () => setState(() {
            if (_markdownPanelWidth < (_minMarkdownWidth - _snapThreshold)) {
              _showMarkdownPanel = false;
              _markdownPanelWidth = 420;
            } else if (_markdownPanelWidth < _minMarkdownWidth) {
              _markdownPanelWidth = _minMarkdownWidth;
            }
          }),
        ),
        Opacity(
          opacity: _markdownPanelWidth < _minMarkdownWidth ? 0.5 : 1.0,
          child: SizedBox(
            width: math.max(_markdownPanelWidth, _minMarkdownWidth),
            child: MarkdownPreviewWidget(
              content: _fileContent,
              filename: _selectedNode?.name,
            ),
          ),
        ),
      ];
}

/// Layout calculation results.
class _LayoutMetrics {
  const _LayoutMetrics({
    required this.effectiveHeight,
    required this.contentWidth,
    required this.needsVerticalScroll,
    required this.needsHorizontalScroll,
  });

  final double effectiveHeight;
  final double contentWidth;
  final bool needsVerticalScroll;
  final bool needsHorizontalScroll;
}

/// Chat panel section with header, progress, and chat.
///
/// Encapsulates the center panel with real progress calculation.
/// Replaces mock data with actual filesystem scanning.
class _ChatPanelSection extends StatefulWidget {
  const _ChatPanelSection({
    required this.projectPath,
    required this.selectedNode,
    required this.showFilesPanel,
    required this.showMarkdownPanel,
    required this.onToggleFiles,
    required this.onToggleMarkdown,
  });

  final String projectPath;
  final FileNode? selectedNode;
  final bool showFilesPanel;
  final bool showMarkdownPanel;
  final VoidCallback onToggleFiles;
  final VoidCallback onToggleMarkdown;

  @override
  State<_ChatPanelSection> createState() => _ChatPanelSectionState();
}

class _ChatPanelSectionState extends State<_ChatPanelSection> {
  int _documentsCreated = 0;
  String _currentPhase = 'Inicial';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didUpdateWidget(_ChatPanelSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectPath != widget.projectPath) {
      _loadProgress();
    }
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);

    final isMock = widget.projectPath.startsWith('mock://');

    if (isMock) {
      // Mock project: use mock data
      setState(() {
        _documentsCreated = MockProjectData.mockDocumentsCreated;
        _currentPhase = MockProjectData.mockCurrentPhase;
        _isLoading = false;
      });
      return;
    }

    // Real project: calculate real progress
    try {
      final projectDir = Directory(widget.projectPath);
      if (!await projectDir.exists()) {
        setState(() {
          _documentsCreated = 0;
          _currentPhase = 'Root';
          _isLoading = false;
        });
        return;
      }

      var count = 0;
      await for (final entity
          in projectDir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.md')) {
          count++;
        }
      }

      if (mounted) {
        setState(() {
          _documentsCreated = count;
          _currentPhase = _calculatePhase(count);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _documentsCreated = 0;
          _currentPhase = 'Root';
          _isLoading = false;
        });
      }
    }
  }

  String _calculatePhase(int docs) {
    if (docs == 0) return 'Root';
    if (docs <= 4) return 'Root';
    if (docs <= 7) return 'Contexto';
    if (docs <= 11) return 'Requisitos';
    if (docs <= 17) return 'Arquitectura';
    if (docs <= 20) return 'UI/UX';
    if (docs <= 24) return 'Planificación';
    return 'Meta';
  }

  @override
  Widget build(BuildContext context) {
    final isMock = widget.projectPath.startsWith('mock://');

    return Column(
      children: [
        ProjectHeaderBar(
          fileName: widget.selectedNode?.name ?? 'SoftArchitect AI',
          showFilesPanel: widget.showFilesPanel,
          showMarkdownPanel: widget.showMarkdownPanel,
          onToggleFiles: widget.onToggleFiles,
          onToggleMarkdown: widget.onToggleMarkdown,
        ),
        if (_isLoading)
          const LinearProgressIndicator()
        else
          ProgressIndicatorWidget(
            documentsCreated: _documentsCreated,
            currentPhase: _currentPhase,
            projectPath: widget.projectPath,
          ),
        Expanded(
          child: ChatPanelWidget(
            messages: isMock ? MockProjectData.mockChatMessages : const [],
            isGuideProject:
                widget.projectPath.startsWith('mock://softarchitect-guide'),
          ),
        ),
      ],
    );
  }
}
