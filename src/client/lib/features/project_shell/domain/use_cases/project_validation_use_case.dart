// lib/features/project_shell/domain/use_cases/project_validation_use_case.dart
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';

/// Use case: Validate project names
class ProjectValidationUseCase {
  /// Regex pattern: [a-zA-Z0-9_-]{3,50}
  static final _validNamePattern = RegExp(r'^[a-zA-Z0-9_-]{3,50}$');

  /// Check if project name is valid
  static bool isValidName(String name) {
    return _validNamePattern.hasMatch(name);
  }

  /// Validate or throw exception
  static void validateNameOrThrow(String name) {
    if (!isValidName(name)) {
      throw InvalidProjectNameException(name);
    }
  }
}
