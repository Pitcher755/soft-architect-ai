import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/domain/entities/document_proposal.dart';

void main() {
  group('DocumentProposal Entity', () {
    test('should create proposal with validation state', () {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-1',
        docType: 'PROJECT_MANIFESTO',
        content: '# Project Title\n\nDescription...',
        metadata: {
          'estimated_pages': 5,
          'sections': ['Vision', 'Goals', 'Scope']
        },
        validationState: ValidationState.pending,
      );

      // Assert
      expect(proposal.id, 'prop-1');
      expect(proposal.docType, 'PROJECT_MANIFESTO');
      expect(proposal.isPending, true);
      expect(proposal.isValidated, false);
    });

    test('should transition to validated state', () {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-1',
        docType: 'PROJECT_MANIFESTO',
        content: 'Content...',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      final validated = proposal.copyWith(
        validationState: ValidationState.validated,
      );

      // Assert
      expect(validated.isValidated, true);
      expect(validated.isPending, false);
    });

    test('should extract sections from markdown content', () {
      // Arrange
      final proposal = DocumentProposal(
        id: 'prop-1',
        docType: 'PROJECT_MANIFESTO',
        content: '''
# Project Title

## Vision
Vision content

## Goals
Goals content
''',
        metadata: {},
        validationState: ValidationState.pending,
      );

      // Act
      final sections = proposal.extractSections();

      // Assert
      expect(sections.length, greaterThanOrEqualTo(2));
      expect(sections, contains('Vision'));
      expect(sections, contains('Goals'));
    });
  });
}
