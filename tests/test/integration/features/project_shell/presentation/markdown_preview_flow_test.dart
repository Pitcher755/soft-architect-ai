// tests/integration/flutter/features/project_shell/presentation/markdown_preview_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/markdown_preview_widget.dart';

void main() {
  group('Markdown Preview Flow Integration Test', () {
    testWidgets('should handle complete markdown preview workflow', (WidgetTester tester) async {
      const testMarkdown = '''
# Project Title

This is a **bold** text and *italic* text.

## Features

- Feature 1
- Feature 2
- Feature 3

### Code Example

```dart
void main() {
  print('Hello, World!');
}
```

> This is a blockquote

### Table

| Column 1 | Column 2 |
|----------|----------|
| Data 1   | Data 2   |
| Data 3   | Data 4   |

---

[Link to Google](https://google.com)
''';

      // When - Render markdown preview
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: testMarkdown,
            ),
          ),
        ),
      );

      // Then - All markdown elements should be rendered
      expect(find.text('Project Title'), findsOneWidget);
      expect(find.text('This is a bold text and italic text.'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Feature 1'), findsOneWidget);
      expect(find.text('Feature 2'), findsOneWidget);
      expect(find.text('Feature 3'), findsOneWidget);
      expect(find.text('Code Example'), findsOneWidget);
      expect(find.text('This is a blockquote'), findsOneWidget);
      expect(find.text('Table'), findsOneWidget);
      expect(find.text('Column 1'), findsOneWidget);
      expect(find.text('Column 2'), findsOneWidget);
      expect(find.text('Data 1'), findsOneWidget);
      expect(find.text('Link to Google'), findsOneWidget);

      // Code block should be present
      expect(find.text("void main() {\n  print('Hello, World!');\n}"), findsOneWidget);
    });

    testWidgets('should handle large content efficiently', (WidgetTester tester) async {
      // Create moderately large markdown content
      final largeContent = StringBuffer();
      largeContent.writeln('# Large Document\n');
      largeContent.writeln('This is a test document.\n');
      for (int i = 0; i < 10; i++) {
        largeContent.writeln('## Section $i\n');
        largeContent.writeln('This is paragraph $i with some content.\n');
      }

      // When - Render large content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: largeContent.toString(),
            ),
          ),
        ),
      );

      // Then - Should render without crashing
      expect(find.text('Large Document'), findsOneWidget);
      expect(find.text('This is a test document.'), findsOneWidget);
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });

    testWidgets('should handle special characters correctly', (WidgetTester tester) async {
      const specialCharsMarkdown = '''
# Special Characters

- Ampersand: &
- Less than: <
- Greater than: >
- Quote: "
- Apostrophe: '

## Math

E = mc²

## Unicode

- Café
- naïve
- résumé
''';

      // When - Render special characters
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: specialCharsMarkdown,
            ),
          ),
        ),
      );

      // Then - Special characters should be rendered
      expect(find.text('Special Characters'), findsOneWidget);
      expect(find.text('Ampersand: &'), findsOneWidget);
      expect(find.text('Less than: <'), findsOneWidget);
      expect(find.text('Greater than: >'), findsOneWidget);
      expect(find.text('Quote: "'), findsOneWidget);
      expect(find.text('Apostrophe: \''), findsOneWidget);
      expect(find.text('E = mc²'), findsOneWidget);
      expect(find.text('Café'), findsOneWidget);
      expect(find.text('naïve'), findsOneWidget);
      expect(find.text('résumé'), findsOneWidget);
    });

    testWidgets('should handle markdown with links correctly', (WidgetTester tester) async {
      const linksMarkdown = '''
# Links Test

This document contains links.

## Section 1

Content here.
''';

      // When - Render markdown with links
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: linksMarkdown,
            ),
          ),
        ),
      );

      // Then - Basic content should be rendered
      expect(find.text('Links Test'), findsOneWidget);
      expect(find.text('This document contains links.'), findsOneWidget);
      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Content here.'), findsOneWidget);
    });

    testWidgets('should handle theme changes correctly', (WidgetTester tester) async {
      const themedMarkdown = '''
# Themed Content

This content should adapt to theme changes.
''';

      // When - Render with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: themedMarkdown,
            ),
          ),
        ),
      );

      // Then - Content should be rendered
      expect(find.text('Themed Content'), findsOneWidget);

      // When - Switch to dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: themedMarkdown,
            ),
          ),
        ),
      );

      // Then - Content should still be rendered
      expect(find.text('Themed Content'), findsOneWidget);
    });

    testWidgets('should handle content updates correctly', (WidgetTester tester) async {
      // Initial content
      const initialContent = '# Initial Content\n\nSome text here.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: initialContent,
            ),
          ),
        ),
      );

      // Initial content should be visible
      expect(find.text('Initial Content'), findsOneWidget);
      expect(find.text('Some text here.'), findsOneWidget);

      // Updated content
      const updatedContent = '# Updated Content\n\nNew text here.';

      // When - Update content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: updatedContent,
            ),
          ),
        ),
      );

      // Then - Updated content should be visible
      expect(find.text('Updated Content'), findsOneWidget);
      expect(find.text('New text here.'), findsOneWidget);

      // Old content should not be visible
      expect(find.text('Initial Content'), findsNothing);
      expect(find.text('Some text here.'), findsNothing);
    });
  });
}
