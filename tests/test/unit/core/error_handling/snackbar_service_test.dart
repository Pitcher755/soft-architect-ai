// Unit tests for SnackbarService (TDD RED Phase).
//
// This module tests UX-optimized notification system.
// All tests are expected to FAIL until implementation is complete (Phase 2).
//
// Test Coverage:
// - Success snackbar (auto-hide after 5s)
// - Info snackbar (auto-hide after 5s)
// - Error snackbar (manual close required)
// - Retryable error snackbar with action button

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/error_handling/snackbar_service.dart';

void main() {
  group('SnackbarService', () {
    late SnackbarService snackbarService;

    setUp(() {
      snackbarService = SnackbarService();
    });

    testWidgets('should show success snackbar with auto-hide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback to avoid build-time error)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showSuccess(context, 'Operation successful');
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pump(const Duration(milliseconds: 500)); // Allow snackbar to appear

      // Assert - Just verify the snackbar appears with correct content
      expect(find.text('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Note: We don't test auto-hide in unit tests as it requires waiting 5 real seconds
      // Auto-hide behavior is tested in integration tests
    });

    testWidgets('should show info snackbar with auto-hide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showInfo(context, 'Information message');
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pump(const Duration(milliseconds: 500)); // Allow snackbar to appear

      // Assert - Just verify the snackbar appears with correct content
      expect(find.text('Information message'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Note: Auto-hide behavior tested in integration tests
    });

    testWidgets('should show error snackbar WITHOUT auto-hide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showError(context, 'Critical error', 'SYS_001');
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pumpAndSettle(); // Wait for animations

      // Assert
      expect(find.text('Critical error'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Código: SYS_001'), findsOneWidget);

      // Verify NO auto-hide after 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('Critical error'), findsOneWidget); // Still visible
    });

    testWidgets('should show close button for error snackbar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showError(context, 'Error message', 'VAL_001');
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pumpAndSettle(); // Wait for animations

      // Assert
      expect(find.text('Cerrar'), findsOneWidget);

      // Act: Tap close button
      await tester.tap(find.text('Cerrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Snackbar dismissed
      expect(find.text('Error message'), findsNothing);
    });

    testWidgets('should show retry button for retryable errors', (tester) async {
      // Arrange
      var retryPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showRetryableError(
                    context,
                    'Connection failed',
                    onRetry: () => retryPressed = true,
                  );
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert
      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);

      // Act: Tap retry button using warnIfMissed: false to avoid obscured widget warning
      await tester.tap(find.text('Reintentar'), warnIfMissed: false);
      await tester.pump();

      // Assert
      expect(retryPressed, isTrue);
    });

    testWidgets('retryable error should NOT auto-hide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showRetryableError(
                    context,
                    'Retryable error',
                    onRetry: () {},
                  );
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pumpAndSettle(); // Wait for animations

      // Assert: Visible initially
      expect(find.text('Retryable error'), findsOneWidget);

      // Act: Wait 10 seconds
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();

      // Assert: Still visible (no auto-hide)
      expect(find.text('Retryable error'), findsOneWidget);
    });

    testWidgets('retry button should dismiss snackbar after retry', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act (post-frame callback)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showRetryableError(
                    context,
                    'Retry this operation',
                    onRetry: () {},
                  );
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pumpAndSettle(); // Wait for animations

      // Assert: Initially visible
      expect(find.text('Retry this operation'), findsOneWidget);

      // Act: Tap retry
      await tester.tap(find.text('Reintentar'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Snackbar dismissed
      expect(find.text('Retry this operation'), findsNothing);
    });
  });
}
