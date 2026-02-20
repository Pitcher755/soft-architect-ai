import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/theme/app_colors.dart'; // Importante para usar AppColors

/// Intelligent message renderer for chat interface.
class SmartMessageRenderer extends StatelessWidget {
  const SmartMessageRenderer({
    required this.rawContent,
    required this.isUser,
    this.onSaveDocument,
    super.key,
  });

  final String rawContent;
  final bool isUser;
  final void Function(String path, String content)? onSaveDocument;

  // ✅ RegEx a prueba de balas usando XML
  static final RegExp _documentBlockRegex = RegExp(
    r'<document>\r?\n?([\s\S]*?)(?:</document>|$)',
    caseSensitive: false,
  );

  /// Decodes HTML entities to fix double-escaped content from backend.
  ///
  /// Fixes issue where backend HTML escaping causes double-encoding:
  /// - `&amp;lt;` → `&lt;` → `<`
  /// - `&amp;gt;` → `&gt;` → `>`
  /// - `&amp;quot;` → `&quot;` → `"`
  ///
  /// This is necessary because the backend uses `html.escape()` for XSS
  /// prevention, but HTTP transport can cause additional encoding.
  static String _decodeHtmlEntities(String text) => text
      .replaceAll('&amp;', '&') // Must be first to avoid double-decode
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&#x27;', "'")
      .replaceAll('&apos;', "'");

  @override
  Widget build(BuildContext context) {
    // ✅ Decode HTML entities before processing
    final decodedContent = _decodeHtmlEntities(rawContent);

    if (isUser) {
      return _buildMarkdown(context, decodedContent);
    }

    final matches = _documentBlockRegex.allMatches(decodedContent);

    if (matches.isEmpty) {
      return _buildMarkdown(context, decodedContent);
    }

    return _buildMixedContent(context, matches, decodedContent);
  }

  /// Builds a standard markdown widget with selectable text.
  Widget _buildMarkdown(BuildContext context, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ MEJORA: Color forzado a AppColors.textMain y tamaño base aumentado a 16
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 1.6,
      color: isDark ? AppColors.textMain : Colors.black87,
    );

    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        listBullet: baseStyle,
        code: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontSize: 15, // Código un poco más grande
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: isDark ? Colors.greenAccent.shade100 : Colors.blue.shade800,
        ),
        h1: theme.textTheme.headlineSmall?.copyWith(
          color: baseStyle?.color,
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(
          color: baseStyle?.color,
          fontWeight: FontWeight.bold,
        ),
        h3: theme.textTheme.titleMedium?.copyWith(
          color: baseStyle?.color,
          fontWeight: FontWeight.bold,
        ),
        strong: baseStyle?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMixedContent(
    BuildContext context,
    Iterable<RegExpMatch> matches,
    String decodedContent,
  ) {
    final elements = <Widget>[];
    var currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        final textBefore = decodedContent
            .substring(currentIndex, match.start)
            .trim();
        if (textBefore.isNotEmpty) {
          elements
            ..add(_buildMarkdown(context, textBefore))
            ..add(const SizedBox(height: 12));
        }
      }

      final documentContent = match.group(1)?.trim() ?? '';
      elements
        ..add(_DocumentCard(content: documentContent, onSave: onSaveDocument))
        ..add(const SizedBox(height: 12));

      currentIndex = match.end;
    }

    if (currentIndex < decodedContent.length) {
      final textAfter = decodedContent.substring(currentIndex).trim();
      if (textAfter.isNotEmpty) {
        elements.add(_buildMarkdown(context, textAfter));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: elements,
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.content, this.onSave});

  final String content;
  final void Function(String path, String cleanContent)? onSave;

  void _handleValidation() {
    final pathRegex = RegExp(
      r'\*\*(?:Path|Ruta):\*\*\s*`?([^\n`]+)`?',
      caseSensitive: false,
    );
    final match = pathRegex.firstMatch(content);

    final extractedPath =
        match?.group(1)?.trim() ?? 'context/UNSORTED/untitled.md';
    final cleanContent = content.replaceAll(pathRegex, '').trim();

    if (onSave != null) {
      onSave!(extractedPath, cleanContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildContent(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.plumbing_rounded, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'DOCUMENTO GENERADO',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ MEJORA: Aumentamos el tamaño de letra también dentro de la tarjeta
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 15, // Letra un poco más grande
      height: 1.5,
      color: isDark ? AppColors.textMain : Colors.black87,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: baseStyle,
          listBullet: baseStyle,
          code: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontSize: 14,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: isDark ? Colors.greenAccent.shade100 : Colors.blue.shade800,
          ),
          h1: theme.textTheme.titleLarge?.copyWith(
            color: baseStyle?.color,
            fontWeight: FontWeight.bold,
          ),
          h2: theme.textTheme.titleMedium?.copyWith(
            color: baseStyle?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: () {
          _handleValidation();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documento enviado a validación...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('Validar y Guardar'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
        ),
      ),
    ),
  );
}
