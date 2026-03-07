import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:softarchitect_ai/shared/presentation/widgets/markdown_builders/mermaid_builder.dart';
import 'package:softarchitect_ai/shared/presentation/widgets/mermaid_view.dart';

/// Unit tests for [MermaidBuilder].
///
/// Test Coverage:
/// - Returns [MermaidView] when the element class is `language-mermaid`
/// - Returns `null` for any non-Mermaid code class
/// - Returns `null` when the element has no class attribute
/// - Passes the raw text content verbatim to [MermaidView]
/// - Returns [MermaidView] when `language-mermaid` appears alongside other classes
void main() {
  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// Builds a `<code>` [md.Element] with the given [cssClass] and [text].
  md.Element codeElement({String cssClass = '', String text = 'A --> B'}) {
    final element = md.Element('code', [md.Text(text)]);
    if (cssClass.isNotEmpty) {
      element.attributes['class'] = cssClass;
    }
    return element;
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('MermaidBuilder.visitElementAfter', () {
    late MermaidBuilder builder;

    setUp(() {
      builder = MermaidBuilder();
    });

    test('returns MermaidView for language-mermaid class', () {
      final element = codeElement(cssClass: 'language-mermaid');
      final result = builder.visitElementAfter(element, null);

      expect(result, isA<MermaidView>());
    });

    test('returns null for language-dart class', () {
      final element = codeElement(cssClass: 'language-dart');
      final result = builder.visitElementAfter(element, null);

      expect(result, isNull);
    });

    test('returns null for language-python class', () {
      final element = codeElement(cssClass: 'language-python');
      final result = builder.visitElementAfter(element, null);

      expect(result, isNull);
    });

    test('returns null when class attribute is absent', () {
      final element = codeElement(cssClass: '');
      final result = builder.visitElementAfter(element, null);

      expect(result, isNull);
    });

    test('returns null for empty class attribute', () {
      final element = codeElement(cssClass: '   ');
      final result = builder.visitElementAfter(element, null);

      expect(result, isNull);
    });

    test('passes raw text content verbatim to MermaidView', () {
      const mermaidCode = 'graph LR\nA --> B\nB --> C';
      final element = codeElement(
        cssClass: 'language-mermaid',
        text: mermaidCode,
      );
      final result = builder.visitElementAfter(element, null);

      expect(result, isA<MermaidView>());
      final view = result! as MermaidView;
      expect(view.code, equals(mermaidCode));
    });

    test(
      'returns MermaidView when language-mermaid is among multiple classes',
      () {
        // Some Markdown parsers may output compound class lists.
        final element = codeElement(
          cssClass: 'highlight language-mermaid dark',
        );
        final result = builder.visitElementAfter(element, null);

        expect(result, isA<MermaidView>());
      },
    );

    test(
      'ignores preferredStyle parameter (returns MermaidView regardless)',
      () {
        final element = codeElement(cssClass: 'language-mermaid');
        const style = TextStyle(fontSize: 14);

        final resultWithStyle = builder.visitElementAfter(element, style);
        final resultWithout = builder.visitElementAfter(element, null);

        expect(resultWithStyle, isA<MermaidView>());
        expect(resultWithout, isA<MermaidView>());
      },
    );

    test('passes empty string to MermaidView for empty code block', () {
      final element = codeElement(cssClass: 'language-mermaid', text: '');
      final result = builder.visitElementAfter(element, null);

      expect(result, isA<MermaidView>());
      final view = result! as MermaidView;
      expect(view.code, isEmpty);
    });
  });
}
