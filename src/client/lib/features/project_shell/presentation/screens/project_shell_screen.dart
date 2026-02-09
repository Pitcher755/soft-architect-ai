import 'dart:io'; // Para leer archivos
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

class ProjectShellScreen extends ConsumerStatefulWidget {
  const ProjectShellScreen({required this.projectPath, super.key});

  // Recibimos la ruta real desde el router
  final String projectPath;

  @override
  ConsumerState<ProjectShellScreen> createState() => _ProjectShellScreenState();
}

class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  // Nodo seleccionado (null al inicio)
  FileNode? _selectedNode;
  String _fileContent = '';

  // Estados de paneles
  bool _showFilesPanel = true;
  bool _showMarkdownPanel = true;

  // Constantes de diseño
  static const double _sidebarWidth = 62;
  static const double _minChatWidth = 300;
  static const double _minScreenHeight = 400;
  static const double _minFilesWidth = 170;
  static const double _minMarkdownWidth = 270;
  static const double _snapThreshold = 30;

  double _filesPanelWidth = 220;
  double _markdownPanelWidth = 420;

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida inicial
    final projectName = widget.projectPath.startsWith('mock://')
        ? 'Guía SoftArchitect'
        : widget.projectPath.split(Platform.pathSeparator).last;
    _fileContent =
        '# Proyecto: $projectName\n\nSelecciona un archivo para ver su contenido.';
  }

  /// Maneja la selección de archivos: Lectura Híbrida (Mock o Real)
  Future<void> _onFileSelected(FileNode node) async {
    setState(() => _selectedNode = node);

    if (!node.isDirectory) {
      // 1. CASO MOCK: Rutas virtuales mock://
      if (node.path.startsWith('mock://')) {
        final content =
            MockProjectData.guideFileContents[node.path] ?? '# Vacío';
        setState(() {
          _fileContent = content;
        });
        return;
      }

      // 2. CASO REAL: Lectura desde disco
      try {
        final file = File(node.path);
        if (await file.exists()) {
          final content = await file.readAsString();
          if (mounted) {
            setState(() {
              _fileContent = content;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _fileContent = 'Error leyendo archivo:\n$e';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.mainBg,
    body: LayoutBuilder(
      builder: (context, constraints) {
        // Lógica de Scroll (Vertical/Horizontal)
        final needsVerticalScroll = constraints.maxHeight < _minScreenHeight;
        final effectiveHeight = needsVerticalScroll
            ? _minScreenHeight
            : constraints.maxHeight;

        var requiredWidth = _sidebarWidth;
        if (_showFilesPanel)
          requiredWidth += math.max(_filesPanelWidth, _minFilesWidth);
        requiredWidth += _minChatWidth;
        if (_showMarkdownPanel)
          requiredWidth += math.max(_markdownPanelWidth, _minMarkdownWidth);

        final needsHorizontalScroll = constraints.maxWidth < requiredWidth;
        final contentWidth = needsHorizontalScroll
            ? requiredWidth
            : constraints.maxWidth;

        final Widget content = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: needsHorizontalScroll
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: contentWidth,
            height: effectiveHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A. SIDEBAR
                const SizedBox(width: _sidebarWidth, child: ProjectsSidebar()),

                // B. WORKSPACE
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. FILES PANEL
                      if (_showFilesPanel) ...[
                        Opacity(
                          opacity: _filesPanelWidth < _minFilesWidth
                              ? 0.5
                              : 1.0,
                          child: SizedBox(
                            width: math.max(_filesPanelWidth, _minFilesWidth),
                            child: FileTreeWidget(
                              // Pasamos la ruta real al widget actualizado
                              projectPath: widget.projectPath,
                              onFileSelected: _onFileSelected,
                            ),
                          ),
                        ),
                        _ResizeHandle(
                          onDragUpdate: (dx) => setState(
                            () => _filesPanelWidth = (_filesPanelWidth + dx)
                                .clamp(50.0, 600.0),
                          ),
                          onDragEnd: () => setState(() {
                            if (_filesPanelWidth <
                                (_minFilesWidth - _snapThreshold)) {
                              _showFilesPanel = false;
                              _filesPanelWidth = 220;
                            } else if (_filesPanelWidth < _minFilesWidth) {
                              _filesPanelWidth = _minFilesWidth;
                            }
                          }),
                        ),
                      ],

                      // 2. CHAT PANEL
                      Expanded(
                        child: Column(
                          children: [
                            _buildHeaderBar(),
                            // Progreso sigue siendo mock por ahora
                            const ProgressIndicatorWidget(
                              documentsCreated:
                                  MockProjectData.mockDocumentsCreated,
                              currentPhase: MockProjectData.mockCurrentPhase,
                            ),
                            Expanded(
                              child: ChatPanelWidget(
                                messages: MockProjectData.mockChatMessages,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. MARKDOWN PREVIEW
                      if (_showMarkdownPanel) ...[
                        _ResizeHandle(
                          onDragUpdate: (dx) => setState(
                            () => _markdownPanelWidth =
                                (_markdownPanelWidth - dx).clamp(50.0, 1000.0),
                          ),
                          onDragEnd: () => setState(() {
                            if (_markdownPanelWidth <
                                (_minMarkdownWidth - _snapThreshold)) {
                              _showMarkdownPanel = false;
                              _markdownPanelWidth = 420;
                            } else if (_markdownPanelWidth <
                                _minMarkdownWidth) {
                              _markdownPanelWidth = _minMarkdownWidth;
                            }
                          }),
                        ),
                        Opacity(
                          opacity: _markdownPanelWidth < _minMarkdownWidth
                              ? 0.5
                              : 1.0,
                          child: SizedBox(
                            width: math.max(
                              _markdownPanelWidth,
                              _minMarkdownWidth,
                            ),
                            child: MarkdownPreviewWidget(
                              content: _fileContent,
                              filename: _selectedNode?.name,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        return needsVerticalScroll
            ? SingleChildScrollView(child: content)
            : content;
      },
    ),
  );

  Widget _buildHeaderBar() => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!_showFilesPanel)
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_right, size: 16),
                tooltip: 'Mostrar Explorador',
                onPressed: () => setState(() => _showFilesPanel = true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            const SizedBox(width: 8),
            Text(
              _selectedNode?.name ??
                  'SoftArchitect AI', // Nombre del archivo o título por defecto
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                _showFilesPanel ? Icons.width_normal : Icons.width_wide,
                size: 16,
                color: _showFilesPanel
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              tooltip: 'Alternar Panel Archivos',
              onPressed: () =>
                  setState(() => _showFilesPanel = !_showFilesPanel),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _showMarkdownPanel ? Icons.visibility : Icons.visibility_off,
                size: 16,
                color: _showMarkdownPanel
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              tooltip: 'Alternar Vista Previa',
              onPressed: () =>
                  setState(() => _showMarkdownPanel = !_showMarkdownPanel),
            ),
          ],
        ),
      ],
    ),
  );
}

// _ResizeHandle se mantiene idéntico al que ya tienes
class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({required this.onDragUpdate, required this.onDragEnd});
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _isHovering = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.resizeColumn,
    onEnter: (_) => setState(() => _isHovering = true),
    onExit: (_) => setState(() => _isHovering = false),
    child: GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _isDragging = true),
      onHorizontalDragEnd: (_) {
        setState(() => _isDragging = false);
        widget.onDragEnd();
      },
      onHorizontalDragUpdate: (details) =>
          widget.onDragUpdate(details.delta.dx),
      child: Container(
        width: 12,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 1,
            height: double.infinity,
            color: (_isHovering || _isDragging)
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
      ),
    ),
  );
}
