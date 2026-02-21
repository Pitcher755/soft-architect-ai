import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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

  // ========================================================================
  // PHASE 11: Enhanced UI Features
  // - Markdown rendering in assistant messages
  // - Improved avatars (Icons.person, Icons.smart_toy)
  // - Action buttons (copy, validate/save)
  // - Edit button for user messages
  // - Blinking cursor for streaming messages
  // ========================================================================
  group('MessageBubbleWidget - Phase 11 Features', () {
    late ChatMessageUI userMessage;
    late ChatMessageUI assistantMessage;
    late ChatMessageUI streamingMessage;
    late ChatMessageUI markdownMessage;
    late TextEditingController messageController;

    setUp(() {
      messageController = TextEditingController();

      userMessage = ChatMessageUI(
        id: 'user-1',
        role: 'user',
        content: 'User message content',
        timestamp: DateTime(2026, 2, 17, 12, 0),
      );

      assistantMessage = ChatMessageUI(
        id: 'assistant-1',
        role: 'assistant',
        content: 'Assistant response',
        timestamp: DateTime(2026, 2, 17, 12, 1),
      );

      streamingMessage = ChatMessageUI(
        id: 'streaming-1',
        role: 'assistant',
        content: 'Streaming response...',
        timestamp: DateTime(2026, 2, 17, 12, 2),
        isStreaming: true,
      );

      markdownMessage = ChatMessageUI(
        id: 'markdown-1',
        role: 'assistant',
        content: '''
# Heading
This is **bold** and *italic* text.
```dart
void main() {
  print('Hello');
}
```
''',
        timestamp: DateTime(2026, 2, 17, 12, 3),
      );
    });

    tearDown(() {
      messageController.dispose();
    });

    group('Markdown Rendering', () {
      testWidgets('should render assistant messages with MarkdownBody', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        expect(find.byType(MarkdownBody), findsOneWidget);
        expect(find.text('Assistant response'), findsOneWidget);
      });

      testWidgets('should render user messages with SelectableText', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.byType(SelectableText), findsOneWidget);
        expect(find.byType(MarkdownBody), findsNothing);
      });

      testWidgets('should render markdown formatted content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: markdownMessage)),
          ),
        );

        expect(find.byType(MarkdownBody), findsOneWidget);
        final markdownWidget = tester.widget<MarkdownBody>(
          find.byType(MarkdownBody),
        );
        expect(markdownWidget.data, contains('# Heading'));
        expect(markdownWidget.data, contains('**bold**'));
      });

      testWidgets('should make markdown content selectable', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        final markdownWidget = tester.widget<MarkdownBody>(
          find.byType(MarkdownBody),
        );
        expect(markdownWidget.selectable, isTrue);
      });
    });

    group('Improved Avatars', () {
      testWidgets('should display person icon for user messages', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('should display smart_toy icon for assistant messages', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
      });

      testWidgets('should display both avatar types correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  MessageBubbleWidget(message: userMessage),
                  MessageBubbleWidget(message: assistantMessage),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CircleAvatar), findsNWidgets(2));
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
      });
    });

    group('Action Buttons - Copy', () {
      testWidgets('should display copy button for assistant messages', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsOneWidget);
        expect(find.byType(IconButton), findsWidgets);
      });

      testWidgets('should NOT display copy button for user messages', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.byIcon(Icons.copy), findsNothing);
      });

      testWidgets('should NOT display copy button while streaming', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: streamingMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsNothing);
      });

      testWidgets('should be tappable', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        final copyButton = find.byIcon(Icons.copy);
        await tester.tap(copyButton);
        await tester.pumpAndSettle();

        expect(copyButton, findsOneWidget);
      });

      testWidgets('should show tooltip on hover', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        final copyButton = find.byIcon(Icons.copy);
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await tester.pump();
        await gesture.moveTo(tester.getCenter(copyButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Copiar al portapapeles'), findsOneWidget);
      });
    });

    group('Edit Button', () {
      testWidgets('should display edit button when controller provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: userMessage,
                messageController: messageController,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.edit), findsOneWidget);
      });

      testWidgets('should NOT display without controller', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.byIcon(Icons.edit), findsNothing);
      });

      testWidgets('should NOT display for assistant messages', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: assistantMessage,
                messageController: messageController,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.edit), findsNothing);
      });

      testWidgets('should load content to controller when tapped', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: userMessage,
                messageController: messageController,
              ),
            ),
          ),
        );

        expect(messageController.text, isEmpty);

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        expect(messageController.text, userMessage.content);
      });

      testWidgets('should show tooltip on hover', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: userMessage,
                messageController: messageController,
              ),
            ),
          ),
        );

        final editButton = find.byIcon(Icons.edit);
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await tester.pump();
        await gesture.moveTo(tester.getCenter(editButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Edit message'), findsOneWidget);
      });
    });

    group('Streaming Messages', () {
      testWidgets('should NOT display action buttons while streaming', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: streamingMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsNothing);
        expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      });

      testWidgets('should display buttons after streaming completes', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: streamingMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsNothing);

        final completedMessage = ChatMessageUI(
          id: streamingMessage.id,
          role: streamingMessage.role,
          content: streamingMessage.content,
          timestamp: streamingMessage.timestamp,
          isStreaming: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: completedMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsOneWidget);
        // Note: MessageBubbleWidget does NOT have validate button
        // Validation happens in SmartMessageRenderer
      });

      testWidgets('should render with markdown', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: streamingMessage),
            ),
          ),
        );

        expect(find.byType(MarkdownBody), findsOneWidget);
        expect(find.text('Streaming response...'), findsOneWidget);
      });
    });

    group('isStreaming Flag', () {
      testWidgets('should show buttons when false', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsOneWidget);
        // Note: MessageBubbleWidget does NOT have validate button
      });

      testWidgets('should hide buttons when true', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: streamingMessage),
            ),
          ),
        );

        expect(find.byIcon(Icons.copy), findsNothing);
        expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      });

      testWidgets('should default to false', (tester) async {
        final defaultMessage = ChatMessageUI(
          id: 'default',
          role: 'assistant',
          content: 'Default message',
          timestamp: DateTime.now(),
        );

        expect(defaultMessage.isStreaming, isFalse);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: defaultMessage)),
          ),
        );

        expect(find.byIcon(Icons.copy), findsOneWidget);
      });
    });

    group('userName Parameter', () {
      testWidgets('should accept userName parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: userMessage,
                userName: 'John Doe',
              ),
            ),
          ),
        );

        expect(find.text('User message content'), findsOneWidget);
      });

      testWidgets('should work without userName', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: userMessage)),
          ),
        );

        expect(find.text('User message content'), findsOneWidget);
      });
    });

    group('Integration - All Features', () {
      testWidgets('should render complete assistant message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: assistantMessage),
            ),
          ),
        );

        expect(find.byType(MarkdownBody), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
        expect(find.byIcon(Icons.copy), findsOneWidget);
        // Note: Validate button is NOT in MessageBubbleWidget
        expect(find.text('12:01'), findsOneWidget);
      });

      testWidgets('should render complete user message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(
                message: userMessage,
                messageController: messageController,
                userName: 'Test User',
              ),
            ),
          ),
        );

        expect(find.byType(SelectableText), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.text('12:00'), findsOneWidget);
        expect(find.byIcon(Icons.copy), findsNothing);
      });

      testWidgets('should render streaming message correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageBubbleWidget(message: streamingMessage),
            ),
          ),
        );

        expect(find.byType(MarkdownBody), findsOneWidget);
        expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
        expect(find.byIcon(Icons.copy), findsNothing);
        // Note: Validate button and copy button hidden during streaming
        expect(find.text('Streaming response...'), findsOneWidget);
      });
    });

    group('One-Shot Validation Button & System Messages', () {
      testWidgets('should display system message with special styling', (
        tester,
      ) async {
        final systemMessage = ChatMessageUI(
          id: 'sys-1',
          role: 'system',
          content: '✅ Documento validado y guardado en `README.md`',
          timestamp: DateTime(2026, 2, 6, 12, 0),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MessageBubbleWidget(message: systemMessage)),
          ),
        );

        // Verify system message content is displayed
        expect(
          find.text('✅ Documento validado y guardado en `README.md`'),
          findsOneWidget,
        );

        // Verify check icon is present
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Verify message is centered (system messages should be centered)
        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('✅ Documento validado y guardado en `README.md`'),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(container.decoration, isNotNull);
      });

      testWidgets('should display user and assistant messages differently', (
        tester,
      ) async {
        final userMessage = ChatMessageUI(
          id: '1',
          role: 'user',
          content: 'User message',
          timestamp: DateTime(2026, 2, 6, 12, 0),
        );

        final assistantMessage = ChatMessageUI(
          id: '2',
          role: 'assistant',
          content: 'Assistant message',
          timestamp: DateTime(2026, 2, 6, 12, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  MessageBubbleWidget(message: userMessage),
                  MessageBubbleWidget(message: assistantMessage),
                ],
              ),
            ),
          ),
        );

        // Both messages should be present
        expect(find.text('User message'), findsOneWidget);
        expect(find.text('Assistant message'), findsOneWidget);

        // User message should have person icon
        expect(find.byIcon(Icons.person), findsOneWidget);

        // Assistant message should have smart_toy icon
        expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
      });

      testWidgets(
        'should show only copy button for completed assistant messages',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MessageBubbleWidget(
                  message: ChatMessageUI(
                    id: '1',
                    role: 'assistant',
                    content: 'Completed response',
                    timestamp: DateTime(2026, 2, 6, 12, 0),
                    isStreaming: false,
                  ),
                ),
              ),
            ),
          );

          // Copy button should be present
          expect(find.byIcon(Icons.copy), findsOneWidget);
        },
      );
    });
  });
}
