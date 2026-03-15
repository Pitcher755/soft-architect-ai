import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../shared/presentation/widgets/markdown_builders/code_element_builder.dart';
import '../../../filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../filesystem/presentation/providers/filesystem_providers.dart';
import '../../infrastructure/services/project_progress_service.dart';
import '../providers/project_providers.dart';

class MarkdownPreviewWidget extends ConsumerStatefulWidget {
  const MarkdownPreviewWidget({super.key, this.content, this.filename});

  final String? content;
  final String? filename;

  @override
  ConsumerState<MarkdownPreviewWidget> createState() =>
      _MarkdownPreviewWidgetState();
}

class _MarkdownPreviewWidgetState extends ConsumerState<MarkdownPreviewWidget> {
  bool _isEditing = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.content ?? '');
    // Si hay filename, leer el contenido real del archivo
    if (widget.filename != null) {
      _loadFileContent();
    }
  }

  @override
  void didUpdateWidget(MarkdownPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el filename, recargar desde archivo
    if (oldWidget.filename != widget.filename && widget.filename != null) {
      _loadFileContent();
    }
    // Si no hay filename y cambia el content
    else if (widget.filename == null &&
        oldWidget.content != widget.content &&
        !_isEditing) {
      _textController.text = widget.content ?? '';
    }
  }

  // Cargar contenido directamente desde el archivo físico
  Future<void> _loadFileContent() async {
    // Defensive check: widget.filename must be a file, not a directory
    if (widget.filename == null) {
      return;
    }

    try {
      final file = File(widget.filename!);

      // Extra safety: Verify it's not a directory before reading
      if (FileSystemEntity.isDirectorySync(widget.filename!)) {
        // Skip reading directories, use widget.content fallback
        if (mounted && !_isEditing) {
          setState(() {
            _textController.text = widget.content ?? '';
          });
        }
        return;
      }

      final content = await file.readAsString();
      if (mounted && !_isEditing) {
        setState(() {
          _textController.text = content;
        });
      }
    } on Exception catch (e) {
      debugPrint('⚠️ Error leyendo archivo: $e');
      // Fallback a widget.content si falla la lectura
      if (mounted && !_isEditing) {
        setState(() {
          _textController.text = widget.content ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE GUARDADO DIRECTO (KILLER FEATURE) ---
  Future<void> _saveEdits() async {
    if (widget.filename == null) {
      return;
    }

    try {
      // 1. widget.filename ya trae la ruta absoluta completa
      final file = File(widget.filename!);

      // 2. Crear directorio padre si no existe
      final parentDir = file.parent;
      if (!parentDir.existsSync()) {
        await parentDir.create(recursive: true);
      }

      // 3. Escribir contenido directamente con dart:io
      await file.writeAsString(_textController.text, flush: true);

      // 3.1 ✅ TRIGGER AUTO-REFRESH: Notify file tree to reload
      ref.read(fileSystemNotifierProvider.notifier).refresh();

      // 4. Actualizar progreso del proyecto
      try {
        // Extraer project root desde la ruta del archivo
        var projectRoot = ref.read(projectRootProvider);
        if (projectRoot == null || projectRoot.isEmpty) {
          final projects = ref.read(projectsProvider);
          projectRoot = projects
              .where((p) => !p.path.startsWith('mock://'))
              .firstOrNull
              ?.path;
        }

        if (projectRoot != null) {
          await ProjectProgressService.updateAfterDocumentSave(projectRoot);
        }
      } on Exception catch (e) {
        debugPrint('⚠️ Error actualizando progreso: $e');
        // No bloqueamos por error en progreso
      }

      // 5. Salir de modo edición
      setState(() {
        _isEditing = false;
      });

      // 6. Recargar contenido desde archivo físico (asegura persistencia)
      await _loadFileContent();

      // 7. Refrescar filesystem notifier
      ref.invalidate(fileSystemNotifierProvider);
      ref.read(fileSystemNotifierProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Archivo actualizado correctamente'),
            backgroundColor: Color(0xFF238636), // Verde GitHub
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // --- COPIAR ---
  Future<void> _handleCopy() async {
    final textToCopy = _isEditing
        ? _textController.text
        : (widget.content ?? '');
    if (textToCopy.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: textToCopy));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenido copiado'),
          backgroundColor: Color(0xFF238636),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isJson = widget.filename?.toLowerCase().endsWith('.json') ?? false;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          // Base layer: content fills entire area
          Positioned.fill(
            child: _isEditing
                ? _buildEditorView()
                : SelectionArea(
                    child: isJson
                        ? _buildJsonView(_textController.text)
                        : _buildMarkdownView(_textController.text),
                  ),
          ),
          // Floating toolbar in top-right corner
          Positioned(top: 8, right: 8, child: _buildFloatingToolbar(context)),
        ],
      ),
    );
  }

  // Floating toolbar with semi-transparent background
  Widget _buildFloatingToolbar(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectionContainer.disabled(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isEditing) ...[
              // Cancel button
              _ToolbarButton(
                icon: Icons.close_rounded,
                tooltip: 'Cancelar edición',
                color: Colors.redAccent,
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                  // Recargar contenido desde archivo (descarta cambios
                  // no guardados)
                  if (widget.filename != null) {
                    _loadFileContent();
                  } else {
                    _textController.text = widget.content ?? '';
                  }
                },
              ),
              const SizedBox(width: 4),
              // Save button
              SizedBox(
                height: 32,
                child: FilledButton.icon(
                  onPressed: _saveEdits,
                  icon: const Icon(Icons.save, size: 14),
                  label: const Text('Guardar', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ] else ...[
              // Edit button
              _ToolbarButton(
                icon: Icons.edit_rounded,
                tooltip: 'Editar archivo',
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              const SizedBox(width: 4),
              // Copy button
              _ToolbarButton(
                icon: Icons.copy_rounded,
                tooltip: 'Copiar contenido',
                onPressed: _handleCopy,
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildEditorView() => Container(
    color: const Color(0xFF0D1117), // Fondo oscuro IDE
    child: TextField(
      controller: _textController,
      maxLines: null,
      expands: true,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 14,
        color: Color(0xFFC9D1D9),
        height: 1.5,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(24),
      ),
    ),
  );

  Widget _buildJsonView(String content) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      padding: const EdgeInsets.all(16),
      child: HighlightView(
        content,
        language: 'json',
        theme: atomOneDarkTheme,
        textStyle: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 13,
          height: 1.5,
        ),
      ),
    ),
  );

  Widget _buildMarkdownView(String content) {
    final safeTheme = ThemeData.dark().copyWith(
      textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 14)),
    );

    return Markdown(
      data: content,
      padding: const EdgeInsets.all(24),
      extensionSet: md.ExtensionSet.gitHubFlavored,
      builders: {'code': CodeElementBuilder()},
      styleSheet: MarkdownStyleSheet.fromTheme(safeTheme).copyWith(
        p: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 14, height: 1.6),
        h1: const TextStyle(
          color: Color(0xFFE6EDF3),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        h2: const TextStyle(
          color: Color(0xFFE6EDF3),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
        ),
        h3: const TextStyle(
          color: Color(0xFFE6EDF3),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        code: const TextStyle(
          fontFamily: 'JetBrains Mono',
          backgroundColor: Color.fromRGBO(110, 118, 129, 0.4),
          color: Color(0xFFC9D1D9),
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 16, color: color ?? const Color(0xFF8B949E)),
    tooltip: tooltip,
    onPressed: onPressed,
    splashRadius: 20,
    hoverColor: Colors.white.withValues(alpha: 0.1),
  );
}
