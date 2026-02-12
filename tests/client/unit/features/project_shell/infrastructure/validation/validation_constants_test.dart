import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/constants/validation_constants.dart';

void main() {
  group('ValidationConstants', () {
    group('Project name validation', () {
      test('projectNamePattern is defined', () {
        expect(ValidationConstants.projectNamePattern.isNotEmpty, isTrue);
      });

      test('projectNameMinLength is positive', () {
        expect(ValidationConstants.projectNameMinLength, greaterThan(0));
      });

      test('projectNameMaxLength is greater than min', () {
        expect(
          ValidationConstants.projectNameMaxLength,
          greaterThan(ValidationConstants.projectNameMinLength),
        );
      });

      test('projectNameMinLength is 3', () {
        expect(ValidationConstants.projectNameMinLength, equals(3));
      });

      test('projectNameMaxLength is 50', () {
        expect(ValidationConstants.projectNameMaxLength, equals(50));
      });

      test('project name pattern matches valid names', () {
        final regex = RegExp(ValidationConstants.projectNamePattern);
        expect(regex.hasMatch('MyProject'), isTrue);
        expect(regex.hasMatch('project_123'), isTrue);
        expect(regex.hasMatch('Project-v2'), isTrue);
      });

      test('project name pattern rejects invalid names', () {
        final regex = RegExp(ValidationConstants.projectNamePattern);
        expect(regex.hasMatch('My'), isFalse); // Too short
        expect(regex.hasMatch('My Project'), isFalse); // Has space
        expect(regex.hasMatch('project!'), isFalse); // Has special char
      });
    });

    group('Path validation', () {
      test('disallowedPathComponents is not empty', () {
        expect(ValidationConstants.disallowedPathComponents.isNotEmpty, isTrue);
      });

      test('disallowedPathComponents contains parent traversal', () {
        expect(
          ValidationConstants.disallowedPathComponents.contains('..'),
          isTrue,
        );
      });

      test('disallowedPathComponents contains home traversal', () {
        expect(
          ValidationConstants.disallowedPathComponents.contains('~'),
          isTrue,
        );
      });

      test('maxFilePathLength is reasonable', () {
        expect(ValidationConstants.maxFilePathLength, greaterThan(100));
        expect(ValidationConstants.maxFilePathLength, lessThanOrEqualTo(10000));
      });
    });

    group('Allowed file extensions', () {
      test('allowedFileExtensions is not empty', () {
        expect(ValidationConstants.allowedFileExtensions.isNotEmpty, isTrue);
      });

      test('allowedFileExtensions contains Dart files', () {
        expect(
          ValidationConstants.allowedFileExtensions.contains('.dart'),
          isTrue,
        );
      });

      test('allowedFileExtensions contains Markdown', () {
        expect(
          ValidationConstants.allowedFileExtensions.contains('.md'),
          isTrue,
        );
      });

      test('allowedFileExtensions contains JSON', () {
        expect(
          ValidationConstants.allowedFileExtensions.contains('.json'),
          isTrue,
        );
      });

      test('allowedFileExtensions contains YAML', () {
        expect(
          ValidationConstants.allowedFileExtensions.contains('.yaml') ||
              ValidationConstants.allowedFileExtensions.contains('.yml'),
          isTrue,
        );
      });

      test('allowedFileExtensions includes Dockerfile', () {
        expect(
          ValidationConstants.allowedFileExtensions.contains('Dockerfile'),
          isTrue,
        );
      });
    });

    group('Error codes', () {
      test('errorCodeInvalidProjectName is defined', () {
        expect(
          ValidationConstants.errorCodeInvalidProjectName.isNotEmpty,
          isTrue,
        );
      });

      test('errorCodeInvalidProjectName starts with PROJ_', () {
        expect(
          ValidationConstants.errorCodeInvalidProjectName,
          startsWith('PROJ_'),
        );
      });

      test('errorCodeDuplicateProject is defined', () {
        expect(
          ValidationConstants.errorCodeDuplicateProject.isNotEmpty,
          isTrue,
        );
      });

      test('errorCodeProjectNotFound is defined', () {
        expect(ValidationConstants.errorCodeProjectNotFound.isNotEmpty, isTrue);
      });

      test('errorCodePathTraversal is defined', () {
        expect(ValidationConstants.errorCodePathTraversal.isNotEmpty, isTrue);
      });

      test('errorCodePathTraversal starts with SEC_', () {
        expect(ValidationConstants.errorCodePathTraversal, startsWith('SEC_'));
      });

      test('errorCodeDatabaseError is defined', () {
        expect(ValidationConstants.errorCodeDatabaseError.isNotEmpty, isTrue);
      });

      test('errorCodeDatabaseError starts with DB_', () {
        expect(ValidationConstants.errorCodeDatabaseError, startsWith('DB_'));
      });

      test('errorCodeFileSystemError is defined', () {
        expect(ValidationConstants.errorCodeFileSystemError.isNotEmpty, isTrue);
      });

      test('errorCodeFileSystemError starts with FS_', () {
        expect(ValidationConstants.errorCodeFileSystemError, startsWith('FS_'));
      });

      test('errorCodeUnauthorized is defined', () {
        expect(ValidationConstants.errorCodeUnauthorized.isNotEmpty, isTrue);
      });

      test('errorCodeInvalidFileType is defined', () {
        expect(ValidationConstants.errorCodeInvalidFileType.isNotEmpty, isTrue);
      });
    });

    group('Security and logging', () {
      test('sensitivePatterns is not empty', () {
        expect(ValidationConstants.sensitivePatterns.isNotEmpty, isTrue);
      });

      test('sensitivePatterns contains password', () {
        expect(
          ValidationConstants.sensitivePatterns.contains('password'),
          isTrue,
        );
      });

      test('sensitivePatterns contains api_key', () {
        expect(
          ValidationConstants.sensitivePatterns.contains('api_key'),
          isTrue,
        );
      });

      test('sensitivePatterns contains secret', () {
        expect(
          ValidationConstants.sensitivePatterns.contains('secret'),
          isTrue,
        );
      });

      test('sensitivePatterns contains token', () {
        expect(ValidationConstants.sensitivePatterns.contains('token'), isTrue);
      });

      test('maxLogLength is reasonable', () {
        expect(ValidationConstants.maxLogLength, greaterThan(100));
        expect(ValidationConstants.maxLogLength, lessThanOrEqualTo(10000));
      });
    });

    group('Constants immutability', () {
      test('all constants are static final/const', () {
        // This is verified by the type system, not at runtime
        expect(ValidationConstants.projectNamePattern, isNotNull);
        expect(ValidationConstants.projectNameMinLength, isNotNull);
        expect(ValidationConstants.projectNameMaxLength, isNotNull);
        expect(ValidationConstants.disallowedPathComponents, isNotNull);
        expect(ValidationConstants.allowedFileExtensions, isNotNull);
        expect(ValidationConstants.sensitivePatterns, isNotNull);
      });
    });
  });
}
