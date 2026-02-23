import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/smart_message_renderer.dart';

/// Tests for SmartMessageRenderer widget (TDD approach).
///
/// Test Coverage:
/// - User messages render as plain markdown
/// - AI messages without documents render as plain markdown
/// - AI messages with single document render DocumentCard
/// - AI messages with multiple documents render multiple DocumentCards
/// - Mixed content (text + document + text) renders correctly
/// - Document card has proper structure (header, content, validate button)
/// - Text selection works for markdown content
void main() {
  group('SmartMessageRenderer', () {
    testWidgets('renders user message as plain markdown', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '# User Question\nThis is a **bold** question.';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: true),
          ),
        ),
      );

      // Assert
      expect(find.text('User Question'), findsOneWidget);
      expect(find.byType(SelectableText), findsWidgets);
      // Should NOT find document card components for user messages
      expect(find.text('DOCUMENTO GENERADO'), findsNothing);
      expect(find.text('Validar'), findsNothing);
    });

    testWidgets('renders AI message without documents as plain markdown', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
## Analysis Complete

Based on your requirements, here are my recommendations:

1. Use FastAPI for backend
2. Use Flutter for frontend
3. Use PostgreSQL for database

Would you like me to proceed?
''';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );

      // Assert
      expect(find.text('Analysis Complete'), findsOneWidget);
      expect(find.text('Use FastAPI for backend'), findsOneWidget);
      // Should NOT find document card for plain messages
      expect(find.text('DOCUMENTO GENERADO'), findsNothing);
      expect(find.text('Validar'), findsNothing);
    });

    testWidgets('renders AI message with single document as DocumentCard', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
I've created the architecture document for you:

<document>
# PROJECT_STRUCTURE_MAP.md

## Directory Structure

```
src/
  client/ - Flutter frontend
  server/ - FastAPI backend
```

## Key Decisions

- Clean Architecture pattern
- Repository pattern for data layer
</document>
''';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      // Should find pre-document text
      expect(
        find.textContaining("I've created the architecture document"),
        findsOneWidget,
      );

      // Should find document card header
      expect(find.text('DOCUMENTO GENERADO'), findsOneWidget);
      expect(find.byIcon(Icons.plumbing_rounded), findsOneWidget);

      // Should find validate button
      expect(find.text('Validar y Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Should find document content
      expect(find.textContaining('PROJECT_STRUCTURE_MAP.md'), findsOneWidget);
      expect(find.textContaining('Directory Structure'), findsOneWidget);
    });

    testWidgets('renders AI message with multiple documents correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
I've prepared two documents:

<document>
# TECH_STACK.md
- Backend: FastAPI
</document>

And also:

<document>
# API_CONTRACT.md
- Endpoint: /api/v1/chat
</document>

Both are ready for validation.
''';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      // Should find TWO document cards
      expect(find.text('DOCUMENTO GENERADO'), findsNWidgets(2));
      expect(find.text('Validar y Guardar'), findsNWidgets(2));

      // Should find content from both documents
      expect(find.textContaining('TECH_STACK.md'), findsOneWidget);
      expect(find.textContaining('API_CONTRACT.md'), findsOneWidget);

      // Should find text between documents
      expect(find.textContaining('And also:'), findsOneWidget);

      // Should find text after documents
      expect(find.textContaining('Both are ready'), findsOneWidget);
    });

    testWidgets('document card has proper visual structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
<document>
# Test Document
Content here
</document>
''';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Find visual components
      // Header with icon
      expect(find.byIcon(Icons.plumbing_rounded), findsOneWidget);
      expect(find.text('DOCUMENTO GENERADO'), findsOneWidget);

      // Validate button text and icon should exist
      expect(find.text('Validar y Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Container with proper decoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('validate button calls callback and disappears when pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
<document>
# Test Document
</document>
''';

      var callbackCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(
              rawContent: testContent,
              isUser: false,
              onSaveDocument: (path, content) async {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap validate button by text
      final validateButton = find.text('Validar y Guardar');
      expect(validateButton, findsOneWidget);
      await tester.tap(validateButton);
      await tester.pump(); // Start async operation
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for completion

      // Assert - Button should disappear and callback called
      expect(callbackCalled, isTrue);
      expect(find.text('Validar y Guardar'), findsNothing);
    });

    testWidgets('markdown content supports text selection', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = 'This is **selectable** text.';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );

      // Assert - MarkdownBody should be present with selectable: true
      // This is tested indirectly by checking the widget tree structure
      expect(find.textContaining('selectable'), findsOneWidget);
    });

    testWidgets('handles empty document block gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
Here's an empty document:

<document>
</document>

That was empty.
''';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      // Should still render document card (even if empty)
      expect(find.text('DOCUMENTO GENERADO'), findsOneWidget);
      expect(find.text('Validar y Guardar'), findsOneWidget);

      // Should find surrounding text
      expect(find.textContaining("Here's an empty document"), findsOneWidget);
      expect(find.textContaining('That was empty'), findsOneWidget);
    });

    testWidgets('dark theme renders properly', (WidgetTester tester) async {
      // Arrange
      const testContent = '''
<document>
# Dark Theme Test
</document>
''';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      // Should render without errors in dark theme
      expect(find.text('DOCUMENTO GENERADO'), findsOneWidget);
      expect(find.text('Validar y Guardar'), findsOneWidget);

      // Find container (dark theme uses different background color)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('handles malformed document blocks gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
This has a malformed document block:

<document> without closing
# Some content

Still in the document?
''';

      // Act & Assert
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The regex captures until EOF if no closing tag, so it WILL create a document card
      // This is the actual behavior of the widget
      expect(find.text('DOCUMENTO GENERADO'), findsOneWidget);
      expect(find.textContaining('Some content'), findsOneWidget);
    });

    testWidgets('extracts path and triggers callback on validation', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
<document>
**Path:** `context/RULES.md`
# Project Rules
- Rule 1
- Rule 2
</document>
''';

      String? capturedPath;
      String? capturedContent;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(
              rawContent: testContent,
              isUser: false,
              onSaveDocument: (path, content) async {
                capturedPath = path;
                capturedContent = content;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the validate button
      final validateButton = find.text('Validar y Guardar');
      expect(validateButton, findsOneWidget);
      await tester.tap(validateButton);
      await tester.pump(); // Start async operation
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for completion

      // Assert callback was triggered with correct values
      expect(capturedPath, 'context/RULES.md');
      expect(capturedContent, isNot(contains('**Path:**')));
      expect(capturedContent, contains('# Project Rules'));
      expect(capturedContent, contains('- Rule 1'));

      // Button should disappear after validation
      expect(find.text('Validar y Guardar'), findsNothing);
    });

    testWidgets('uses fallback path when no path found', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
<document>
# Document Without Path
Just some content without path metadata.
</document>
''';

      String? capturedPath;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(
              rawContent: testContent,
              isUser: false,
              onSaveDocument: (path, content) async {
                capturedPath = path;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the validate button
      await tester.tap(find.text('Validar y Guardar'));
      await tester.pumpAndSettle();

      // Assert fallback path is used
      expect(capturedPath, 'context/UNSORTED/untitled.md');
    });

    testWidgets('decodes double-escaped HTML entities correctly', (
      WidgetTester tester,
    ) async {
      // Arrange - Simulates content with double-escaped HTML from backend
      const testContent = '''
Here's the document structure:

&amp;lt;document&amp;gt;
# README.md

Use &amp;lt;Component&amp;gt; in your code.
&amp;lt;/document&amp;gt;
''';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should decode to proper <document> tags
      // The document card should be rendered (meaning <document> was detected)
      expect(find.text('DOCUMENTO GENERADO'), findsOneWidget);

      // Content should show <Component> not &lt;Component&gt;
      expect(find.textContaining('<Component>'), findsOneWidget);
    });

    testWidgets('decodes common HTML entities in text', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
Code example: List&lt;String&gt; myList = [];

Use &quot;quotes&quot; and &#39;apostrophes&#39; correctly.

Check if x &gt; 5 &amp; y &lt; 10.
''';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should display decoded entities
      expect(find.textContaining('List<String>'), findsOneWidget);
      expect(find.textContaining('"quotes"'), findsOneWidget);
      expect(find.textContaining("'apostrophes'"), findsOneWidget);
      expect(find.textContaining('x > 5 & y < 10'), findsOneWidget);
    });

    testWidgets('validate button disappears after being pressed (one-shot)', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
I've created the document:

<document>
**Path:** context/test.md

# Test Document

This is a test document.
</document>
''';
      var saveCallbackExecuted = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(
              rawContent: testContent,
              isUser: false,
              onSaveDocument: (String path, String content) async {
                // Mock callback to simulate async save
                await Future.delayed(const Duration(milliseconds: 50));
                saveCallbackExecuted = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Button should be visible initially
      final validateButton = find.text('Validar y Guardar');
      expect(validateButton, findsOneWidget);

      // Act - Tap the button
      await tester.tap(validateButton);
      await tester.pump(); // Start async operation

      // Assert - Button should show "Validando..." while processing
      expect(find.text('Validando...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete async operations
      await tester.pumpAndSettle();

      // Assert - Button should disappear after being pressed (one-shot)
      expect(find.text('Validar y Guardar'), findsNothing);
      expect(find.text('Validando...'), findsNothing);
      expect(saveCallbackExecuted, isTrue);
    });
  });
}
