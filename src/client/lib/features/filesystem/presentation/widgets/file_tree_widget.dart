// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../project_shell/data/mock_data.dart';
import '../../domain/entities/file_node.dart';
import '../../infrastructure/services/file_tree_service.dart';
import 'file_tree_node.dart';

class FileTreeWidget extends StatefulWidget {
  const FileTreeWidget({
    required this.onFileSelected,
    this.rootNode,
    this.projectPath, // New parameter for real path
    super.key,
  });

  final ValueChanged<FileNode> onFileSelected;
  final FileNode? rootNode; // For Mocks (optional)
  final String? projectPath; // For Real (optional)

  @override
  State<FileTreeWidget> createState() => _FileTreeWidgetState();
}

class _FileTreeWidgetState extends State<FileTreeWidget> {
  FileNode? _activeRootNode;
  FileNode? _selectedNode;
  final Set<String> _expandedFolders = {};

  // UI state
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(FileTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the project path changes, reload
    if (oldWidget.projectPath != widget.projectPath) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // LÓGICA HÍBRIDA: Detecta rutas mock:// vs rutas reales

    // 1. MODO MOCK: Si la ruta es virtual (empieza con 'mock://')
    if (widget.projectPath?.startsWith('mock://') ?? false) {
      setState(() {
        _activeRootNode = MockProjectData.guideRootNode;
        _expandedFolders.add(_activeRootNode!.id);
      });
      return;
    }

    // 2. REAL MODE: If there's a projectPath, use the infrastructure service
    if (widget.projectPath != null) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final node = await FileTreeService.buildTreeFromPath(
          widget.projectPath!,
        );

        if (mounted) {
          setState(() {
            _activeRootNode = node;
            _expandedFolders.add(node.id); // Expandimos la raíz por defecto
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error cargando archivos: $e';
            _isLoading = false;
          });
        }
      }
    }
    // 3. MODO MOCK LEGACY: Usamos el rootNode pasado si existe
    else if (widget.rootNode != null) {
      setState(() {
        _activeRootNode = widget.rootNode;
        _expandedFolders.add(widget.rootNode!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(right: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      children: [
        // Header: EXPLORER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'EXPLORER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Botón de refrescar real
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                color: AppColors.textSecondary,
                iconSize: 16,
                tooltip: 'Recargar',
                onPressed: _isLoading ? null : _loadData,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Contenido del Árbol
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
              : _activeRootNode == null
              ? const SizedBox()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildFileTree(_activeRootNode!, 0),
                ),
        ),
      ],
    ),
  );

  Widget _buildFileTree(FileNode node, int depth) {
    final isFolder = node.isDirectory;
    final isExpanded = _expandedFolders.contains(node.id);
    final isSelected = _selectedNode?.id == node.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: FileTreeNode(
            node: node,
            depth: depth,
            isSelected: isSelected,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                _selectedNode = node;
                if (isFolder) {
                  if (isExpanded) {
                    _expandedFolders.remove(node.id);
                  } else {
                    _expandedFolders.add(node.id);
                  }
                }
              });
              widget.onFileSelected(node);
            },
            onToggle: isFolder
                ? () {
                    setState(() {
                      if (isExpanded) {
                        _expandedFolders.remove(node.id);
                      } else {
                        _expandedFolders.add(node.id);
                      }
                    });
                  }
                : null,
          ),
        ),
        if (isFolder && isExpanded)
          ...node.children.map((child) => _buildFileTree(child, depth + 1)),
      ],
    );
  }
}
