/// Utilities for parsing and detecting document formats in chat messages.
///
/// This module provides:
/// - HTML entity decoding for safe text rendering
/// - Document block detection via regex patterns
/// - Rail operation document identification
///
/// ## Usage
///
/// ```dart
/// // Decode HTML entities
/// final decoded = MessageParserUtils.decodeHtmlEntities(rawText);
///
/// // Detect document blocks
/// final matches = MessageParserUtils.documentBlockRegex.allMatches(text);
///
/// // Check if content is a rail operation document
/// final isRailDoc = MessageParserUtils.isRailOperationDocument(content);
/// ```
class MessageParserUtils {
  MessageParserUtils._(); // Private constructor (utility class)

  /// Regex pattern for detecting `<document>...</document>` blocks.
  ///
  /// Matches multi-line content between document tags.
  /// Case-insensitive, handles optional closing tag.
  ///
  /// Example matches:
  /// - `<document>content</document>`
  /// - `<DOCUMENT>content` (no closing tag)
  /// - `<document>\ncontent\n</document>`
  static final RegExp documentBlockRegex = RegExp(
    r'<document>\r?\n?([\s\S]*?)(?:</document>|$)',
    caseSensitive: false,
  );

  /// Decodes common HTML entities to their character equivalents.
  ///
  /// Handles:
  /// - `&amp;` → `&`
  /// - `&lt;` → `<`
  /// - `&gt;` → `>`
  /// - `&quot;` → `"`
  /// - `&#39;`, `&#x27;`, `&apos;` → `'`
  ///
  /// Example:
  /// ```dart
  /// final decoded = MessageParserUtils.decodeHtmlEntities(
  ///   'Hello &amp; welcome &lt;user&gt;!'
  /// );
  /// // Result: "Hello & welcome <user>!"
  /// ```
  static String decodeHtmlEntities(String text) => text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&#x27;', "'")
      .replaceAll('&apos;', "'");

  /// Detects if content represents a "rail operation" document.
  ///
  /// A rail operation document is identified by:
  /// - Contains `**Path:**` or `Path:` markers
  /// - Contains `**File:**` marker
  /// - Contains `[document]` tag
  /// - Contains code blocks (` ```json`, ` ```markdown`)
  /// - Is a JSON object (starts with `{` and ends with `}`)
  ///
  /// Example:
  /// ```dart
  /// final isRail = MessageParserUtils.isRailOperationDocument(
  ///   '**Path:** src/main.dart\n\n```json\n{...}\n```'
  /// );
  /// // Result: true
  /// ```
  static bool isRailOperationDocument(String content) {
    final trimmed = content.trim();
    return content.contains('**Path:**') ||
        content.contains('Path:') ||
        content.contains('**File:**') ||
        content.contains('[document]') ||
        content.contains('```json') ||
        content.contains('```markdown') ||
        (trimmed.startsWith('{') && trimmed.endsWith('}'));
  }
}
