import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/infrastructure/validation/validation_constants.dart';

void main() {
  group('ValidationConstants', () {
    group('Project name regex', () {
      test('pattern is not empty', () {
        expect(ValidationConstants.projectNamePattern.isEmpty, isFalse);
      });

      test('pattern matches valid names', () {
        final regex = RegExp(ValidationConstants.projectNamePattern);
        expect(regex.hasMatch('MyProject'), isTrue);
        expect(regex.hasMatch('project_123'), isTrue);
        expect(regex.hasMatch('Project-v2'), isTrue);
      });

      test('pattern rejects invalid names', () {
        final regex = RegExp(ValidationConstants.projectNamePattern);
        expect(regex.hasMatch('My@Project'), isFalse);
        expect(regex.hasMatch('project with spaces'), isFalse);
        expect(regex.hasMatch('.hidden'), isFalse);
      });
    });

    group('File extension whitelist', () {
      test('contains dart extension', () {
        expect(ValidationConstants.allowedFileExtensions.contains('dart'), isTrue);
      });

      test('contains markdown extension', () {
        expect(ValidationConstants.allowedFileExtensions.contains('md'), isTrue);
      });

      test('contains python extension', () {
        expect(ValidationConstants.allowedFileExtensions.contains('py'), isTrue);
      });

      test('contains json extension', () {
        expect(ValidationConstants.allowedFileExtensions.contains('json'), isTrue);
      });

      test('contains yaml extension', () {
        expect(ValidationConstants.allowedFileExtensions.contains('yaml'), isTrue);
        expect(ValidationConstants.allowedFileExtensions.contains('yml'), isTrue);
      });

      test('is not empty', () {
        expect(ValidationConstants.allowedFileExtensions.isNotEmpty, isTrue);
      });

      test('all extensions are lowercase', () {
        for (final ext in ValidationConstants.allowedFileExtensions) {
          expect(ext, equals(ext.toLowerCase()));
        }
      });
    });

    group('Disallowed file extensions', () {
      test('contains executable extensions', () {
        expect(ValidationConstants.disallowedFileExtensions.contains('exe'), isTrue);
      });

      test('contains shell script extensions', () {
        expect(ValidationConstants.disallowedFileExtensions.contains('sh'), isTrue);
        expect(ValidationConstants.disallowedFileExtensions.contains('bat'), isTrue);
      });

      test('contains dynamic library extensions', () {
        expect(ValidationConstants.disallowedFileExtensions.contains('dll'), isTrue);
        expect(ValidationConstants.disallowedFileExtensions.contains('so'), isTrue);
      });

      test('is not empty', () {
        expect(ValidationConstants.disallowedFileExtensions.isNotEmpty, isTrue);
      });
    });

    group('Length constraints', () {
      test('min project name length is positive', () {
        expect(ValidationConstants.minProjectNameLength, greaterThan(0));
      });

      test('max project name length is reasonable', () {
        expect(ValidationConstants.maxProjectNameLength, greaterThan(ValidationConstants.minProjectNameLength));
      });

      test('min project name length is 3', () {
        expect(ValidationConstants.minProjectNameLength, equals(3));
      });

      test('max project name length is 50', () {
        expect(ValidationConstants.maxProjectNameLength, equals(50));
      });

      test('max path depth is reasonable', () {
        expect(ValidationConstants.maxPathDepth, greaterThan(5));
        expect(ValidationConstants.maxPathDepth, lessThan(100));
      });

      test('max filename length is reasonable', () {
        expect(ValidationConstants.maxFileNameLength, greaterThan(0));
        expect(ValidationConstants.maxFileNameLength, lessThanOrEqualTo(255));
      });
    });

    group('Error codes', () {
      test('project error code is defined', () {
        expect(ValidationConstants.errorCodeProjectInvalidName.isNotEmpty, isTrue);
      });

      test('security error code is defined', () {
        expect(ValidationConstants.errorCodePathTraversal.isNotEmpty, isTrue);
      });

      test('database error code is defined', () {
        expect(ValidationConstants.errorCodeDatabaseError.isNotEmpty, isTrue);
      });

      test('error codes follow naming convention', () {
        expect(ValidationConstants.errorCodeProjectInvalidName, startsWith('PROJ_'));
        expect(ValidationConstants.errorCodePathTraversal, startsWith('SEC_'));
        expect(ValidationConstants.errorCodeDatabaseError, startsWith('DB_'));
      });

      test('error codes are uppercase', () {
        expect(
          ValidationConstants.errorCodeProjectInvalidName,
          equals(ValidationConstants.errorCodeProjectInvalidName.toUpperCase()),
        );
      });
    });

    group('Sensitive patterns', () {
      test('contains environment variable pattern', () {
        expect(ValidationConstants.sensitivePatterns.isNotEmpty, isTrue);
      });

      test('patterns are not empty', () {
        for (final pattern in ValidationConstants.sensitivePatterns) {
          expect(pattern.isEmpty, isFalse);
        }
      });
    });

    group('Disallowed path components', () {
      test('contains parent directory traversal', () {
        expect(ValidationConstants.disallowedPathComponents.contains('..'), isTrue);
      });

      test('contains current directory', () {
        expect(ValidationConstants.disallowedPathComponents.contains('.'), isTrue);
      });

      test('contains home directory tilde', () {
        expect(ValidationConstants.disallowedPathComponents.contains('~'), isTrue);
      });

      test('is not empty', () {
        expect(ValidationConstants.disallowedPathComponents.isNotEmpty, isTrue);
      });
    });

    group('Constants consistency', () {
      test('no duplicate allowed extensions', () {
        final extensions = ValidationConstants.allowedFileExtensions;
        expect(extensions.length, equals(extensions.toSet().length));
      });

      test('no duplicate disallowed extensions', () {
        final extensions = ValidationConstants.disallowedFileExtensions;
        expect(extensions.length, equals(extensions.toSet().length));
      });

      test('allowed and disallowed extensions do not overlap', () {
        final allowed = ValidationConstants.allowedFileExtensions.toSet();
        final disallowed = ValidationConstants.disallowedFileExtensions.toSet();
        final overlap = allowed.intersection(disallowed);
        expect(overlap.isEmpty, isTrue);
      });

      test('no duplicate disallowed path components', () {
        final components = ValidationConstants.disallowedPathComponents;
        expect(components.length, equals(components.toSet().length));
      });
    });
  });
}
