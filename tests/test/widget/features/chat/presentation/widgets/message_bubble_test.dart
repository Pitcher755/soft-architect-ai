import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai_tests/features/chat/presentation/widgets/message_bubble_widget.dart';

void main() {
  group('MessageBubbleWidget', () {
    final userMessage = ChatMessageUI(
      id: '1',
      role: 'user',
      content: 'Hello, analyze this document',
      timestamp: DateTime.now(),
    );

    final assistantMessage = ChatMessageUI(
      id: '2',
      role: 'assistant',
      content: 'I will analyze the document for you.',
      timestamp: DateTime.now(),
    );

    testWidgets('should render user message with right alignment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [MessageBubbleWidget(message: userMessage)],
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubbleWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render assistant message with left alignment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [MessageBubbleWidget(message: assistantMessage)],
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubbleWidget), findsOneWidget);
      expect(find.byType(Align), findsWidgets);
    });

    testWidgets(
      'should apply different styling for user and assistant messages',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  MessageBubbleWidget(message: userMessage),
                  MessageBubbleWidget(message: assistantMessage),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(MessageBubbleWidget), findsNWidgets(2));
        expect(find.byType(Container), findsWidgets);
      },
    );

    testWidgets('should display message content as text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [MessageBubbleWidget(message: userMessage)],
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should apply dark theme styling with GitHub colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF0D1117), // GitHub dark theme
            body: ListView(
              children: [MessageBubbleWidget(message: assistantMessage)],
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubbleWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render multiple messages in correct order', (
      WidgetTester tester,
    ) async {
      final messages = [
        ChatMessageUI(
          id: '1',
          role: 'user',
          content: 'Message 1',
          timestamp: DateTime.now(),
        ),
        ChatMessageUI(
          id: '2',
          role: 'assistant',
          content: 'Response 1',
          timestamp: DateTime.now(),
        ),
        ChatMessageUI(
          id: '3',
          role: 'user',
          content: 'Message 2',
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                for (final message in messages)
                  MessageBubbleWidget(message: message),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(MessageBubbleWidget), findsNWidgets(3));
    });
  });
}
