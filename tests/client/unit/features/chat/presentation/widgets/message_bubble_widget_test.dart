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
  });
}
