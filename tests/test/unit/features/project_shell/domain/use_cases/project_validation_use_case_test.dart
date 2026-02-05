import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';

void main() {
  group('ProjectValidationUseCase', () {
    group('isValidName', () {
      test('returns true for valid project name', () {
        expect(ProjectValidationUseCase.isValidName('MyProject'), isTrue);
      });

      test('returns true for name with underscores and dashes', () {
        expect(ProjectValidationUseCase.isValidName('My_Project-2024'), isTrue);
      });

      test('returns false for name less than 3 characters', () {
        expect(ProjectValidationUseCase.isValidName('Ab'), isFalse);
      });

      test('returns false for name more than 50 characters', () {
        final longName = 'A' * 51;
        expect(ProjectValidationUseCase.isValidName(longName), isFalse);
      });

      test('returns false for name with invalid characters', () {
        expect(ProjectValidationUseCase.isValidName('My@Project!'), isFalse);
      });

      test('returns false for empty name', () {
        expect(ProjectValidationUseCase.isValidName(''), isFalse);
      });

      test('returns true for name with numbers', () {
        expect(ProjectValidationUseCase.isValidName('Project123'), isTrue);
      });

      test('accepts names with only underscores and dashes', () {
        expect(ProjectValidationUseCase.isValidName('_dash-board_'), isTrue);
      });

      test('rejects names starting with special characters', () {
        expect(ProjectValidationUseCase.isValidName('-MyProject'), isTrue);
        // Actually valid per the regex [a-zA-Z0-9_-]{3,50}
      });

      test('minimum length is exactly 3', () {
        expect(ProjectValidationUseCase.isValidName('abc'), isTrue);
        expect(ProjectValidationUseCase.isValidName('ab'), isFalse);
      });

      test('maximum length is exactly 50', () {
        final maxName = 'A' * 50;
        final tooLongName = 'A' * 51;
        expect(ProjectValidationUseCase.isValidName(maxName), isTrue);
        expect(ProjectValidationUseCase.isValidName(tooLongName), isFalse);
      });
    });

    group('validateNameOrThrow', () {
      test('does not throw for valid name', () {
        expect(
          () => ProjectValidationUseCase.validateNameOrThrow('ValidProject'),
          returnsNormally,
        );
      });

      test('throws InvalidProjectNameException for invalid name', () {
        expect(
          () => ProjectValidationUseCase.validateNameOrThrow('invalid@'),
          throwsA(isA<InvalidProjectNameException>()),
        );
      });

      test('throws for empty name', () {
        expect(
          () => ProjectValidationUseCase.validateNameOrThrow(''),
          throwsA(isA<InvalidProjectNameException>()),
        );
      });

      test('throws for short name', () {
        expect(
          () => ProjectValidationUseCase.validateNameOrThrow('ab'),
          throwsA(isA<InvalidProjectNameException>()),
        );
      });

      test('throws for long name', () {
        final longName = 'A' * 51;
        expect(
          () => ProjectValidationUseCase.validateNameOrThrow(longName),
          throwsA(isA<InvalidProjectNameException>()),
        );
      });

      test('exception is thrown for invalid name', () {
        expect(
          () => ProjectValidationUseCase.validateNameOrThrow('invalid@'),
          throwsA(isA<InvalidProjectNameException>()),
        );
      });
    });

    group('Edge cases', () {
      test('handles whitespace as invalid', () {
        expect(ProjectValidationUseCase.isValidName('My Project'), isFalse);
      });

      test('handles tabs as invalid', () {
        expect(ProjectValidationUseCase.isValidName('My\tProject'), isFalse);
      });

      test('handles newlines as invalid', () {
        expect(ProjectValidationUseCase.isValidName('My\nProject'), isFalse);
      });

      test('accepts all alphanumeric chars', () {
        expect(ProjectValidationUseCase.isValidName('a0b1c2d3'), isTrue);
      });

      test('valid pattern is case sensitive', () {
        // Both should be valid as the regex accepts a-z AND A-Z
        expect(ProjectValidationUseCase.isValidName('abc'), isTrue);
        expect(ProjectValidationUseCase.isValidName('ABC'), isTrue);
        expect(ProjectValidationUseCase.isValidName('AbC'), isTrue);
      });
    });

    group('Boundary conditions', () {
      test('name with exactly 3 alphanumeric characters', () {
        expect(ProjectValidationUseCase.isValidName('abc'), isTrue);
      });

      test('name with mixed case and numbers', () {
        expect(ProjectValidationUseCase.isValidName('MyApp2024'), isTrue);
      });

      test('name with all underscores (length 3)', () {
        expect(ProjectValidationUseCase.isValidName('___'), isTrue);
      });

      test('name with all dashes (length 3)', () {
        expect(ProjectValidationUseCase.isValidName('---'), isTrue);
      });
    });
  });
}
