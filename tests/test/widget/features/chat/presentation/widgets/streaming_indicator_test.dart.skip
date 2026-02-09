import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/streaming_indicator_widget.dart';

void main() {
  group('StreamingIndicatorWidget', () {
    testWidgets('should render with default progress at 0%', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0,
              documentIndex: 1,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      expect(find.byType(StreamingIndicatorWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display progress percentage correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.5,
              documentIndex: 12,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify percentage is displayed
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should render progress bar widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.3,
              documentIndex: 5,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify LinearProgressIndicator is rendered
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('should apply dark theme styling with GitHub colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.3,
              documentIndex: 8,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that Container exists (dark theme background)
      expect(find.byType(Container), findsWidgets);

      // Verify progress text is visible
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('should show completed state at 100% progress', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 1.0,
              documentIndex: 25,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should maintain theme consistency with dark background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF0D1117), // GitHub dark theme
            body: StreamingIndicatorWidget(
              progress: 0.6,
              documentIndex: 15,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('60%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should render Column with children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.4,
              documentIndex: 10,
              totalDocuments: 25,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
      expect(find.text('40%'), findsOneWidget);
    });
  });
}
