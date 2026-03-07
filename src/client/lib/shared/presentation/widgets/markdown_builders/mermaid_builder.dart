import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../mermaid_view.dart';

/// A [MarkdownElementBuilder] that intercepts fenced Mermaid code blocks
/// and renders them with [MermaidView].
///
/// Inject via `MarkdownBody(builders: {'code': MermaidBuilder()})`.
/// Non-Mermaid code blocks are left untouched (returns `null`).
class MermaidBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // A ```mermaid block is parsed as <code class="language-mermaid">.
    final classList = element.attributes['class'] ?? '';
    if (classList.contains('language-mermaid')) {
      return MermaidView(code: element.textContent);
    }
    return null;
  }
}
