import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/streaming_message_widget.dart';

void main() {
  group('StreamingMessageWidget', () {
    testWidgets('should display message text', (tester) async {
      const text = 'This is a streaming message';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreamingMessageWidget(text: text)),
        ),
      );

      expect(find.text(text), findsOneWidget);
    });

    testWidgets('should show loading indicator when streaming', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingMessageWidget(
              text: 'Streaming...',
              isStreaming: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should NOT show loading indicator when not streaming', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingMessageWidget(
              text: 'Complete message',
              isStreaming: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should default to isStreaming=false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreamingMessageWidget(text: 'Default state')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should use RepaintBoundary for performance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingMessageWidget(text: 'Performance test'),
          ),
        ),
      );

      // RepaintBoundary exists in widget (may be multiple in tree including framework ones)
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('should have proper padding and margin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreamingMessageWidget(text: 'Layout test')),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(RepaintBoundary),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, const EdgeInsets.all(12));
      expect(container.margin, const EdgeInsets.symmetric(vertical: 4));
    });

    testWidgets('should have rounded corners', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreamingMessageWidget(text: 'Styling test')),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(RepaintBoundary),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('should use blue background with alpha', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreamingMessageWidget(text: 'Color test')),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(RepaintBoundary),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final color = decoration.color!;

      // Check it's blue-based with low opacity
      expect((color.b * 255.0).round().clamp(0, 255), greaterThan(100));
      expect((color.a * 255.0).round().clamp(0, 255) / 255.0, lessThan(0.2));
    });

    testWidgets('should display both text and indicator when streaming', (
      tester,
    ) async {
      const text = 'Currently streaming content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingMessageWidget(text: text, isStreaming: true),
          ),
        ),
      );

      expect(find.text(text), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use Row layout for content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingMessageWidget(
              text: 'Layout test',
              isStreaming: true,
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(
        find.descendant(of: find.byType(Container), matching: find.byType(Row)),
      );

      expect(row.crossAxisAlignment, CrossAxisAlignment.start);
    });
  });
}
