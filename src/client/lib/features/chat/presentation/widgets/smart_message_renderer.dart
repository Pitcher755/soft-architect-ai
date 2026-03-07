import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/markdown_builders/mermaid_builder.dart';

/// Intelligent message renderer for chat interface.
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
  final Future<void> Function(String path, String content)? onSaveDocument;
  final Future<void> Function(String message)? onSendChatMessage;

  // RegEx for legacy XML format
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

    // 1. BACKWARD COMPATIBILITY WITH LEGACY XML FORMAT
    final matches = _documentBlockRegex.allMatches(decodedContent);
    if (matches.isNotEmpty) {
      return _buildMixedContent(context, matches, decodedContent);
    }

    // 2. NEW "OPERATION RAILS" FORMAT (With brackets or Path keyword)
    if (_isRailOperationDocument(decodedContent)) {
      return _buildRailMixedContent(context, decodedContent);
    }

    // 3. IF NO DOCUMENT DETECTED, IT'S JUST A CHAT MESSAGE
    return _buildMarkdown(context, decodedContent);
  }

  /// Detects if the text is from Operation Rails format.
  bool _isRailOperationDocument(String content) =>
      content.contains('**Path:**') ||
      content.contains('Path:') ||
      content.contains('**File:**') ||
      content.contains('[document]');

  /// Splits content between reasoning and document, building the appropriate widgets.
  Widget _buildRailMixedContent(BuildContext context, String content) {
    final elements = <Widget>[];
    var reasoningText = '';
    var documentText = content;

    // Si el LLM usó la etiqueta [document], cortamos por ahí
    if (content.contains('[document]')) {
      final parts = content.split('[document]');
      reasoningText = parts.first.trim();
      documentText = parts.length > 1 ? parts[1].trim() : '';

      // Limpiamos la etiqueta [Razonamiento] si la puso
      if (reasoningText.startsWith('[Razonamiento]')) {
        reasoningText = reasoningText.replaceFirst('[Razonamiento]', '').trim();
      }
    } else {
      // If no [document] tag but has Path keyword, attempt to infer where document starts
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

    // 1. Render reasoning (if present) as a normal message
    if (reasoningText.isNotEmpty) {
      elements.add(_buildMarkdown(context, reasoningText));
      elements.add(const SizedBox(height: 12));
    }

    // 2. Render document (if present) inside its Card
    if (documentText.isNotEmpty) {
      final cleanDocument = _cleanRailDocument(documentText);
      elements.add(
        _DocumentCard(
          key: ValueKey(cleanDocument.hashCode),
          content: cleanDocument,
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

  /// Cleans code blocks or extra tags from the document.
  String _cleanRailDocument(String content) {
    var result = content;

    // If LLM wrapped document in a markdown code block, remove it
    if (result.trim().startsWith('```markdown')) {
      result = result.replaceFirst('```markdown', '').trim();
      if (result.trim().endsWith('```')) {
        result = result.substring(0, result.lastIndexOf('```')).trim();
      }
    }
    return result.trim();
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
            onSendChatMessage: onSendChatMessage,
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
  const _DocumentCard({
    required this.content,
    this.onSave,
    this.onSendChatMessage,
    super.key,
  });

  final String content;
  final Future<void> Function(String path, String cleanContent)? onSave;
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

  static final RegExp _pathRegex = RegExp(
    r'\*\*(?:Path|Ruta):\*\*\s*`?([^\n`]+)`?',
    caseSensitive: false,
  );

  String _extractPath() {
    final match = _pathRegex.firstMatch(widget.content);
    return match?.group(1)?.trim() ?? 'context/UNSORTED/untitled.md';
  }

  String _extractCleanContent() =>
      widget.content.replaceAll(_pathRegex, '').trim();

  Future<void> _handleValidation() async {
    if (_isValidating || _isAlreadyValidated) {
      return;
    }

    setState(() {
      _isValidating = true;
    });

    final extractedPath = _extractPath();
    final cleanContent = _extractCleanContent();

    if (widget.onSave != null) {
      try {
        await widget.onSave!(extractedPath, cleanContent);

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

        _validatedDocs.add(widget.content.hashCode);

        if (mounted) {
          setState(() {
            _isValidating = false;
            _isValidatedLocally = true;
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

  Future<void> _handleRefine() async {
    if (_isRefining || _isAlreadyValidated || _isDismissed) {
      return;
    }

    final extractedPath = _extractPath();
    final refineMessage = 'Deseo refinar el documento en $extractedPath: ';

    if (widget.onSendChatMessage == null) {
      return;
    }

    setState(() {
      _isRefining = true;
    });

    try {
      await widget.onSendChatMessage!(refineMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isRefining = false;
        });
      }
    }
  }

  void _handleReject() {
    if (_isAlreadyValidated || _isDismissed) {
      return;
    }

    setState(() {
      _dismissedDocs.add(widget.content.hashCode);
      _isDismissedLocally = true;
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
            constraints: const BoxConstraints(maxHeight: 700),
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
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            Text(
              'DOCUMENTO GENERADO',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
              ),
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

    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 1.5,
      color: isDark ? AppColors.textMain : Colors.black87,
    );

    return Container(
      color: AppColors.mainBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: widget.content,
          selectable: true,
          builders: {'code': MermaidBuilder()},
          styleSheet: MarkdownStyleSheet(
            p: baseStyle,
            listBullet: baseStyle,
            code: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: 16,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: isDark
                  ? Colors.greenAccent.shade100
                  : Colors.blue.shade800,
            ),
            h1: theme.textTheme.titleLarge?.copyWith(
              color: baseStyle?.color,
              fontWeight: FontWeight.bold,
            ),
            h2: theme.textTheme.titleMedium?.copyWith(
              color: baseStyle?.color,
              fontWeight: FontWeight.bold,
            ),
            strong: baseStyle?.copyWith(fontWeight: FontWeight.bold),
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
          key: const Key('proposal_reject_button'),
          onPressed: _isValidating || _isRefining ? null : _handleReject,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Rechazar'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              key: const Key('proposal_refine_button'),
              onPressed: _isValidating || _isRefining ? null : _handleRefine,
              icon: _isRefining
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit, size: 16),
              label: Text(_isRefining ? 'Refinando...' : 'Refinar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const Key('proposal_validate_button'),
              onPressed: _isValidating || _isRefining
                  ? null
                  : _handleValidation,
              icon: _isValidating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 16),
              label: Text(_isValidating ? 'Validando...' : 'Validar y Guardar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
