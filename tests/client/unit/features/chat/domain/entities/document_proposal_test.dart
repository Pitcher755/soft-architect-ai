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
          'sections': ['Vision', 'Goals', 'Scope'],
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

    test('should support rejected state flag', () {
      final proposal = DocumentProposal(
        id: 'prop-2',
        docType: 'ADR',
        content: 'Rejected content',
        metadata: const {},
        validationState: ValidationState.rejected,
      );

      expect(proposal.isRejected, true);
      expect(proposal.isValidated, false);
      expect(proposal.isPending, false);
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

    test('extractSections should return empty list when no headers', () {
      final proposal = DocumentProposal(
        id: 'prop-3',
        docType: 'README',
        content: 'Plain text without markdown headers',
        metadata: const {},
        validationState: ValidationState.pending,
      );

      expect(proposal.extractSections(), isEmpty);
    });

    test('copyWith updates metadata and keeps defaults', () {
      final original = DocumentProposal(
        id: 'prop-4',
        docType: 'SPEC',
        content: '# Spec',
        metadata: const {'a': 1},
        validationState: ValidationState.pending,
      );

      final updated = original.copyWith(
        metadata: const {'a': 2, 'b': true},
        content: '# New Spec',
      );

      expect(updated.id, original.id);
      expect(updated.docType, original.docType);
      expect(updated.content, '# New Spec');
      expect(updated.metadata['a'], 2);
      expect(updated.metadata['b'], true);
    });

    test('equality and hashCode ignore metadata', () {
      final a = DocumentProposal(
        id: 'same',
        docType: 'SPEC',
        content: 'X',
        metadata: const {'version': 1},
        validationState: ValidationState.pending,
      );
      final b = DocumentProposal(
        id: 'same',
        docType: 'SPEC',
        content: 'X',
        metadata: const {'version': 2},
        validationState: ValidationState.validated,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
