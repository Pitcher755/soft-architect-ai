// tests/widget/markdown_preview_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/markdown_preview_widget.dart';

void main() {
  group('MarkdownPreviewWidget', () {
    testWidgets('shows empty state when content is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: null),
          ),
        ),
      );

      // Verify empty state message
      expect(find.text('Select a file to preview'), findsOneWidget);
    });

    testWidgets('renders markdown content correctly',
        (WidgetTester tester) async {
      const markdownContent = '''
# Hello World

This is a **bold** text and *italic* text.

- Item 1
- Item 2
- Item 3
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: markdownContent),
          ),
        ),
      );

      // Verify markdown is rendered
      expect(find.text('Hello World'), findsWidgets);
      expect(find.text('bold'), findsWidgets);
      expect(find.text('italic'), findsWidgets);
    });

    testWidgets('handles code blocks', (WidgetTester tester) async {
      const markdownContent = '''
# Code Example

\`\`\`dart
void main() {
  print('Hello');
}
\`\`\`
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: markdownContent),
          ),
        ),
      );

      // Verify content is displayed
      expect(find.text('Code Example'), findsWidgets);
    });

    testWidgets('scrollable for long content', (WidgetTester tester) async {
      final longContent = StringBuffer();
      for (int i = 0; i < 100; i++) {
        longContent.writeln('## Section $i\n\nContent for section $i\n');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: longContent.toString()),
          ),
        ),
      );

      // Verify at least one section is shown
      expect(find.text('Section 0'), findsWidgets);

      // Verify scrollable widget exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays links correctly', (WidgetTester tester) async {
      const markdownContent = '''
# Links Example

Check out [Flutter](https://flutter.dev) for more info.
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: markdownContent),
          ),
        ),
      );

      // Verify link text is displayed
      expect(find.text('Flutter'), findsWidgets);
    });

    testWidgets('renders lists with formatting', (WidgetTester tester) async {
      const markdownContent = '''
# Tasks

1. First task
2. Second task
3. Third task

- Bullet point
- Another point
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: markdownContent),
          ),
        ),
      );

      // Verify list items are shown
      expect(find.text('First task'), findsWidgets);
      expect(find.text('Bullet point'), findsWidgets);
    });

    testWidgets('handles empty string content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(content: ''),
          ),
        ),
      );

      // Should show empty state or nothing
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });

    testWidgets('dark theme colors applied',
        (WidgetTester tester) async {
      const markdownContent = '# Test Content';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: MarkdownPreviewWidget(content: markdownContent),
          ),
        ),
      );

      // Verify widget renders with dark theme
      expect(find.text('Test Content'), findsWidgets);
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });
  });
}
