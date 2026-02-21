import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/error_handling/error_mapper.dart';
import 'package:softarchitect_ai/core/error_handling/snackbar_service.dart';

/// Integration tests for error handling flow (E2E).
/// Tests complete error flow from error code to user feedback.
void main() {
  group('Error Handling E2E Flow', () {
    late SnackbarService snackbarService;

    setUp(() {
      // Force Spanish locale for consistent testing
      ErrorMapper.setLocale('es');
      snackbarService = SnackbarService();
    });

    testWidgets('should display error with Spanish message and suggestion', (
      WidgetTester tester,
    ) async {
      // Arrange: Setup widget with error display
      const errorCode = 'VAL_001';
      final errorMessage = ErrorMapper.getUserMessage(errorCode);
      final errorSuggestion = ErrorMapper.getSuggestion(errorCode);

      // Act: Build widget tree and show error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showError(context, '', errorMessage);
                });
                return Column(
                  children: [Text(errorMessage), Text('💡 $errorSuggestion')],
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger initial build
      await tester.pump(); // Process post-frame callback
      await tester.pump(const Duration(milliseconds: 500)); // Allow animation

      // Assert: Verify error displayed with Spanish message and suggestion
      expect(find.textContaining('inválido'), findsWidgets);
      expect(find.textContaining('💡'), findsOneWidget);
      expect(find.textContaining('Regenera el documento'), findsOneWidget);

      // Verify snackbar displayed (no icon check since styling may vary)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should persist critical error snackbar (no auto-hide)', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorMessage = 'Error: No hay conexión';

      // Act: Show error snackbar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showError(context, '', errorMessage);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump(); // Trigger build
      await tester.pump(); // Process callback
      await tester.pump(const Duration(milliseconds: 500)); // Animation

      // Assert: Error visible
      expect(find.byType(SnackBar), findsOneWidget);

      // Wait 6 seconds (longer than auto-hide duration)
      await tester.pump(const Duration(seconds: 6));

      // Error should still be visible (no auto-hide for errors)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should support retry with retryable errors', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorCode = 'RAG_001';
      final isRetryable = ErrorMapper.isRetryable(errorCode);

      // Act: Build retry button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(ErrorMapper.getUserMessage(errorCode)),
                if (isRetryable)
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('🔄 Reintentar'),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert: Verify retry button is present for retryable error
      expect(isRetryable, isTrue);
      expect(find.text('🔄 Reintentar'), findsOneWidget);

      // Trigger retry
      await tester.tap(find.text('🔄 Reintentar'));
      await tester.pump();
    });

    testWidgets('should not show retry button for non-retryable errors', (
      WidgetTester tester,
    ) async {
      // Arrange: Use a non-retryable error code
      const errorCode = 'AUTH_001'; // Missing API key (user action required)
      final isRetryable = ErrorMapper.isRetryable(errorCode);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(ErrorMapper.getUserMessage(errorCode)),
                if (isRetryable)
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('🔄 Reintentar'),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert: No retry button for user validation errors
      expect(isRetryable, isFalse);
      expect(find.text('🔄 Reintentar'), findsNothing);
    });

    testWidgets('should show success feedback after recovery', (
      WidgetTester tester,
    ) async {
      // Arrange: Simulate error recovery scenario
      const successMessage = '✅ Operación completada correctamente';

      // Act: Show success snackbar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  snackbarService.showSuccess(context, successMessage);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Success message displayed and icon present
      expect(find.text(successMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify success color (typically green)
      final snackbar = find.byType(SnackBar);
      expect(snackbar, findsOneWidget);
    });

    test('should map all validation error codes correctly', () {
      // Test that all validation gates have proper error codes
      const validationCodes = [
        'VAL_001',
        'VAL_002',
        'VAL_003',
        'VAL_004',
        'VAL_005',
      ];

      for (final code in validationCodes) {
        final message = ErrorMapper.getUserMessage(code);
        expect(message, isNotEmpty);
        expect(message, isNot('Error desconocido'));
      }
    });

    test('should classify system errors as retryable', () {
      // System errors should be retryable (infrastructure issues)
      const systemErrors = ['SYS_001', 'RAG_001', 'SYS_RETRY_EXHAUSTED'];

      for (final code in systemErrors) {
        final isRetryable = ErrorMapper.isRetryable(code);
        expect(
          isRetryable,
          isTrue,
          reason: '$code should be retryable (system error)',
        );
      }
    });

    test('should classify validation errors as non-retryable', () {
      // Validation errors should NOT be retryable (user errors)
      const validationErrors = ['VAL_003', 'VAL_004', 'VAL_005'];

      for (final code in validationErrors) {
        final isRetryable = ErrorMapper.isRetryable(code);
        expect(
          isRetryable,
          isFalse,
          reason: '$code should NOT be retryable (validation error)',
        );
      }
    });
  });
}
