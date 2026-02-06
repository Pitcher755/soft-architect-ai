import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:softarchitect_ai/main.dart' as app;
import 'package:softarchitect_ai/features/chat/presentation/widgets/'
    'proposal_card_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Chat Sequential Flow', () {
    testWidgets(
      'should complete full document generation cycle',
      (WidgetTester tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();

        // Navigate to chat
        final chatButton = find.text('Nuevo Proyecto');
        await tester.tap(chatButton);
        await tester.pumpAndSettle();

        // Act: Send message
        final inputField = find.byType(TextField);
        await tester.enterText(inputField, 'Genera el Project Manifesto');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();

        // Wait for streaming to complete
        await tester.pump(const Duration(seconds: 5));

        // Assert: Proposal should be visible
        expect(find.byType(ProposalCardWidget), findsOneWidget);
        expect(find.text('Validar y Guardar'), findsOneWidget);

        // Act: Validate proposal
        await tester.tap(find.text('Validar y Guardar'));
        await tester.pumpAndSettle();

        // Assert: Success toast and progress update
        expect(find.text('✅ Documento guardado'), findsOneWidget);
        expect(find.text('Doc 2/25'), findsOneWidget);
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
        await tester.tap(chatButton);
        await tester.pumpAndSettle();

        // Act: Send message
        final inputField = find.byType(TextField);
        await tester.enterText(inputField, 'Generate doc');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();

        // Wait for error
        await tester.pump(const Duration(seconds: 3));

        // Assert: Error message should be visible
        expect(find.textContaining('Error'), findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);
      },
    );
  });
}
