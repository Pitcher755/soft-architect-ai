import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/widgets/chat_panel_widget.dart';
import '../../../chat/presentation/widgets/progress_indicator_widget.dart';
import '../../../filesystem/domain/entities/file_node.dart';
import '../../../filesystem/presentation/widgets/file_tree_widget.dart';
import '../../data/mock_data.dart';
import '../../domain/services/project_progress_service.dart';
import '../widgets/markdown_preview_widget.dart';
import '../widgets/project_header_bar.dart';
import '../widgets/resize_handle.dart';

/// Chat panel section with header, progress, and chat area.
///
/// Encapsulates the entire middle section including progress tracking.
class ChatPanelSection extends StatefulWidget {
  const ChatPanelSection({
    required this.projectPath,
    required this.selectedNode,
    super.key,
  });

  final String projectPath;
  final FileNode? selectedNode;

  @override
  State<ChatPanelSection> createState() => _ChatPanelSectionState();
}

class _ChatPanelSectionState extends State<ChatPanelSection> {
  bool _showFilesPanel = true;
  bool _showMarkdownPanel = true;
  String _fileContent = '';
  int _documentsCreated = 0;
  String _currentPhase = 'Inicial';

  @override
  void initState() {
    super.initState();
    _initializeContent();
    _loadProgress();
  }

  @override
  void didUpdateWidget(ChatPanelSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectPath != widget.projectPath) {
      _loadProgress();
    }
  }

  void _initializeContent() {
    final projectName = widget.projectPath.startsWith('mock://')
        ? 'Guía SoftArchitect'
        : widget.projectPath.split(Platform.pathSeparator).last;
    _fileContent =
        '# Proyecto: $projectName\n\nSelecciona un archivo para ver su contenido.';
  }

  Future<void> _loadProgress() async {
    final docs =
        await ProjectProgressService.calculateDocumentsCreated(
      widget.projectPath,
    );
    final phase = ProjectProgressService.getCurrentPhase(
      docs,
      widget.projectPath,
    );

    if (mounted) {
      setState(() {
        _documentsCreated = docs;
        _currentPhase = phase;
      });
    }
  }

  Future<void> _onFileSelected(FileNode node) async {
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
  Widget build(BuildContext context) => Column(
        children: [
          ProjectHeaderBar(
            fileName: widget.selectedNode?.name ?? 'SoftArchitect AI',
            showFilesPanel: _showFilesPanel,
            showMarkdownPanel: _showMarkdownPanel,
            onToggleFiles: () =>
                setState(() => _showFilesPanel = !_showFilesPanel),
            onToggleMarkdown: () =>
                setState(() => _showMarkdownPanel = !_showMarkdownPanel),
          ),
          ProgressIndicatorWidget(
            documentsCreated: _documentsCreated,
            currentPhase: _currentPhase,
            projectPath: widget.projectPath,
          ),
          Expanded(
            child: ChatPanelWidget(
              messages: widget.projectPath.startsWith('mock://')
                  ? MockProjectData.mockChatMessages
                  : const [],
              isGuideProject:
                  widget.projectPath.startsWith('mock://softarchitect-guide'),
            ),
          ),
        ],
      );
}
