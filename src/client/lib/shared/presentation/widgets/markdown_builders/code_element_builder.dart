import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../mermaid_view.dart';

/// A hybrid [MarkdownElementBuilder] for fenced code blocks.
///
/// Routes by language attribute:
/// - **Mermaid diagrams** → [MermaidView] (rendered via mermaid.ink)
/// - **All other languages** → [HighlightView] (syntax highlighting)
///
/// ## Usage
///
/// ```dart
/// MarkdownBody(
///   data: content,
///   builders: {'code': CodeElementBuilder()},
///   extensionSet: md.ExtensionSet.gitHubFlavored,
/// )
/// ```
///
/// ## Supported Languages
///
/// Supports 185+ languages via `flutter_highlighter`:
/// - dart, json, yaml, python, javascript, typescript, bash, etc.
/// - See: https://pub.dev/packages/flutter_highlighter
///
/// ## Design Pattern
///
/// Follows **Strategy Pattern**:
/// - Detects language from `class="language-xxx"` attribute
/// - Delegates rendering to specialized widgets
///   ([MermaidView] or [HighlightView])
/// - Returns null if no specific handler needed (fallback to default)
class CodeElementBuilder extends MarkdownElementBuilder {
  /// Creates a code element builder with optional custom theme.
  ///
  /// Parameters:
  /// - [theme]: Syntax highlighting theme (default: [atomOneDarkTheme])
  /// - [textStyle]: Custom text style for code blocks
  CodeElementBuilder({
    this.theme = atomOneDarkTheme,
    this.textStyle = const TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 13,
      height: 1.4,
    ),
  });

  /// Syntax highlighting theme for code blocks.
  final Map<String, TextStyle> theme;

  /// Text style applied to code content.
  final TextStyle textStyle;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Extract language from class attribute (e.g., "language-dart")
    var language = '';
    if (element.attributes['class'] != null) {
      final classValue = element.attributes['class'] as String;
      language = classValue.startsWith('language-')
          ? classValue.substring(9)
          : classValue;
    }

    // Extract code content (remove trailing newline if present)
    final codeContent = element.textContent.endsWith('\n')
        ? element.textContent.substring(0, element.textContent.length - 1)
        : element.textContent;

    // Route to MermaidView for diagrams
    if (language == 'mermaid') {
      return MermaidView(code: codeContent);
    }

    // Route to HighlightView for syntax highlighting
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), // GitHub dark code block bg
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30363D)), // Subtle border
      ),
      child: HighlightView(
        codeContent,
        language: language,
        theme: theme,
        padding: const EdgeInsets.all(12),
        textStyle: textStyle,
      ),
    );
  }
}
