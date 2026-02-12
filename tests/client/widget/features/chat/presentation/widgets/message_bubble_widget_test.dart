import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/message_bubble_widget.dart';

void main() {
  group('MessageBubbleWidget - PHASE 4: Chat Components', () {
    // Test 1: User message displays correctly
    testWidgets('MessageBubbleWidget displays user message correctly', (
      WidgetTester tester,
    ) async {
      final message = ChatMessageUI(
        id: '1',
        role: 'user',
        content: 'Hello, how can you help me?',
        timestamp: DateTime(2026, 2, 6, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubbleWidget(message: message)),
        ),
      );

      // Verify message content is displayed
      expect(find.text('Hello, how can you help me?'), findsOneWidget);
      // Verify timestamp is displayed (formatted as HH:MM)
      expect(find.text('10:30'), findsOneWidget);
    });

    // Test 2: Assistant message displays correctly
    testWidgets('MessageBubbleWidget displays assistant message correctly', (
      WidgetTester tester,
    ) async {
      final message = ChatMessageUI(
        id: '2',
        role: 'assistant',
        content: 'I can help you with software architecture!',
        timestamp: DateTime(2026, 2, 6, 10, 31),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubbleWidget(message: message)),
        ),
      );

      // Verify message content is displayed
      expect(
        find.text('I can help you with software architecture!'),
        findsOneWidget,
      );
      // Verify timestamp is displayed
      expect(find.text('10:31'), findsOneWidget);
    });

    // Test 3: Message timestamp is formatted correctly
    testWidgets('MessageBubbleWidget displays timestamp in HH:MM format', (
      tester,
    ) async {
      final message = ChatMessageUI(
        id: '3',
        role: 'user',
        content: 'Test message',
        timestamp: DateTime(2026, 2, 6, 15, 45),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubbleWidget(message: message)),
        ),
      );

      // Verify message content
      expect(find.text('Test message'), findsOneWidget);
      // Verify timestamp is formatted correctly
      expect(find.text('15:45'), findsOneWidget);
    });

    // Test 4: Multiple messages can be displayed
    testWidgets('MessageBubbleWidget renders in list context', (tester) async {
      final messages = [
        ChatMessageUI(
          id: '1',
          role: 'user',
          content: 'First message',
          timestamp: DateTime(2026, 2, 6, 10, 30),
        ),
        ChatMessageUI(
          id: '2',
          role: 'assistant',
          content: 'Response message',
          timestamp: DateTime(2026, 2, 6, 10, 31),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  MessageBubbleWidget(message: messages[index]),
            ),
          ),
        ),
      );

      // Verify both messages are rendered
      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Response message'), findsOneWidget);
    });

    // Test 5: Long messages are wrapped correctly
    testWidgets('MessageBubbleWidget wraps long content', (tester) async {
      final longContent =
          'This is a very long message that should wrap across multiple lines in the message bubble widget to ensure that the UI remains readable and doesn\'t break on long text content.';

      final message = ChatMessageUI(
        id: '4',
        role: 'user',
        content: longContent,
        timestamp: DateTime(2026, 2, 6, 11, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubbleWidget(message: message)),
        ),
      );

      // Verify long content is displayed (wrapped)
      expect(find.text(longContent), findsOneWidget);
    });

    // Test 6: Widget builds successfully with user and assistant roles
    testWidgets('MessageBubbleWidget supports user and assistant roles', (
      tester,
    ) async {
      final roles = ['user', 'assistant'];

      for (final role in roles) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: ChatMessageUI(
                  id: role,
                  role: role,
                  content: 'Test message for $role',
                  timestamp: DateTime.now(),
                ),
              ),
            ),
          ),
        );

        // Verify message renders
        expect(find.text('Test message for $role'), findsOneWidget);
      }
    });

    // Test 7: Message bubble widget structure
    testWidgets('MessageBubbleWidget renders container with proper styling', (
      tester,
    ) async {
      final message = ChatMessageUI(
        id: '7',
        role: 'user',
        content: 'Styled message',
        timestamp: DateTime(2026, 2, 6, 14, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubbleWidget(message: message)),
        ),
      );

      // Verify container exists
      expect(find.byType(Container), findsWidgets);
      // Verify message content is present
      expect(find.text('Styled message'), findsOneWidget);
    });

    // Test 8: Different timestamps render correctly
    testWidgets('MessageBubbleWidget handles various timestamp formats', (
      tester,
    ) async {
      final timestamps = [
        DateTime(2026, 2, 6, 0, 0), // 00:00
        DateTime(2026, 2, 6, 12, 30), // 12:30
        DateTime(2026, 2, 6, 23, 59), // 23:59
      ];

      const expectedTimes = ['00:00', '12:30', '23:59'];

      for (int i = 0; i < timestamps.length; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: ChatMessageUI(
                  id: '$i',
                  role: 'user',
                  content: 'Message $i',
                  timestamp: timestamps[i],
                ),
              ),
            ),
          ),
        );

        // Verify each timestamp formats correctly
        expect(find.text(expectedTimes[i]), findsOneWidget);
      }
    });
  });
}
