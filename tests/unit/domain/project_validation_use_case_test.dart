// tests/unit/domain/project_validation_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';

void main() {
  group('ProjectValidationUseCase', () {
    test('isValidName rejects names shorter than 3 chars', () {
      expect(ProjectValidationUseCase.isValidName('ab'), false);
      expect(ProjectValidationUseCase.isValidName(''), false);
    });

    test('isValidName accepts valid project names', () {
      expect(ProjectValidationUseCase.isValidName('my-project'), true);
      expect(ProjectValidationUseCase.isValidName('MyProject_2'), true);
      expect(ProjectValidationUseCase.isValidName('project123'), true);
    });

    test('isValidName rejects names with special characters', () {
      expect(ProjectValidationUseCase.isValidName('my project'), false);
      expect(ProjectValidationUseCase.isValidName('my@project'), false);
      expect(ProjectValidationUseCase.isValidName('../project'), false);
    });

    test('isValidName rejects names longer than 50 chars', () {
      final longName = 'a' * 51;
      expect(ProjectValidationUseCase.isValidName(longName), false);
    });
  });
}
