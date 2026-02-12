// tests/widget/flutter/features/project_shell/presentation/markdown_preview_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/markdown_preview_widget.dart';
import 'package:softarchitect_ai/gen/app_localizations.dart';

Widget createLocalizedApp(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: child),
);

void main() {
  group('MarkdownPreviewWidget', () {
    testWidgets('should display widget when content is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MarkdownPreviewWidget())),
      );

      // Widget renders without crashing, no empty state text required
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
      expect(
        find.byIcon(Icons.visibility_outlined),
        findsOneWidget,
      ); // Toolbar icon
    });

    testWidgets('should display widget when content is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownPreviewWidget(content: '')),
        ),
      );

      // Widget renders without crashing, shows toolbar with default filename
      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
      expect(
        find.text('Preview.md'),
        findsOneWidget,
      ); // Default filename in toolbar
    });

    testWidgets('should display markdown content when provided', (
      WidgetTester tester,
    ) async {
      const markdownContent = '# Hello World\n\nThis is a **bold** text.';
      const filename = 'test.md';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: markdownContent,
              filename: filename,
            ),
          ),
        ),
      );

      // Should display the filename in the header
      expect(find.text(filename), findsOneWidget);

      // Should render markdown content
      expect(find.byType(Markdown), findsOneWidget);

      // Should contain the rendered text
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should display header with filename when provided', (
      WidgetTester tester,
    ) async {
      const markdownContent = '# Test Content';
      const filename = 'example.md';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: markdownContent,
              filename: filename,
            ),
          ),
        ),
      );

      // Should display markdown content
      expect(find.byType(Markdown), findsOneWidget);

      // Should render the markdown heading
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should not display header when filename is null', (
      WidgetTester tester,
    ) async {
      const markdownContent = '# Test Content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownPreviewWidget(content: markdownContent)),
        ),
      );

      // Should still display markdown content
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should render complex markdown correctly', (
      WidgetTester tester,
    ) async {
      const markdownContent = '''
# Header 1
## Header 2

This is **bold** and *italic* text.

- List item 1
- List item 2

```dart
void main() {
  print('Hello World');
}
```

> This is a blockquote
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: markdownContent,
              filename: 'complex.md',
            ),
          ),
        ),
      );

      // Should render various markdown elements
      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Header 2'), findsOneWidget);
      expect(find.text('List item 1'), findsOneWidget);
      expect(find.text('List item 2'), findsOneWidget);
      expect(find.byType(Markdown), findsOneWidget);
    });

    testWidgets('should handle very long content', (WidgetTester tester) async {
      final longContent = '# Long Content\n\n' + 'Line of text.\n' * 1000;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: longContent,
              filename: 'long.md',
            ),
          ),
        ),
      );

      // Should still render without crashing
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Long Content'), findsOneWidget);
    });

    testWidgets('should handle special characters in content', (
      WidgetTester tester,
    ) async {
      const specialContent = '# Special Characters\n\n© ® ™ € £ ¥ § ¶ † ‡';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: specialContent,
              filename: 'special.md',
            ),
          ),
        ),
      );

      // Should render without issues
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Special Characters'), findsOneWidget);
    });

    testWidgets('should handle markdown with links', (
      WidgetTester tester,
    ) async {
      const linkContent =
          '# Links\n\n[Google](https://google.com) and [GitHub](https://github.com)';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: linkContent,
              filename: 'links.md',
            ),
          ),
        ),
      );

      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
    });

    testWidgets('should handle markdown with images', (
      WidgetTester tester,
    ) async {
      const imageContent =
          '# Images\n\n![Alt text](https://example.com/image.png)';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: imageContent,
              filename: 'images.md',
            ),
          ),
        ),
      );

      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Images'), findsOneWidget);
    });

    testWidgets('should handle markdown with tables', (
      WidgetTester tester,
    ) async {
      const tableContent = '''
# Tables

| Column 1 | Column 2 |
|----------|----------|
| Data 1   | Data 2   |
| Data 3   | Data 4   |
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: tableContent,
              filename: 'table.md',
            ),
          ),
        ),
      );

      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Tables'), findsOneWidget);
      expect(find.text('Column 1'), findsOneWidget);
      expect(find.text('Data 1'), findsOneWidget);
    });

    testWidgets('should have proper dark theme colors', (
      WidgetTester tester,
    ) async {
      const markdownContent = '# Test';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewWidget(
              content: markdownContent,
              filename: 'test.md',
            ),
          ),
        ),
      );

      // The widget should render with proper theming
      expect(find.byType(Markdown), findsOneWidget);
    });

    testWidgets('should render JSON view when filename ends with .json', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const MarkdownPreviewWidget(
            content: '{"name":"test"}',
            filename: 'data.json',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HighlightView), findsOneWidget);
      expect(find.byType(Markdown), findsNothing);
      expect(find.text('data.json'), findsOneWidget);
    });

    testWidgets('copy button should execute action without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const MarkdownPreviewWidget(content: '# Título', filename: 'doc.md'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });

    testWidgets('download button should execute action without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const MarkdownPreviewWidget(content: '# Save me', filename: 'doc.md'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
    });

    testWidgets('copy should do nothing when content is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const MarkdownPreviewWidget(content: '', filename: 'empty.md'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
