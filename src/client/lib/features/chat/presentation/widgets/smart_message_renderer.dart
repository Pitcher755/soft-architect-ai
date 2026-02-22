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
  final Future<void> Function(String path, String content)? onSaveDocument;

  // RegEx a prueba de balas usando XML
  static final RegExp _documentBlockRegex = RegExp(
    r'<document>\r?\n?([\s\S]*?)(?:</document>|$)',
    caseSensitive: false,
  );

  static String _decodeHtmlEntities(String text) => text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&#x27;', "'")
      .replaceAll('&apos;', "'");

  @override
  Widget build(BuildContext context) {
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

  Widget _buildMarkdown(BuildContext context, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          fontSize: 15,
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
        ..add(
          _DocumentCard(
            key: ValueKey(documentContent.hashCode),
            content: documentContent,
            onSave: onSaveDocument,
          ),
        )
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

class _DocumentCard extends StatefulWidget {
  const _DocumentCard({required this.content, this.onSave, super.key});

  final String content;
  final Future<void> Function(String path, String cleanContent)? onSave;

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  static final Set<int> _validatedDocs = {};

  bool _isValidating = false;

  bool get _isAlreadyValidated =>
      _validatedDocs.contains(widget.content.hashCode);

  Future<void> _handleValidation() async {
    if (_isValidating || _isAlreadyValidated) {
      return;
    }

    setState(() {
      _isValidating = true;
    });

    final pathRegex = RegExp(
      r'\*\*(?:Path|Ruta):\*\*\s*`?([^\n`]+)`?',
      caseSensitive: false,
    );
    final match = pathRegex.firstMatch(widget.content);

    final extractedPath =
        match?.group(1)?.trim() ?? 'context/UNSORTED/untitled.md';
    final cleanContent = widget.content.replaceAll(pathRegex, '').trim();

    if (widget.onSave != null) {
      try {
        await widget.onSave!(extractedPath, cleanContent);

        // ✅ HU-5.0: Show green success SnackBar (visual feedback)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Documento validado y guardado con éxito'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // ✅ AÑADIMOS A LA MEMORIA ESTÁTICA
        _validatedDocs.add(widget.content.hashCode);

        if (mounted) {
          setState(() {
            _isValidating = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isValidating = false;
          });
        }
        rethrow;
      }
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

    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 1.5,
      color: isDark ? AppColors.textMain : Colors.black87,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(
        data: widget.content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: baseStyle,
          listBullet: baseStyle,
          code: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontSize: 16,
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

  Widget _buildActions(BuildContext context) {
    // 🔥 Leemos de la memoria absoluta. Si ya se validó, adiós botón.
    if (_isAlreadyValidated) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: _isValidating ? null : _handleValidation,
          icon: _isValidating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.check_circle),
          label: Text(_isValidating ? 'Validando...' : 'Validar y Guardar'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
