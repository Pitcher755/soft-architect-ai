// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:io'; // Necesario para escribir el archivo

import 'package:file_picker/file_picker.dart'; // Necesario para guardar
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para Clipboard
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Markdown preview widget displaying rendered markdown content.
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({super.key, this.content, this.filename});

  final String? content;
  final String? filename;

  // --- LÓGICA DE COPIADO ---
  Future<void> _handleCopy(BuildContext context) async {
    final textToCopy = content ?? '';
    if (textToCopy.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contenido copiado al portapapeles'),
          backgroundColor: const Color(0xFF238636), // Verde GitHub
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // --- LÓGICA DE DESCARGA (GUARDAR COMO) ---
  Future<void> _handleDownload(BuildContext context) async {
    final textToSave = content ?? '';
    if (textToSave.isEmpty) return;

    // 1. Determinar extensión correcta
    final isJson = filename?.toLowerCase().endsWith('.json') ?? false;
    final extension = isJson ? '.json' : '.md';

    // 2. Preparar nombre por defecto asegurando la extensión
    var defaultName = filename ?? 'document$extension';
    if (!defaultName.toLowerCase().endsWith(extension)) {
      defaultName += extension;
    }

    try {
      // 3. Abrir diálogo de guardado
      var outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar documento',
        fileName: defaultName,
        // Filtramos por el tipo correcto para ayudar al OS
        allowedExtensions: isJson ? ['json'] : ['md', 'txt'],
        type: FileType.custom,
      );

      if (outputFile == null) {
        // Cancelado por el usuario
        return;
      }

      // 4. FORZAR EXTENSIÓN: Si el OS no la puso, la ponemos nosotros
      if (!outputFile.toLowerCase().endsWith(extension)) {
        outputFile = '$outputFile$extension';
      }

      // 5. Escribir archivo
      final file = File(outputFile);
      await file.writeAsString(textToSave);

      // 6. Feedback visual
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado en: $outputFile'),
            backgroundColor: const Color(0xFF1F6FEB), // Azul GitHub
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayContent = content ?? '';
    final isJson = filename?.toLowerCase().endsWith('.json') ?? false;

    return Container(
      color: const Color(0xFF0D1117),
      child: Column(
        children: [
          // Toolbar con context para SnackBars
          SelectionContainer.disabled(child: _buildToolbar(context)),
          Expanded(
            child: SelectionArea(
              child: isJson
                  ? _buildJsonView(displayContent)
                  : _buildMarkdownView(displayContent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) => Container(
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
            const Icon(
              Icons.visibility_outlined,
              size: 16,
              color: Color(0xFF8B949E),
            ),
            const SizedBox(width: 8),
            Text(
              filename ?? 'Preview.md',
              style: const TextStyle(
                color: Color(0xFFC9D1D9),
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        Row(
          children: [
            _ToolbarButton(
              icon: Icons.copy_rounded,
              tooltip: 'Copiar contenido',
              onPressed: () => _handleCopy(context),
            ),
            _ToolbarButton(
              icon: Icons.download_rounded,
              tooltip: 'Guardar archivo',
              onPressed: () => _handleDownload(context),
            ),
          ],
        ),
      ],
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
        blockquote: const TextStyle(
          color: Color(0xFF8B949E),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFF30363D), width: 4)),
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
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
        tableHead: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE6EDF3),
        ),
        tableBorder: TableBorder.all(color: const Color(0xFF30363D)),
        tableBody: const TextStyle(color: Color(0xFFC9D1D9)),
        a: const TextStyle(
          color: Color(0xFF58A6FF),
          decoration: TextDecoration.none,
        ),
        listBullet: const TextStyle(color: Color(0xFF79C0FF)),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 16, color: const Color(0xFF8B949E)),
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
