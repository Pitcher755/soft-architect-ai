import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/error_banner_widget.dart';

void main() {
  group('ErrorBannerWidget', () {
    testWidgets('should display error message text', (tester) async {
      const message = 'Connection failed. Please try again.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(message: 'Error occurred'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display close icon button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(message: 'Test error'),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onDismiss when dismiss button is pressed',
        (tester) async {
      var dismissCalled = false;
      void onDismiss() {
        dismissCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              message: 'Test error',
              onDismiss: onDismiss,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(dismissCalled, true);
    });

    testWidgets('should truncate long error messages with ellipsis',
        (tester) async {
      const longMessage =
          'This is a very long error message that should be truncated with ellipsis because it exceeds the maximum number of lines allowed in the error banner widget for displaying error messages to the user.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ErrorBannerWidget(message: longMessage),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(longMessage));
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should use red color scheme for error styling',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(message: 'Error'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Error'),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red[900]);
    });

    testWidgets('should render with white text color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(message: 'Error'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Error'));
      expect(textWidget.style?.color, Colors.white);
    });

    testWidgets('should work without onDismiss callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(message: 'Error'),
          ),
        ),
      );

      // Should not throw when tapping dismiss without callback
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Widget should still exist
      expect(find.text('Error'), findsOneWidget);
    });
  });
}
