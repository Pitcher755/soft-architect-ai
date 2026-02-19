import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Intelligent message renderer for chat interface.
///
/// Parses AI-generated messages to detect and render document artifacts as
/// premium cards while preserving normal markdown rendering for text content.
///
/// **Rendering Logic:**
/// - User messages: Pass through as plain markdown (no parsing)
/// - AI messages without documents: Standard markdown rendering
/// - AI messages with documents: Parse and render premium [_DocumentCard]s
///
/// **Document Block Format:**
/// ```
/// ```document
/// **Path:** `path/to/file.md`
/// # Document content here
/// ```
/// ```
///
/// **Features:**
/// - RegEx-based document block detection
/// - Automatic path extraction from **Path:** or **Ruta:** metadata
/// - Selectable text for copy/paste functionality
/// - Premium card UI for document artifacts
/// - Dark/light theme support
/// - "Validate and Save" action button with callback
///
/// **Example Usage:**
/// ```dart
/// SmartMessageRenderer(
///   rawContent: message.content,
///   isUser: message.role == 'user',
///   onSaveDocument: (path, cleanContent) {
///     // Save file logic here
///     fileSystemProvider.writeFile(path, cleanContent);
///   },
/// )
/// ```
class SmartMessageRenderer extends StatelessWidget {
  /// Creates a smart message renderer.
  ///
  /// [rawContent] is the complete message text that may contain
  /// document blocks.
  /// [isUser] determines if this is a user message (true) or
  /// AI message (false).
  /// [onSaveDocument] is called when user validates a document,
  /// providing the extracted path and cleaned content.
  const SmartMessageRenderer({
    required this.rawContent,
    required this.isUser,
    this.onSaveDocument,
    super.key,
  });

  /// The raw message content, potentially containing ```document blocks.
  final String rawContent;

  /// Whether this message is from the user (true) or AI assistant (false).
  final bool isUser;

  /// Callback triggered when user approves a document for saving.
  ///
  /// Provides:
  /// - `path`: Extracted file path from document metadata
  /// - `content`: Cleaned content (path metadata line removed)
  final void Function(String path, String content)? onSaveDocument;

  /// RegEx pattern to match document blocks.
  ///
  /// Matches: ```document\n{content}\n```
  /// Captures the document content in group 1.
  static final RegExp _documentBlockRegex = RegExp(
    r'```document\n([\s\S]*?)```',
    multiLine: true,
  );

  @override
  Widget build(BuildContext context) {
    // User messages: Pass through without parsing
    if (isUser) {
      return _buildMarkdown(context, rawContent);
    }

    // AI messages: Check for document blocks
    final matches = _documentBlockRegex.allMatches(rawContent);

    // No documents found: Render as plain markdown
    if (matches.isEmpty) {
      return _buildMarkdown(context, rawContent);
    }

    // Documents found: Parse and render mixed content
    return _buildMixedContent(context, matches);
  }

  /// Builds a standard markdown widget with selectable text.
  Widget _buildMarkdown(BuildContext context, String content) => MarkdownBody(
    data: content,
    selectable: true,
    styleSheet: MarkdownStyleSheet(
      p: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      code: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    ),
  );

  /// Builds mixed content with document cards and text sections.
  Widget _buildMixedContent(
    BuildContext context,
    Iterable<RegExpMatch> matches,
  ) {
    final elements = <Widget>[];
    var currentIndex = 0;

    for (final match in matches) {
      // Add text BEFORE this document block
      if (match.start > currentIndex) {
        final textBefore = rawContent
            .substring(currentIndex, match.start)
            .trim();
        if (textBefore.isNotEmpty) {
          elements
            ..add(_buildMarkdown(context, textBefore))
            ..add(const SizedBox(height: 12));
        }
      }

      // Add the document card
      final documentContent = match.group(1)?.trim() ?? '';
      elements
        ..add(
          _DocumentCard(
            content: documentContent,
            onSave: onSaveDocument,
          ),
        )
        ..add(const SizedBox(height: 12));

      currentIndex = match.end;
    }

    // Add text AFTER last document block
    if (currentIndex < rawContent.length) {
      final textAfter = rawContent.substring(currentIndex).trim();
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

/// Premium card widget for rendering document artifacts.
///
/// Displays engineering artifacts with enhanced visual hierarchy:
/// - Header with icon and label
/// - Colored border with theme-aware primary color
/// - Drop shadow for depth
/// - Validate button that extracts path and triggers save callback
///
/// **Path Extraction:**
/// Detects `**Path:** path/to/file.md` or `**Ruta:** path/to/file.md`
/// in the document content and extracts it for file system operations.
///
/// **Design Principles:**
/// - Clear visual separation from chat text
/// - Professional engineering aesthetic
/// - Actionable UI (validate and save button)
/// - Theme-aware styling (dark/light modes)
class _DocumentCard extends StatelessWidget {
  /// Creates a document card.
  ///
  /// [content] is the parsed document content from the ```document block.
  /// [onSave] is called when user validates the document, providing
  /// the extracted path and cleaned content.
  const _DocumentCard({
    required this.content,
    this.onSave,
  });

  /// The document content extracted from the markdown block.
  final String content;

  /// Callback to save the document to file system.
  final void Function(String path, String cleanContent)? onSave;

  /// Extracts path from document metadata and triggers save callback.
  ///
  /// **Path Detection:**
  /// Searches for `**Path:** path` or `**Ruta:** path` in the content.
  /// Falls back to `context/UNSORTED/untitled.md` if no path found.
  ///
  /// **Content Cleaning:**
  /// Removes the path metadata line to avoid duplicating it in the file.
  void _handleValidation() {
    // 1. Search for "**Path:** `path`" or "**Ruta:** `path`" line
    final pathRegex = RegExp(
      r'\*\*(?:Path|Ruta):\*\*\s*`?([^\n`]+)`?',
      caseSensitive: false,
    );
    final match = pathRegex.firstMatch(content);

    // 2. Extract path (or use safety fallback)
    final extractedPath =
        match?.group(1)?.trim() ?? 'context/UNSORTED/untitled.md';

    // 3. Clean content to avoid saving path metadata in final file
    final cleanContent = content.replaceAll(pathRegex, '').trim();

    // 4. Trigger save callback
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

  /// Builds the card header with icon and label.
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
            'ARTEFACTO DE INGENIERÍA',
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

  /// Builds the document content section with markdown rendering.
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          code: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          h1: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Builds the action button section.
  Widget _buildActions(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () {
              // Trigger validation and save
              _handleValidation();

              // Visual feedback
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
