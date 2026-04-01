import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../shared/presentation/widgets/markdown_builders/code_element_builder.dart';
import 'document_proposal_card.dart';
import 'message_parser_utils.dart';

/// Smart renderer for chat messages with adaptive formatting.
///
/// Automatically detects and renders:
/// - **User messages**: Plain markdown
/// - **AI messages with `<document>` blocks**: Extracts and renders as
///   interactive [DocumentProposalCard]
/// - **Rail operation documents**: Splits reasoning from document content
/// - **Standard AI messages**: Plain markdown with code highlighting
///
/// ## Architecture (SOLID - Single Responsibility)
///
/// This class follows SRP by delegating:
/// - **Parsing logic** → [MessageParserUtils]
/// - **Document cards** → [DocumentProposalCard]
/// - **Rendering** → This class (routing only)
///
/// ## Usage
///
/// ```dart
/// SmartMessageRenderer(
///   rawContent: message.content,
///   isUser: message.role == 'user',
///   onSaveDocument: () async {
///     await saveToFile(extractedDocument);
///   },
///   onSendChatMessage: (refinementPrompt) async {
///     await chatNotifier.sendMessage(refinementPrompt);
///   },
/// )
/// ```
class SmartMessageRenderer extends StatelessWidget {
  /// Creates a smart message renderer.
  ///
  /// Parameters:
  /// - [rawContent]: The raw message content (may contain HTML entities)
  /// - [isUser]: Whether this is a user message (vs AI message)
  /// - [onSaveDocument]: Callback for saving extracted documents
  /// - [onSendChatMessage]: Callback for sending refinement requests
  const SmartMessageRenderer({
    required this.rawContent,
    required this.isUser,
    this.onSaveDocument,
    this.onSendChatMessage,
    super.key,
  });

  /// The raw message content to render.
  final String rawContent;

  /// Whether this message is from the user (vs AI).
  final bool isUser;

  /// Callback invoked when user validates a document proposal.
  final Future<void> Function()? onSaveDocument;

  /// Callback invoked when user requests document refinement.
  final Future<void> Function(String message)? onSendChatMessage;

  @override
  Widget build(BuildContext context) {
    final decodedContent = MessageParserUtils.decodeHtmlEntities(rawContent);

    if (isUser) {
      return _buildMarkdown(context, decodedContent);
    }

    final matches = MessageParserUtils.documentBlockRegex.allMatches(
      decodedContent,
    );
    if (matches.isNotEmpty) {
      return _buildMixedContent(context, matches, decodedContent);
    }

    if (MessageParserUtils.isRailOperationDocument(decodedContent)) {
      return _buildRailMixedContent(context, decodedContent);
    }

    return _buildMarkdown(context, decodedContent);
  }

  /// Builds content for rail operation documents (with **Path:** headers).
  ///
  /// Splits content into reasoning text and document content, then renders:
  /// - Reasoning as markdown (optional)
  /// - Document as [DocumentProposalCard] (handles JSON detection internally)
  ///
  /// Supports two formats:
  /// - `[Razonamiento] ... [document] ...` (legacy format)
  /// - `<reasoning text> **Path:** <path> <document>` (current format)
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
      elements
        ..add(_buildMarkdown(context, reasoningText))
        ..add(const SizedBox(height: 12));
    }

    if (documentText.isNotEmpty) {
      elements.add(
        DocumentProposalCard(
          key: ValueKey(documentText.hashCode),
          content: documentText,
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

  /// Builds content with embedded `<document>...</document>` blocks.
  ///
  /// Extracts document blocks using regex and renders:
  /// - Text before/after documents as markdown
  /// - Documents as [DocumentProposalCard] instances (handles JSON internally)
  ///
  /// This method processes multiple document blocks in a single message.
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
          DocumentProposalCard(
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

  /// Detects the LLM pattern `Path: <file>.json\n{...raw json...}` and
  /// converts it into a display-safe Markdown string for the chat UI.
  ///
  /// **This method is for display only.** The original [content] string must
  /// be used when saving the file to disk so no Markdown backticks are written.
  ///
  /// ### Input (raw LLM output)
  /// ```
  /// Path: context/20-REQUIREMENTS/USER_STORIES_MASTER.json
  /// { "project_name": "PadelMatch Local", ... }
  /// ```
  ///
  /// ### Output (display text)
  /// ```
  /// `Path: context/20-REQUIREMENTS/USER_STORIES_MASTER.json`
  ///
  /// ```json
  /// {
  ///   "project_name": "PadelMatch Local",
  ///   ...
  /// }
  /// ```
  /// ```
  ///
  /// If the content does not match the pattern, it is returned unchanged.
  ///
  /// Supports both plain (`Path:`) and bold (`**Path:**`) header variants.
  static String _formatJsonPathBlock(String content) {
    // Matches optional bold markers and captures:
    //   group(1) → the raw path   (e.g. context/foo/bar.json)
    //   group(2) → the JSON body  (everything after the path line)
    final match = RegExp(
      r'^\*{0,2}Path:\*{0,2}\s+(\S+\.json)\s*\n([\s\S]+)$',
      caseSensitive: false,
    ).firstMatch(content.trim());

    if (match == null) {
      return content;
    }

    final pathValue = match.group(1)!;
    final jsonBody = match.group(2)!.trim();

    // Only wrap when the body is actually valid JSON – if the LLM produced
    // something malformed, fall back to the raw string so nothing is lost.
    try {
      final decoded = jsonDecode(jsonBody);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      return '`Path: $pathValue`\n\n```json\n$pretty\n```';
    } on FormatException {
      // Body is not valid JSON – return as-is.
      return content;
    }
  }

  /// Detects if [content] is a raw (unformatted) JSON string and pretty-prints
  /// it as a fenced markdown code block.
  ///
  /// A single-line JSON string has no word-break opportunities, which causes
  /// Flutter's [SelectableRegion] to throw:
  /// `'Drag target size is larger than scrollable size'`
  /// because the text widget grows wider than the scrollable container.
  ///
  /// By converting it to an indented ` ```json ` block the text gains natural
  /// break points and the [LayoutBuilder] constraint can enforce the max width.
  static String _formatIfJson(String content) {
    final trimmed = content.trim();
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        final decoded = jsonDecode(trimmed);
        final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
        return '```json\n$formatted\n```';
      } on FormatException {
        // Not valid JSON – render the content as-is.
      }
    }
    return content;
  }

  /// Builds standard markdown content with syntax highlighting.
  ///
  /// Renders plain markdown text with:
  /// - GitHub Flavored Markdown support
  /// - Code syntax highlighting via [CodeElementBuilder]
  /// - Theme-aware text colors
  /// - Selectable text for copy/paste
  Widget _buildMarkdown(BuildContext context, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 1.6,
      color: context.appColors.textMain,
    );

    // 1. Try Path + JSON pattern first (most specific: "Path: *.json\n{...}").
    // 2. Fall back to bare-JSON detection for pure JSON blob responses.
    // Both helpers are display-only: the original [content] string is
    // untouched by callers that write content to disk (DocumentProposalCard).
    final displayContent = _formatIfJson(_formatJsonPathBlock(content));

    // LayoutBuilder ensures MarkdownBody (and its internal SelectableRegion)
    // is always bounded by available width, preventing the
    // 'Drag target size is larger than scrollable size' assertion.
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth),
        child: MarkdownBody(
          data: displayContent,
          selectable: true,
          extensionSet: md.ExtensionSet.gitHubFlavored,
          builders: {
            'code': CodeElementBuilder(
              codeBgColor: Theme.of(
                context,
              ).extension<AppColorsExtension>()?.cardBg,
              codeBorderColor: Theme.of(
                context,
              ).extension<AppColorsExtension>()?.cardBorder,
            ),
          },
          styleSheet: MarkdownStyleSheet(
            p: baseStyle,
            listBullet: baseStyle,
            code: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: 15,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: isDark
                  ? Colors.greenAccent.shade100
                  : Colors.blue.shade800,
            ),
            h1: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            h2: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            strong: baseStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
