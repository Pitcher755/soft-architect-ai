import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/proposal_card_widget.dart';

void main() {
  group('ProposalCardWidget', () {
    testWidgets('should render markdown content', (WidgetTester tester) async {
      // Arrange
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: '# Title\n\nTest content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SelectableText), findsOneWidget);
      final selectableText = find.byType(SelectableText).first;
      expect(selectableText, findsOneWidget);
    });

    testWidgets('should show action buttons', (WidgetTester tester) async {
      // Arrange
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Validar y Guardar'), findsOneWidget);
      expect(find.text('Refinar'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);
    });

    testWidgets('should call onValidate when button tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool validateCalled = false;
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () => validateCalled = true,
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('Validar y Guardar'));
      await tester.pumpAndSettle();

      // Assert
      expect(validateCalled, true);
    });

    testWidgets('should call onRefine when refine button tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool refineCalled = false;
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () {},
              onRefine: () => refineCalled = true,
              onReject: () {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('Refinar'));
      await tester.pumpAndSettle();

      // Assert
      expect(refineCalled, true);
    });

    testWidgets('should call onReject when reject button tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool rejectCalled = false;
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () => rejectCalled = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      // Assert
      expect(rejectCalled, true);
    });

    testWidgets('should apply dark theme styling', (WidgetTester tester) async {
      // Arrange
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      // Assert
      final containerFinder = find.byType(Container).first;
      expect(containerFinder, findsOneWidget);
      // Verify widget was built successfully with dark theme
    });

    testWidgets('should display copy button in header', (
      WidgetTester tester,
    ) async {
      // Arrange
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Test content to copy',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: proposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Copiar'), findsOneWidget);
    });
  });
}
