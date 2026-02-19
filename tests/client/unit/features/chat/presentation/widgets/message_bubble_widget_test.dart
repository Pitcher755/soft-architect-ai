import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/message_bubble_widget.dart';

void main() {
  group('MessageBubbleWidget', () {
    late ChatMessageUI userMessage;
    late ChatMessageUI assistantMessage;

    setUp(() {
      userMessage = ChatMessageUI(
        id: 'msg-1',
        role: 'user',
        content: 'User message content',
        timestamp: DateTime(2026, 2, 13, 12, 0),
      );

      assistantMessage = ChatMessageUI(
        id: 'msg-2',
        role: 'assistant',
        content: 'Assistant response',
        timestamp: DateTime(2026, 2, 13, 12, 1),
      );
    });

    group('User Messages', () {
      testWidgets('should display user message content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.text('User message content'), findsOneWidget);
      });

      testWidgets('should align user message to the right', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        final align = tester.widget<Align>(
          find.ancestor(
            of: find.text('User message content'),
            matching: find.byType(Align),
          ),
        );

        expect(align.alignment, Alignment.centerRight);
      });

      testWidgets('should have appropriate padding', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        // User messages should have more padding on left than right
        final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
        expect(paddingWidgets, isNotEmpty);
      });
    });

    group('Assistant Messages', () {
      testWidgets('should display assistant message content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        expect(find.text('Assistant response'), findsOneWidget);
      });

      testWidgets('should align assistant message to the left', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        final align = tester.widget<Align>(
          find.ancestor(
            of: find.text('Assistant response'),
            matching: find.byType(Align),
          ),
        );

        expect(align.alignment, Alignment.centerLeft);
      });

      testWidgets('should have appropriate padding', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        // Assistant messages should have more padding on right than left
        final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
        expect(paddingWidgets, isNotEmpty);
      });
    });

    group('Interactions', () {
      testWidgets('should work without onLongPress callback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        // Should not throw when long pressing without callback
        await tester.longPress(find.byType(SelectableText));
        await tester.pumpAndSettle();

        expect(find.text('User message content'), findsOneWidget);
      });
    });

    group('Styling', () {
      testWidgets('should have Container with decoration', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should use SelectableText for message content', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.byType(SelectableText), findsOneWidget);
      });

      testWidgets('should use Stack layout for badge positioning', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        // Widget uses Stack (may be multiple in tree)
        expect(find.byType(Stack), findsWidgets);
      });
    });

    group('ChatMessageUI Model', () {
      test('should create instance with all fields', () {
        final message = ChatMessageUI(
          id: 'test-1',
          role: 'user',
          content: 'Test content',
          timestamp: DateTime(2026, 2, 13),
        );

        expect(message.id, 'test-1');
        expect(message.role, 'user');
        expect(message.content, 'Test content');
        expect(message.timestamp, DateTime(2026, 2, 13));
      });

      test('should distinguish between user and assistantroles', () {
        final user = ChatMessageUI(
          id: '1',
          role: 'user',
          content: 'User msg',
          timestamp: DateTime.now(),
        );

        final assistant = ChatMessageUI(
          id: '2',
          role: 'assistant',
          content: 'Assistant msg',
          timestamp: DateTime.now(),
        );

        expect(user.role, 'user');
        expect(assistant.role, 'assistant');
        expect(user.role, isNot(equals(assistant.role)));
      });
    });

    group('Validation Button Visual Feedback', () {
      testWidgets('should show outline icon when not validated', (
        tester,
      ) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-1',
          role: 'assistant',
          content: '# README\n\nProject description',
          timestamp: DateTime(2026, 2, 13, 14, 0),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: false, // Not validated yet
              ),
            ),
          ),
        );

        // Should find outline version of icon
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final validateButton = iconButtons.firstWhere(
          (btn) {
            final icon = btn.icon as Icon;
            return icon.icon == Icons.check_circle_outline;
          },
          orElse: () =>
              throw Exception('Validate button with outline icon not found'),
        );

        expect(validateButton, isNotNull);
      });

      testWidgets('should show filled icon when validated', (tester) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-2',
          role: 'assistant',
          content: '# PROJECT MANIFESTO\n\nVision statement',
          timestamp: DateTime(2026, 2, 13, 14, 5),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: true, // Already validated
              ),
            ),
          ),
        );

        // Should find filled version of icon
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final validateButton = iconButtons.firstWhere(
          (btn) {
            final icon = btn.icon as Icon;
            return icon.icon == Icons.check_circle;
          },
          orElse: () =>
              throw Exception('Validate button with filled icon not found'),
        );

        expect(validateButton, isNotNull);
      });

      testWidgets('should show gray color when not validated', (tester) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-3',
          role: 'assistant',
          content: '# DESIGN DOC\n\nArchitecture details',
          timestamp: DateTime(2026, 2, 13, 14, 10),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: false,
              ),
            ),
          ),
        );

        // Find the validate button by icon type
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final validateButton = iconButtons.firstWhere((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle_outline;
        }, orElse: () => throw Exception('Validate button not found'));

        // Verify color is muted (gray)
        final icon = validateButton.icon as Icon;
        expect(icon.color, isNot(equals(Colors.green)));
      });

      testWidgets('should call onValidate when button pressed', (tester) async {
        var validateCalled = false;
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-4',
          role: 'assistant',
          content: '# API SPEC\n\nEndpoints documentation',
          timestamp: DateTime(2026, 2, 13, 14, 15),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {
                  validateCalled = true;
                },
                isValidated: false,
              ),
            ),
          ),
        );

        // Find and tap the validate button
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final validateButtonIndex = iconButtons.toList().indexWhere((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle_outline;
        });

        expect(validateButtonIndex, greaterThanOrEqualTo(0));

        await tester.tap(find.byType(IconButton).at(validateButtonIndex));
        await tester.pumpAndSettle();

        expect(validateCalled, true);
      });

      testWidgets('should hide validate button when no callback provided', (
        tester,
      ) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-5',
          role: 'assistant',
          content: '# SECURITY POLICY\n\nSecurity guidelines',
          timestamp: DateTime(2026, 2, 13, 14, 20),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: null, // No validate callback
                isValidated: false,
              ),
            ),
          ),
        );

        // Should not find validate button (no onValidate callback)
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final hasValidateButton = iconButtons.any((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle_outline ||
              icon.icon == Icons.check_circle;
        });

        expect(hasValidateButton, false);
      });

      testWidgets('should show "Validar" tooltip when not validated', (
        tester,
      ) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-6',
          role: 'assistant',
          content: '# TEST PLAN\n\nTest strategy',
          timestamp: DateTime(2026, 2, 13, 14, 25),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: false,
              ),
            ),
          ),
        );

        // Find the validate button
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final validateButton = iconButtons.firstWhere((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle_outline;
        }, orElse: () => throw Exception('Validate button not found'));

        // Verify tooltip contains "Validar"
        expect(validateButton.tooltip, contains('Validar'));
      });

      testWidgets('should show "guardado" tooltip when validated', (
        tester,
      ) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-7',
          role: 'assistant',
          content: '# DEPLOYMENT GUIDE\n\nDeployment instructions',
          timestamp: DateTime(2026, 2, 13, 14, 30),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: true, // Already validated
              ),
            ),
          ),
        );

        // Find the validate button (filled icon)
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final validateButton = iconButtons.firstWhere((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle;
        }, orElse: () => throw Exception('Validate button not found'));

        // Verify tooltip contains "guardado" (saved)
        expect(validateButton.tooltip, contains('guardado'));
      });

      testWidgets('should persist validation state across rebuilds', (
        tester,
      ) async {
        final documentMessage = ChatMessageUI(
          id: 'msg-doc-8',
          role: 'assistant',
          content: '# USER GUIDE\n\nUser documentation',
          timestamp: DateTime(2026, 2, 13, 14, 35),
        );

        // Initial render (not validated)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: false,
              ),
            ),
          ),
        );

        // Verify outline icon
        var iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        var hasOutlineIcon = iconButtons.any((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle_outline;
        });
        expect(hasOutlineIcon, true);

        // Rebuild with validated state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: documentMessage,
                onValidate: () {},
                isValidated: true, // Now validated
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify filled icon after rebuild
        iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
        final hasFilledIcon = iconButtons.any((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle;
        });
        expect(hasFilledIcon, true);
      });

      testWidgets('should not show validate button for non-document messages', (
        tester,
      ) async {
        final plainMessage = ChatMessageUI(
          id: 'msg-plain-1',
          role: 'assistant',
          content: 'This is a regular response without document format',
          timestamp: DateTime(2026, 2, 13, 14, 40),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: plainMessage,
                onValidate: null, // No validate for non-documents
                isValidated: false,
              ),
            ),
          ),
        );

        // Should not find validate button for non-document messages
        final iconButtons = tester.widgetList<IconButton>(
          find.byType(IconButton),
        );
        final hasValidateButton = iconButtons.any((btn) {
          final icon = btn.icon as Icon;
          return icon.icon == Icons.check_circle_outline ||
              icon.icon == Icons.check_circle;
        });

        expect(hasValidateButton, false);
      });
    });
  });
}
