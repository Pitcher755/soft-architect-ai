// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

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
import '../../domain/services/project_phase_service.dart';
import '../providers/project_providers.dart';
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
  ConsumerState<ProjectShellScreen> createState() => _ProjectShellScreenState();
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
    _fileContent =
        '# Proyecto: $projectName\n\n'
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
    final effectiveHeight = needsVerticalScroll
        ? _minScreenHeight
        : constraints.maxHeight;

    var requiredWidth = _sidebarWidth;
    if (_showFilesPanel) {
      requiredWidth += math.max(_filesPanelWidth, _minFilesWidth);
    }
    requiredWidth += _minChatWidth;
    if (_showMarkdownPanel) {
      requiredWidth += math.max(_markdownPanelWidth, _minMarkdownWidth);
    }

    final needsHorizontalScroll = constraints.maxWidth < requiredWidth;
    final contentWidth = needsHorizontalScroll
        ? requiredWidth
        : constraints.maxWidth;

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
          const SizedBox(width: _sidebarWidth, child: ProjectsSidebar()),
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
        () => _filesPanelWidth = (_filesPanelWidth + dx).clamp(50.0, 600.0),
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
      onToggleFiles: () => setState(() => _showFilesPanel = !_showFilesPanel),
      onToggleMarkdown: () =>
          setState(() => _showMarkdownPanel = !_showMarkdownPanel),
    ),
  );

  List<Widget> _buildMarkdownPanel() => [
    ResizeHandle(
      onDragUpdate: (dx) => setState(
        () => _markdownPanelWidth = (_markdownPanelWidth - dx).clamp(
          50.0,
          1000.0,
        ),
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
class _ChatPanelSection extends ConsumerStatefulWidget {
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
  ConsumerState<_ChatPanelSection> createState() => _ChatPanelSectionState();
}

class _ChatPanelSectionState extends ConsumerState<_ChatPanelSection> {
  @override
  void didUpdateWidget(_ChatPanelSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectPath != widget.projectPath) {
      ref
          .read(projectProgressProvider(widget.projectPath).notifier)
          .loadProgress(widget.projectPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMock = widget.projectPath.startsWith('mock://');
    final progressState = ref.watch(
      projectProgressProvider(widget.projectPath),
    );

    final progressData = progressState.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    final documentsCreated = isMock
        ? MockProjectData.mockDocumentsCreated
        : (progressData?.docsCompleted ?? 0);
    final currentPhase = isMock
        ? MockProjectData.mockCurrentPhase
        : ProjectPhaseService.getPhaseNameFromIndex(
            progressData?.currentPhase ?? 0,
          );

    return Column(
      children: [
        ProjectHeaderBar(
          fileName: widget.selectedNode?.name ?? 'SoftArchitect AI',
          showFilesPanel: widget.showFilesPanel,
          showMarkdownPanel: widget.showMarkdownPanel,
          onToggleFiles: widget.onToggleFiles,
          onToggleMarkdown: widget.onToggleMarkdown,
        ),
        if (progressState.isLoading && !isMock)
          const LinearProgressIndicator()
        else
          ProgressIndicatorWidget(
            documentsCreated: documentsCreated,
            currentPhase: currentPhase,
            projectPath: widget.projectPath,
          ),
        Expanded(
          child: ChatPanelWidget(
            messages: isMock ? MockProjectData.mockChatMessages : const [],
            isGuideProject: widget.projectPath.startsWith(
              'mock://softarchitect-guide',
            ),
          ),
        ),
      ],
    );
  }
}
