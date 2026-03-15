import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/theme/app_colors.dart';
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
      color: isDark ? AppColors.textMain : Colors.black87,
    );

    return MarkdownBody(
      data: content,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      builders: {'code': CodeElementBuilder()},
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
