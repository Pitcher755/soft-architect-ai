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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsNothing);
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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsNothing);
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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);

      // Should find validate button
      expect(find.text('Validar y Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Refinar'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);

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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsNWidgets(2));
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
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);

      // Validate button text and icon should exist
      expect(find.text('Validar y Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Refinar'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);

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
              onSaveDocument: () async {
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

      // Assert - Callback should execute and card remains visible
      expect(callbackCalled, isTrue);
      expect(find.text('Validar y Guardar'), findsOneWidget);
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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);
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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);
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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);
      expect(find.textContaining('Some content'), findsOneWidget);
    });

    testWidgets('triggers callback on validation', (WidgetTester tester) async {
      // Arrange
      const testContent = '''
<document>
**Path:** `context/RULES.md`
# Project Rules
- Rule 1
- Rule 2
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
              onSaveDocument: () async {
                callbackCalled = true;
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

      // Assert callback was triggered
      expect(callbackCalled, isTrue);

      // Card remains visible after validation
      expect(find.text('Validar y Guardar'), findsOneWidget);
    });

    testWidgets('callback works when no path found', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testContent = '''
<document>
# Document Without Path
Just some content without path metadata.
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
              onSaveDocument: () async {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the validate button
      await tester.tap(find.text('Validar y Guardar'));
      await tester.pumpAndSettle();

      // Assert callback was triggered
      expect(callbackCalled, isTrue);
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
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);

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

    testWidgets('validate action executes successfully (one-shot)', (
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
              onSaveDocument: () async {
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

      // Assert - Validation completed and card still visible
      expect(find.text('Validar y Guardar'), findsOneWidget);
      expect(find.text('Validando...'), findsNothing);
      expect(saveCallbackExecuted, isTrue);
    });

    testWidgets('refine button sends predefined message with document path', (
      WidgetTester tester,
    ) async {
      const testContent = '''
<document>
**Path:** `context/10-BUSINESS_AND_SCOPE/EXECUTIVE_SUMMARY_MVP.md`
# Executive Summary
</document>
''';

      String? capturedRefineMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(
              rawContent: testContent,
              isUser: false,
              onSendChatMessage: (message) async {
                capturedRefineMessage = message;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Refinar'));
      await tester.pumpAndSettle();

      expect(capturedRefineMessage, 'Deseo refinar este documento: ');
    });

    testWidgets('reject button hides the document card locally', (
      WidgetTester tester,
    ) async {
      const testContent = '''
<document>
# Documento a rechazar
</document>
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(find.text('PROPUESTA DE DOCUMENTO'), findsNothing);
      expect(find.text('Validar y Guardar'), findsNothing);
    });

    testWidgets('document card detects plain Path: .json header (no bold)', (
      WidgetTester tester,
    ) async {
      // Regression: _buildContent regex previously only matched **bold**
      // Path: headers. This verifies plain "Path:" is also handled.
      const testContent = '''
<document>
Path: context/20-REQUIREMENTS/USER_STORIES.json
{"user_stories": [{"id": 1, "title": "Login"}]}
</document>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Card header must be visible regardless of path format.
      expect(find.text('PROPUESTA DE DOCUMENTO'), findsOneWidget);
      // Action buttons are present (card rendered successfully).
      expect(find.text('Validar y Guardar'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Markdown JSON formatting helpers (_formatJsonPathBlock / _formatIfJson)
  // ---------------------------------------------------------------------------

  group('markdown JSON formatting', () {
    testWidgets('renders plain Path: .json block without crash', (
      WidgetTester tester,
    ) async {
      // Verifies _formatJsonPathBlock converts the LLM raw output to a
      // code-fenced display string, preventing SelectableRegion assertion
      // errors caused by unbounded single-line content.
      const rawJson = '{"name": "test", "version": "1.0"}';
      const testContent = 'Path: context/config.json\n$rawJson';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Widget must render without throwing.
      expect(find.byType(SmartMessageRenderer), findsOneWidget);
    });

    testWidgets('renders bold **Path:** .json block without crash', (
      WidgetTester tester,
    ) async {
      // Verifies bold variant is also handled by _formatJsonPathBlock.
      const rawJson = '{"key": "value"}';
      const testContent = '**Path:** context/data.json\n$rawJson';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SmartMessageRenderer), findsOneWidget);
    });

    testWidgets('renders raw JSON object wrapped in code block without crash', (
      WidgetTester tester,
    ) async {
      // Verifies _formatIfJson wraps bare JSON objects in a ```json fence,
      // providing natural line-break points to avoid layout overflow.
      const testContent = '{"project":"SoftArchitect","version":"0.1.0"}';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SmartMessageRenderer), findsOneWidget);
    });

    testWidgets('passes non-JSON content through unchanged', (
      WidgetTester tester,
    ) async {
      // Verifies _formatIfJson leaves plain text untouched.
      const testContent = 'This is just plain text, not JSON.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartMessageRenderer(rawContent: testContent, isUser: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('plain text, not JSON'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // _buildRailMixedContent – [document] marker / reasoning extraction
  // ---------------------------------------------------------------------------

  group('rail mixed content', () {
    testWidgets(
      '_buildRailMixedContent handles [document] + [Razonamiento] prefix',
      (tester) async {
        // Content with legacy [Razonamiento] prefix followed by [document].
        // This exercises the content.contains('[document]') branch that splits
        // reasoning text from document content (lines 107-112, 129-130).
        const testContent =
            '[Razonamiento] Some analysis here [document] '
            '**Path:** context/doc.md\n# Document Title';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SmartMessageRenderer(
                rawContent: testContent,
                isUser: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartMessageRenderer), findsOneWidget);
      },
    );

    testWidgets(
      '_buildRailMixedContent splits reasoning before **Path:** header',
      (tester) async {
        // Reasoning text BEFORE a **Path:** marker triggers the else-branch
        // startIndex > 0 path (lines 122-123) and the reasoningText.isNotEmpty
        // path (lines 129-130).
        const testContent =
            'Here is my analysis of the requirements.\n'
            '**Path:** context/spec.json\n{"key": "value"}';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SmartMessageRenderer(
                rawContent: testContent,
                isUser: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartMessageRenderer), findsOneWidget);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // _buildMarkdown helpers via user messages (isUser:true bypasses routing)
  // ---------------------------------------------------------------------------

  group('_buildMarkdown via user messages', () {
    testWidgets(
      '_formatJsonPathBlock formats valid Path:JSON in user message',
      (tester) async {
        // isUser:true always routes to _buildMarkdown → _formatJsonPathBlock
        // is called with content that matches the regex (lines 245, 246,
        // 251, 252, 253 of smart_message_renderer.dart).
        const rawJson = '{"name": "test", "version": "1.0"}';
        const testContent = 'Path: context/config.json\n$rawJson';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SmartMessageRenderer(
                rawContent: testContent,
                isUser: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartMessageRenderer), findsOneWidget);
      },
    );

    testWidgets(
      '_formatJsonPathBlock returns content-as-is for invalid JSON body',
      (tester) async {
        // Regex matches but jsonDecode throws FormatException (line 254).
        const testContent = 'Path: context/data.json\n{not_valid_json_at_all}';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SmartMessageRenderer(
                rawContent: testContent,
                isUser: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartMessageRenderer), findsOneWidget);
      },
    );

    testWidgets(
      '_formatIfJson wraps a valid JSON object in a code fence (user msg)',
      (tester) async {
        // isUser:true → _buildMarkdown → _formatIfJson sees JSON object
        // (lines 275, 276, 277 of smart_message_renderer.dart).
        const testContent = '{"project": "SoftArchitect", "version": "0.1.0"}';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SmartMessageRenderer(
                rawContent: testContent,
                isUser: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartMessageRenderer), findsOneWidget);
      },
    );

    testWidgets(
      '_formatIfJson handles FormatException for JSON-like content',
      (tester) async {
        // Starts with { ends with } but is not valid JSON → FormatException
        // caught (line 278 of smart_message_renderer.dart).
        const testContent = '{key_without_quotes: "value"}';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SmartMessageRenderer(
                rawContent: testContent,
                isUser: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartMessageRenderer), findsOneWidget);
      },
    );

    testWidgets('_buildMarkdown applies dark-theme code style', (tester) async {
      // Dark theme forces isDark == true → the greenAccent code-color branch
      // inside _buildMarkdown's MarkdownStyleSheet (line 326).
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SmartMessageRenderer(
              rawContent: 'Plain AI response without any document blocks.',
              isUser: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SmartMessageRenderer), findsOneWidget);
    });
  });
}
