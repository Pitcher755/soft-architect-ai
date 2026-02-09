import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/streaming_indicator_widget.dart';

void main() {
  group('StreamingIndicatorWidget - PHASE 4: Chat Components', () {
    // Test 1: Progress animation displays correctly
    testWidgets('StreamingIndicatorWidget shows progress animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.5,
              documentIndex: 1,
              totalDocuments: 3,
            ),
          ),
        ),
      );

      // Verify document count is displayed
      expect(find.text('Document 1/3'), findsOneWidget);
      // Verify progress indicator is present
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    // Test 2: Progress percentage updates correctly
    testWidgets('StreamingIndicatorWidget updates progress percentage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.25,
              documentIndex: 0,
              totalDocuments: 4,
            ),
          ),
        ),
      );

      // Verify initial progress
      expect(find.text('Document 0/4'), findsOneWidget);
    });

    // Test 3: Document counter displays correctly
    testWidgets('StreamingIndicatorWidget displays document counter',
        (WidgetTester tester) async {
      final testCases = [
        (index: 0, total: 1),
        (index: 1, total: 5),
        (index: 4, total: 10),
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StreamingIndicatorWidget(
                progress: 0.5,
                documentIndex: testCase.index,
                totalDocuments: testCase.total,
              ),
            ),
          ),
        );

        // Verify document count format
        expect(
          find.text('Document ${testCase.index}/${testCase.total}'),
          findsOneWidget,
        );
      }
    });

    // Test 4: Progress indicator visual feedback
    testWidgets('StreamingIndicatorWidget provides progress visual feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.0,
              documentIndex: 0,
              totalDocuments: 5,
            ),
          ),
        ),
      );

      // Verify progress indicator is present
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    // Test 5: Streaming indicator handles edge cases
    testWidgets('StreamingIndicatorWidget handles edge progress values',
        (WidgetTester tester) async {
      final progressValues = [0.0, 0.1, 0.5, 0.99, 1.0];

      for (final progress in progressValues) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StreamingIndicatorWidget(
                progress: progress,
                documentIndex: 1,
                totalDocuments: 10,
              ),
            ),
          ),
        );

        // Verify widget renders without error
        expect(find.byType(StreamingIndicatorWidget), findsOneWidget);
      }
    });

    // Test 6: Multiple streaming indicators in list
    testWidgets(
        'StreamingIndicatorWidget can render multiple instances in list',
        (WidgetTester tester) async {
      const indicators = [
        (progress: 0.25, index: 0, total: 3),
        (progress: 0.5, index: 1, total: 3),
        (progress: 0.75, index: 2, total: 3),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: indicators.length,
              itemBuilder: (context, idx) => StreamingIndicatorWidget(
                progress: indicators[idx].progress,
                documentIndex: indicators[idx].index,
                totalDocuments: indicators[idx].total,
              ),
            ),
          ),
        ),
      );

      // Verify all indicators are rendered
      expect(find.byType(StreamingIndicatorWidget), findsWidgets);
      expect(find.text('Document 0/3'), findsOneWidget);
      expect(find.text('Document 1/3'), findsOneWidget);
      expect(find.text('Document 2/3'), findsOneWidget);
    });
  });
}
