import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';
import 'package:softarchitect_ai/features/project_shell/infrastructure/validation/validation_constants.dart';

void main() {
  late ProjectValidationUseCase validationUseCase;

  setUp(() {
    validationUseCase = ProjectValidationUseCase();
  });

  group('ProjectValidationUseCase', () {
    group('isValidName', () {
      test('returns true for valid project name', () {
        expect(validationUseCase.isValidName('MyProject'), isTrue);
      });

      test('returns true for name with underscores and dashes', () {
        expect(validationUseCase.isValidName('My_Project-2024'), isTrue);
      });

      test('returns false for name less than 3 characters', () {
        expect(validationUseCase.isValidName('Ab'), isFalse);
      });

      test('returns false for name more than 50 characters', () {
        final longName = 'A' * 51;
        expect(validationUseCase.isValidName(longName), isFalse);
      });

      test('returns false for name with invalid characters', () {
        expect(validationUseCase.isValidName('My@Project!'), isFalse);
      });

      test('returns false for empty name', () {
        expect(validationUseCase.isValidName(''), isFalse);
      });

      test('returns true for name with numbers', () {
        expect(validationUseCase.isValidName('Project123'), isTrue);
      });
    });

    group('isSafeName', () {
      test('returns true for safe name', () {
        expect(validationUseCase.isSafeName('MyProject'), isTrue);
      });

      test('returns false for hidden file name', () {
        expect(validationUseCase.isSafeName('.hiddenProject'), isFalse);
      });

      test('returns false for suspicious pattern names', () {
        expect(validationUseCase.isSafeName('../../etc'), isFalse);
      });

      test('returns true for valid safe names', () {
        expect(validationUseCase.isSafeName('ValidProject'), isTrue);
        expect(validationUseCase.isSafeName('Project_2024'), isTrue);
        expect(validationUseCase.isSafeName('project-v1'), isTrue);
      });
    });

    group('validateCompleteOrThrow', () {
      test('throws error for invalid project name', () {
        final project = Project(
          id: 'proj_123',
          name: 'Ab', // Too short
          path: '/valid/path',
          createdAt: DateTime.now(),
        );

        expect(
          () => validationUseCase.validateCompleteOrThrow(project),
          throwsException,
        );
      });

      test('throws error for unsafe project name', () {
        final project = Project(
          id: 'proj_123',
          name: '.hidden',
          path: '/valid/path',
          createdAt: DateTime.now(),
        );

        expect(
          () => validationUseCase.validateCompleteOrThrow(project),
          throwsException,
        );
      });

      test('does not throw for valid project', () {
        final project = Project(
          id: 'proj_123',
          name: 'ValidProject',
          path: '/valid/path',
          createdAt: DateTime.now(),
        );

        expect(
          () => validationUseCase.validateCompleteOrThrow(project),
          returnsNormally,
        );
      });
    });

    group('Name length validation', () {
      test('minimum length exactly 3 characters is valid', () {
        expect(validationUseCase.isValidName('Abc'), isTrue);
      });

      test('maximum length exactly 50 characters is valid', () {
        final name50 = 'A' * 50;
        expect(validationUseCase.isValidName(name50), isTrue);
      });

      test('length 2 characters is invalid', () {
        expect(validationUseCase.isValidName('Ab'), isFalse);
      });

      test('length 51 characters is invalid', () {
        final name51 = 'A' * 51;
        expect(validationUseCase.isValidName(name51), isFalse);
      });
    });

    group('Name pattern validation', () {
      test('allows uppercase letters', () {
        expect(validationUseCase.isValidName('PROJECT'), isTrue);
      });

      test('allows lowercase letters', () {
        expect(validationUseCase.isValidName('project'), isTrue);
      });

      test('allows numbers', () {
        expect(validationUseCase.isValidName('Project2024'), isTrue);
      });

      test('allows underscores', () {
        expect(validationUseCase.isValidName('My_Project'), isTrue);
      });

      test('allows dashes', () {
        expect(validationUseCase.isValidName('My-Project'), isTrue);
      });

      test('rejects spaces', () {
        expect(validationUseCase.isValidName('My Project'), isFalse);
      });

      test('rejects special characters', () {
        expect(validationUseCase.isValidName('Project@#$'), isFalse);
      });

      test('rejects dots in middle of name', () {
        expect(validationUseCase.isValidName('My.Project'), isFalse);
      });
    });
  });
}
