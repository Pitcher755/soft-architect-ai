// tests/test/unit/features/filesystem/infrastructure/security/path_validator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/domain/exceptions/filesystem_exceptions.dart';
import 'package:softarchitect_ai/features/filesystem/infrastructure/security/path_validator.dart';

void main() {
  group('PathValidator - Security Tests (CRITICAL)', () {
    late PathValidator validator;
    late String projectRoot;

    setUp(() {
      // Simular project root en ubicación temporal
      projectRoot = '/tmp/test_project';
      validator = PathValidator(projectRoot: projectRoot);
    });

    group('✅ VALID PATHS (Should Pass)', () {
      test('should accept simple relative path', () {
        expect(
          () => validator.validate('context/10-CONTEXT/doc.md'),
          returnsNormally,
        );
      });

      test('should accept nested relative path', () {
        expect(
          () => validator.validate(
            'context/30-ARCHITECTURE/decisions/adr-001.md',
          ),
          returnsNormally,
        );
      });

      test('should accept path with single dot (current dir)', () {
        expect(
          () => validator.validate('./context/README.md'),
          returnsNormally,
        );
      });

      test('should normalize double slashes', () {
        expect(
          () => validator.validate('context//10-CONTEXT///doc.md'),
          returnsNormally,
        );
      });
    });

    group('❌ ATTACK VECTORS (Should Throw PathTraversalException)', () {
      test('should reject path with parent directory traversal', () {
        expect(
          () => validator.validate('../secret.txt'),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should reject deeply nested parent traversal', () {
        expect(
          () => validator.validate('context/../../../../../../etc/passwd'),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should reject absolute path (Unix)', () {
        expect(
          () => validator.validate('/etc/passwd'),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should reject absolute path (Windows)', () {
        expect(
          () => validator.validate('C:\\Windows\\System32\\config.sys'),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should reject path escaping project root after normalization', () {
        // Tricky: starts inside, but ends outside after normalization
        expect(
          () => validator.validate('context/../../../outside.txt'),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should reject empty path', () {
        expect(
          () => validator.validate(''),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should reject path with null bytes (injection attack)', () {
        expect(
          () => validator.validate('context/file\x00.txt'),
          throwsA(isA<PathTraversalException>()),
        );
      });
    });

    group('🔍 EDGE CASES', () {
      test('should handle path with multiple dots in filename', () {
        expect(
          () => validator.validate('context/file.backup.2024.md'),
          returnsNormally,
        );
      });

      test('should accept Unicode characters in filename', () {
        expect(
          () => validator.validate('context/10-CONTEXT/documento_español_ñ.md'),
          returnsNormally,
        );
      });

      test('should accept spaces in path', () {
        expect(
          () => validator.validate('context/30-ARCHITECTURE/My Document.md'),
          returnsNormally,
        );
      });
    });

    group('🛡️ NORMALIZATION BEHAVIOR', () {
      test('should return normalized path on success', () {
        final result = validator.validate(
          './context/../context/10-CONTEXT/doc.md',
        );
        expect(result, contains('context/10-CONTEXT/doc.md'));
        expect(result, isNot(contains('..')));
      });

      test('should return absolute safe path within project', () {
        final result = validator.validate('context/README.md');
        expect(result, startsWith(projectRoot));
        expect(result, endsWith('context/README.md'));
      });
    });
  });

  group('PathValidator - Boundary Tests', () {
    test('should handle very long paths (DOS attack prevention)', () {
      final validator = PathValidator(projectRoot: '/tmp/test');
      final longPath = 'context/' + ('a/' * 500) + 'file.md';

      // Should either accept or throw, but NOT hang
      expect(
        () => validator.validate(longPath),
        anyOf(returnsNormally, throwsException),
      );
    });

    test('should handle special characters in project root', () {
      final validator = PathValidator(projectRoot: '/tmp/test project (2024)');
      expect(() => validator.validate('context/doc.md'), returnsNormally);
    });
  });
}
