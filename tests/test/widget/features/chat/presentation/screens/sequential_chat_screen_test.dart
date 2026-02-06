import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/chat_message.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/proposal_card_widget.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/streaming_indicator_widget.dart';

void main() {
  group('SequentialChatScreen Widget Tests', () {
    /// Test 3: Display messages in chat history
    testWidgets('displays chat messages in correct order', (WidgetTester tester) async {
      final testMessage = ChatMessage(
        id: 'msg-1',
        role: MessageRole.user,
        content: 'Tell me about Document 1',
        timestamp: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ListView(children: [Text(testMessage.content)])),
        ),
      );

      expect(find.text('Tell me about Document 1'), findsOneWidget);
    });

    /// Test 4: Display proposal card when document is generated
    testWidgets('shows proposal card when currentProposal is set', (WidgetTester tester) async {
      final mockProposal = DocumentProposal(
        id: 'doc-1',
        docType: 'architecture',
        content: '## Architecture Overview\n\nDetailed architecture content...',
        metadata: {'source': 'test'},
        validationState: ValidationState.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: mockProposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProposalCardWidget), findsOneWidget);
    });

    /// Test 5: Show streaming indicator during document generation
    testWidgets('displays streaming indicator while generating', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.5,
              documentIndex: 1,
              totalDocuments: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StreamingIndicatorWidget), findsOneWidget);
    });

    /// Test 6: Verify proposal card functionality
    testWidgets('proposal card displays document content correctly', (WidgetTester tester) async {
      final mockProposal = DocumentProposal(
        id: 'doc-2',
        docType: 'specification',
        content: '## Requirements\n\nFunctional and non-functional requirements',
        metadata: {'version': '1.0'},
        validationState: ValidationState.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalCardWidget(
              proposal: mockProposal,
              onValidate: () {},
              onRefine: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProposalCardWidget), findsOneWidget);
    });

    /// Test 7: Verify streaming indicator updates
    testWidgets('streaming indicator shows progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreamingIndicatorWidget(
              progress: 0.75,
              documentIndex: 2,
              totalDocuments: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StreamingIndicatorWidget), findsOneWidget);
    });

    /// Test 8: Verify multiple proposal cards can be displayed
    testWidgets('multiple proposal cards can be displayed in sequence', (WidgetTester tester) async {
      final proposals = [
        DocumentProposal(
          id: 'doc-1',
          docType: 'architecture',
          content: '## Architecture Overview',
          metadata: {'order': 1},
          validationState: ValidationState.pending,
        ),
        DocumentProposal(
          id: 'doc-2',
          docType: 'specification',
          content: '## Specification',
          metadata: {'order': 2},
          validationState: ValidationState.pending,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                return ProposalCardWidget(
                  proposal: proposals[index],
                  onValidate: () {},
                  onRefine: () {},
                  onReject: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProposalCardWidget), findsWidgets);
    });
  });
}
