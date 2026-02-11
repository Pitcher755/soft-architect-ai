import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/proposal_card_widget.dart';
import 'package:softarchitect_ai/gen/app_localizations.dart';

/// Helper to create MaterialApp with proper i18n setup for tests
Widget createTestApp(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: child),
);

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
        createTestApp(
          ProposalCardWidget(
            proposal: proposal,
            onValidate: () {},
            onRefine: () {},
            onReject: () {},
          ),
        ),
      );

      // Assert
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('# Title\n\nTest content'), findsOneWidget);
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
        createTestApp(
          ProposalCardWidget(
            proposal: proposal,
            onValidate: () {},
            onRefine: () {},
            onReject: () {},
          ),
        ),
      );

      // Assert - Find buttons by type instead of localized text
      expect(find.byType(ElevatedButton), findsOneWidget); // Validate button
      expect(find.byType(OutlinedButton), findsOneWidget); // Refine button
      expect(find.byType(TextButton), findsOneWidget); // Reject button
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
        createTestApp(
          ProposalCardWidget(
            proposal: proposal,
            onValidate: () => validateCalled = true,
            onRefine: () {},
            onReject: () {},
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton)); // Validate button
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
        createTestApp(
          ProposalCardWidget(
            proposal: proposal,
            onValidate: () {},
            onRefine: () => refineCalled = true,
            onReject: () {},
          ),
        ),
      );
      await tester.tap(find.byType(OutlinedButton)); // Refine button
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
        createTestApp(
          ProposalCardWidget(
            proposal: proposal,
            onValidate: () {},
            onRefine: () {},
            onReject: () => rejectCalled = true,
          ),
        ),
      );
      await tester.tap(find.byType(TextButton)); // Reject button
      await tester.pumpAndSettle();

      // Assert
      expect(rejectCalled, true);
    });

    testWidgets('should apply dark theme styling', (WidgetTester tester) async {
      // Arrange
      final proposal = DocumentProposal(
        id: '1',
        docType: 'PROJECT_MAN IFESTO',
        content: 'Content',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
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
      expect(find.byType(ProposalCardWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
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
        createTestApp(
          ProposalCardWidget(
            proposal: proposal,
            onValidate: () {},
            onRefine: () {},
            onReject: () {},
          ),
        ),
      );

      // Assert - Find copy icon instead of localized text
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets); // Copy button uses InkWell
    });
  });
}
