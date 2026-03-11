import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/markdown_builders/mermaid_builder.dart';

// ════════════════════════════════════════════════════════════════════════════
// 1. SMART MESSAGE RENDERER
// ════════════════════════════════════════════════════════════════════════════

class SmartMessageRenderer extends StatelessWidget {
  const SmartMessageRenderer({
    required this.rawContent,
    required this.isUser,
    this.onSaveDocument,
    this.onSendChatMessage,
    super.key,
  });

  final String rawContent;
  final bool isUser;
  final Future<void> Function()? onSaveDocument;
  final Future<void> Function(String message)? onSendChatMessage;

  @override
  Widget build(BuildContext context) {
    final decodedContent = _decodeHtmlEntities(rawContent);

    if (isUser) {
      return _buildMarkdown(context, decodedContent);
    }

    final matches = _documentBlockRegex.allMatches(decodedContent);
    if (matches.isNotEmpty) {
      return _buildMixedContent(context, matches, decodedContent);
    }

    if (_isRailOperationDocument(decodedContent)) {
      return _buildRailMixedContent(context, decodedContent);
    }

    return _buildMarkdown(context, decodedContent);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. PARSING & FORMAT DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

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

  bool _isRailOperationDocument(String content) {
    final trimmed = content.trim();
    return content.contains('**Path:**') ||
        content.contains('Path:') ||
        content.contains('**File:**') ||
        content.contains('[document]') ||
        content.contains('```json') ||
        content.contains('```markdown') ||
        (trimmed.startsWith('{') && trimmed.endsWith('}'));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. UI BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRailMixedContent(BuildContext context, String content) {
    final elements = <Widget>[];
    var reasoningText = '';
    var documentText = content;

    if (content.contains('[document]')) {
      final parts = content.split('[document]');
      reasoningText = parts.first.trim();
      documentText = parts.length > 1 ? parts[1].trim() : '';

      if (reasoningText.startsWith('[Razonamiento]')) {
        reasoningText = reasoningText.replaceFirst('[Razonamiento]', '').trim();
      }
    } else {
      final pathIndex = content.indexOf('**Path:**');
      final altPathIndex = content.indexOf('Path:');
      final startIndex = pathIndex != -1
          ? pathIndex
          : (altPathIndex != -1 ? altPathIndex : -1);

      if (startIndex > 0) {
        reasoningText = content.substring(0, startIndex).trim();
        documentText = content.substring(startIndex).trim();
      }
    }

    if (reasoningText.isNotEmpty) {
      elements.add(_buildMarkdown(context, reasoningText));
      elements.add(const SizedBox(height: 12));
    }

    if (documentText.isNotEmpty) {
      // 🎯 MODIFICACIÓN: NO limpiamos el documento aquí para mantener los bloques ```json
      // Así el componente de Markdown puede renderizarlo con formato y colores.
      elements.add(
        _DocumentCard(
          key: ValueKey(documentText.hashCode),
          content: documentText, // Pasamos el contenido bruto con sus marcas
          onSave: onSaveDocument,
          onSendChatMessage: onSendChatMessage,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: elements,
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
          elements.add(_buildMarkdown(context, textBefore));
          elements.add(const SizedBox(height: 12));
        }
      }

      final documentContent = match.group(1)?.trim() ?? '';
      elements.add(
        _DocumentCard(
          key: ValueKey(documentContent.hashCode),
          content: documentContent,
          onSave: onSaveDocument,
          onSendChatMessage: onSendChatMessage,
        ),
      );
      elements.add(const SizedBox(height: 12));
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
      builders: {'code': MermaidBuilder()},
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
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        strong: baseStyle?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 4. DOCUMENT CARD WIDGET
// ════════════════════════════════════════════════════════════════════════════

class _DocumentCard extends StatefulWidget {
  const _DocumentCard({
    required this.content,
    this.onSave,
    this.onSendChatMessage,
    super.key,
  });
  final String content;
  final Future<void> Function()? onSave;
  final Future<void> Function(String message)? onSendChatMessage;

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  static final Set<int> _validatedDocs = {};
  static final Set<int> _dismissedDocs = {};

  bool _isValidating = false;
  bool _isRefining = false;
  bool _isValidatedLocally = false;
  bool _isDismissedLocally = false;

  bool get _isAlreadyValidated =>
      _isValidatedLocally || _validatedDocs.contains(widget.content.hashCode);
  bool get _isDismissed =>
      _isDismissedLocally || _dismissedDocs.contains(widget.content.hashCode);

  Future<void> _handleValidation() async {
    if (_isValidating || _isAlreadyValidated) {
      return;
    }
    setState(() => _isValidating = true);

    if (widget.onSave != null) {
      try {
        await widget.onSave!();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Documento validado y guardado con éxito'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        _validatedDocs.add(widget.content.hashCode);
        if (mounted) {
          setState(() {
            _isValidating = false;
            _isValidatedLocally = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isValidating = false);
        }
        rethrow;
      }
    }
  }

  Future<void> _handleRefine() async {
    if (_isRefining ||
        _isAlreadyValidated ||
        _isDismissed ||
        widget.onSendChatMessage == null) {
      return;
    }
    setState(() => _isRefining = true);
    try {
      await widget.onSendChatMessage!('Deseo refinar este documento: ');
    } finally {
      if (mounted) {
        setState(() => _isRefining = false);
      }
    }
  }

  void _handleReject() {
    setState(() {
      _isDismissedLocally = true;
      _dismissedDocs.add(widget.content.hashCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: _buildContent(context),
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: const Border(bottom: BorderSide(color: AppColors.border)),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: Colors.blueAccent,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'PROPUESTA DE DOCUMENTO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        InkWell(
          onTap: () => Clipboard.setData(ClipboardData(text: widget.content)),
          child: const Row(
            children: [
              Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Copiar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🎯 MEJORA: Usamos MarkdownBody SIEMPRE, incluso para el JSON.
    // Si el contenido tiene ```json, MarkdownBody lo indentará y coloreará automáticamente.
    // Si no los tiene, lo envolveremos visualmente para el renderizado.
    var displayData = widget.content.trim();
    if (!displayData.contains('```') &&
        (displayData.startsWith('{') || displayData.startsWith('['))) {
      displayData = '```json\n$displayData\n```';
    }

    return Container(
      width: double.infinity,
      color: AppColors.mainBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: displayData,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textMain : Colors.black87,
            ),
            code: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: isDark
                  ? Colors.greenAccent.shade100
                  : Colors.blue.shade800,
            ),
            codeblockPadding: const EdgeInsets.all(12),
            codeblockDecoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _isValidating || _isRefining ? null : _handleReject,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Rechazar'),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _isValidating || _isRefining ? null : _handleRefine,
              icon: const Icon(Icons.edit, size: 16),
              label: Text(_isRefining ? 'Refinando...' : 'Refinar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _isValidating || _isRefining
                  ? null
                  : _handleValidation,
              icon: _isValidating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 16),
              label: Text(_isValidating ? 'Validando...' : 'Validar y Guardar'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            ),
          ],
        ),
      ],
    ),
  );
}
