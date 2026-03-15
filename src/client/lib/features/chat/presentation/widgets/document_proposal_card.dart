import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/markdown_builders/code_element_builder.dart';

/// Interactive card widget for displaying document proposals from AI.
///
/// Provides three actions:
/// - **Validate & Save**: Confirms and persists the document
/// - **Refine**: Requests AI to improve the proposal
/// - **Reject**: Dismisses the proposal
///
/// ## Features
///
/// - Auto-detects and wraps pure JSON content in code blocks
/// - Maintains validation state across widget rebuilds (static sets)
/// - Disables actions while processing (prevents double-submission)
/// - Shows snackbar feedback on validation success
/// - Markdown rendering with syntax highlighting
///
/// ## Usage
///
/// ```dart
/// DocumentProposalCard(
///   content: jsonDocument,
///   onSave: () async {
///     await saveToFile(jsonDocument);
///   },
///   onSendChatMessage: (message) async {
///     await chatNotifier.sendMessage(message);
///   },
/// )
/// ```
class DocumentProposalCard extends StatefulWidget {
  /// Creates a document proposal card.
  ///
  /// Parameters:
  /// - [content]: The document content (JSON, Markdown, or plain text)
  /// - [onSave]: Callback invoked when user validates (optional)
  /// - [onSendChatMessage]: Callback for AI refinement requests (optional)
  const DocumentProposalCard({
    required this.content,
    this.onSave,
    this.onSendChatMessage,
    super.key,
  });

  /// The document content to display.
  final String content;

  /// Callback invoked when user clicks "Validate & Save".
  ///
  /// Should persist the document to disk or database.
  final Future<void> Function()? onSave;

  /// Callback invoked when user clicks "Refine".
  ///
  /// Should send a refinement request to the AI chatbot.
  /// The message parameter contains the user's refinement prompt.
  final Future<void> Function(String message)? onSendChatMessage;

  @override
  State<DocumentProposalCard> createState() => _DocumentProposalCardState();
}

class _DocumentProposalCardState extends State<DocumentProposalCard> {
  // Static sets to persist state across widget rebuilds
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

  /// Builds the content view based on document type.
  ///
  /// Detects JSON documents (either with `**Path:** ...json` header or
  /// pure JSON) and renders them with syntax highlighting using
  /// [HighlightView]. Other content types use standard Markdown rendering.
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if this is a JSON document with Path header
    final pathMatch = RegExp(
      r'\*\*Path:\*\*\s+(.+?\.json)',
      caseSensitive: false,
    ).firstMatch(widget.content);

    if (pathMatch != null) {
      // Extract JSON content after the path header
      final pathEndIndex = pathMatch.end;
      final jsonContent = widget.content.substring(pathEndIndex).trim();

      if (jsonContent.startsWith('{') || jsonContent.startsWith('[')) {
        return _buildJsonView(jsonContent);
      }
    }

    // Fallback: Check if pure JSON without path header
    final trimmedContent = widget.content.trim();
    if ((trimmedContent.startsWith('{') || trimmedContent.startsWith('[')) &&
        !trimmedContent.contains('```')) {
      return _buildJsonView(trimmedContent);
    }

    // Standard markdown rendering for non-JSON content
    return Container(
      width: double.infinity,
      color: AppColors.mainBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: widget.content,
          selectable: true,
          extensionSet: md.ExtensionSet.gitHubFlavored,
          builders: {'code': CodeElementBuilder()},
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

  /// Builds a specialized view for JSON content with syntax highlighting.
  ///
  /// Uses [HighlightView] from flutter_highlighter with Atom One Dark theme
  /// for consistent, readable JSON formatting. This matches the rendering
  /// used in the markdown preview widget.
  Widget _buildJsonView(String jsonContent) => Container(
    width: double.infinity,
    color: AppColors.mainBg,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectionArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          padding: const EdgeInsets.all(16),
          child: HighlightView(
            jsonContent,
            language: 'json',
            theme: atomOneDarkTheme,
            textStyle: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ),
    ),
  );

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
