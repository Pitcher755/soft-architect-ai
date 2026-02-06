import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/'
    'proposal_card_widget.dart';
import 'package:softarchitect_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Global test setup (if needed)
  });

  group('E2E Chat Sequential Flow', () {
    testWidgets(
      'should complete full document generation cycle',
      (WidgetTester tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navigate to chat
        final chatButton = find.text('Nuevo Proyecto');
        expect(chatButton, findsOneWidget, reason: 'Navigation button required');
        await tester.tap(chatButton);
        await tester.pumpAndSettle();

        // Act: Send message
        final inputField = find.byType(TextField);
        expect(
          inputField,
          findsOneWidget,
          reason: 'Chat input field required',
        );
        await tester.enterText(inputField, 'Genera el Project Manifesto');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();

        // Wait for streaming to complete
        await tester.pump(const Duration(seconds: 5));

        // Assert: Proposal should be visible
        expect(
          find.byType(ProposalCardWidget),
          findsOneWidget,
          reason: 'Proposal card must appear after streaming',
        );
        expect(
          find.text('Validar y Guardar'),
          findsOneWidget,
          reason: 'Action button required for proposal',
        );

        // Act: Validate proposal
        await tester.tap(find.text('Validar y Guardar'));
        await tester.pumpAndSettle();

        // Assert: Success toast and progress update
        expect(
          find.text('✅ Documento guardado'),
          findsOneWidget,
          reason: 'Success notification required',
        );
        expect(
          find.text('Doc 2/25'),
          findsOneWidget,
          reason: 'Progress counter must update',
        );
      },
    );

    testWidgets(
      'should handle streaming errors gracefully',
      (WidgetTester tester) async {
        // Arrange: Initialize app
        app.main();
        await tester.pumpAndSettle();

        // Navigate to chat
        final chatButton = find.text('Nuevo Proyecto');
        expect(chatButton, findsOneWidget);
        await tester.tap(chatButton);
        await tester.pumpAndSettle();

        // Act: Send message
        final inputField = find.byType(TextField);
        expect(inputField, findsOneWidget);
        await tester.enterText(inputField, 'Generate doc');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();

        // Wait for error
        await tester.pump(const Duration(seconds: 3));

        // Assert: Error message should be visible
        expect(
          find.textContaining('Error'),
          findsOneWidget,
          reason: 'Error message required on failure',
        );
        expect(
          find.text('Reintentar'),
          findsOneWidget,
          reason: 'Retry button required for error recovery',
        );
      },
    );
  });
}
