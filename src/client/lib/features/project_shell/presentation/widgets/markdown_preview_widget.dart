import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;

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
  }

  @override
  void didUpdateWidget(MarkdownPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content && !_isEditing) {
      _textController.text = widget.content ?? '';
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
      // 1. Obtener root seguro
      var projectRoot = ref.read(projectRootProvider);
      if (projectRoot == null || projectRoot.isEmpty) {
        final projects = ref.read(projectsProvider);
        projectRoot = projects
            .where((p) => !p.path.startsWith('mock://'))
            .firstOrNull
            ?.path;
      }

      if (projectRoot == null) {
        throw Exception('No project root found');
      }

      // 2. Normalizar ruta
      final normalizedPath = widget.filename!.startsWith('/')
          ? widget.filename!.substring(1)
          : widget.filename!;

      // 3. Construir ruta absoluta física
      final absolutePath = p.join(projectRoot, normalizedPath);
      final file = File(absolutePath);

      // 4. Crear directorio padre si no existe
      final parentDir = file.parent;
      if (!parentDir.existsSync()) {
        await parentDir.create(recursive: true);
      }

      // 5. Escribir contenido directamente con dart:io
      await file.writeAsString(_textController.text, flush: true);

      // 6. Actualizar progreso del proyecto
      try {
        await ProjectProgressService.updateAfterDocumentSave(projectRoot);
      } on Exception catch (e) {
        debugPrint('⚠️ Error actualizando progreso: $e');
        // No bloqueamos por error en progreso
      }

      // 7. Refrescar estado y salir de edición
      setState(() {
        _isEditing = false;
      });
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
      child: Column(
        children: [
          SelectionContainer.disabled(child: _buildToolbar()),
          Expanded(
            child: _isEditing
                ? _buildEditorView()
                : SelectionArea(
                    child: isJson
                        ? _buildJsonView(_textController.text)
                        : _buildMarkdownView(_textController.text),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: const BoxDecoration(
      color: Color(0xFF161B22),
      border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _isEditing ? Icons.edit_note : Icons.visibility_outlined,
              size: 16,
              color: _isEditing ? Colors.orangeAccent : const Color(0xFF8B949E),
            ),
            const SizedBox(width: 8),
            Text(
              widget.filename ?? 'Preview.md',
              style: TextStyle(
                color: _isEditing
                    ? Colors.orangeAccent
                    : const Color(0xFFC9D1D9),
                fontSize: 12,
                fontWeight: _isEditing ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'JetBrains Mono',
              ),
            ),
            if (_isEditing)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  '(Modo Edición)',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 10),
                ),
              ),
          ],
        ),
        Row(
          children: [
            if (_isEditing) ...[
              _ToolbarButton(
                icon: Icons.close_rounded,
                tooltip: 'Cancelar edición',
                color: Colors.redAccent,
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _textController.text =
                        widget.content ?? ''; // Revertir cambios
                  });
                },
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _saveEdits,
                icon: const Icon(Icons.save, size: 14),
                label: const Text('Guardar', style: TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ] else ...[
              _ToolbarButton(
                icon: Icons.edit_rounded,
                tooltip: 'Editar archivo',
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              _ToolbarButton(
                icon: Icons.copy_rounded,
                tooltip: 'Copiar contenido',
                onPressed: _handleCopy,
              ),
            ],
          ],
        ),
      ],
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
      builders: {'code': _CodeElementBuilder()},
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

class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      final lg = element.attributes['class'] as String;
      language = lg.startsWith('language-') ? lg.substring(9) : lg;
    }
    final codeContent = element.textContent.endsWith('\n')
        ? element.textContent.substring(0, element.textContent.length - 1)
        : element.textContent;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: HighlightView(
        codeContent,
        language: language,
        theme: atomOneDarkTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}
