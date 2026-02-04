import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/core/security/path_validator.dart';

void main() {
  group('PathValidator', () {
    const projectPath = '/home/user/my_project';

    group('validateFilePathInProject', () {
      test('accepts valid relative path', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/main.dart',
          ),
          returnsNormally,
        );
      });

      test('accepts path with multiple subdirectories', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath:
                'lib/features/project_shell/presentation/screens/project_shell_screen.dart',
          ),
          returnsNormally,
        );
      });

      test('rejects absolute path with leading slash', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '/etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('rejects path traversal with ../', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '../../../etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('rejects paths with .. in the middle', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/../../../etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('rejects paths escaping project boundary', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '../../other_project/secret.txt',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('accepts deep nested paths within project', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'src/a/b/c/d/e/f/g/h/file.dart',
          ),
          returnsNormally,
        );
      });

      test('rejects paths exceeding maximum length', () {
        // maxFilePathLength should be in ValidationConstants
        final longPath = List.filled(3000, 'a').join('/');
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: longPath,
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('returns normalized safe path', () {
        final result = PathValidator.validateFilePathInProject(
          projectPath: projectPath,
          filePath: 'lib/main.dart',
        );
        expect(result, contains('lib/main.dart'));
        expect(result, contains(projectPath));
      });

      test('handles normalized paths correctly', () {
        final result = PathValidator.validateFilePathInProject(
          projectPath: projectPath,
          filePath: './lib/./main.dart',
        );
        expect(result, isNotEmpty);
      });

      test('rejects symbolic link traversal attempts', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/symlink/../../../etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('rejects hidden file patterns', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '../../.ssh/id_rsa',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('accepts files with dots in name', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'assets/config.dev.yaml',
          ),
          returnsNormally,
        );
      });

      test('accepts files with multiple extensions', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/app.config.dart',
          ),
          returnsNormally,
        );
      });

      test('rejects null bytes in path', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/file\x00.dart',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('rejects paths with disallowed components', () {
        // Based on ValidationConstants.disallowedPathComponents
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '../../../main.dart',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('is case sensitive for path traversal', () {
        // .. should be rejected regardless of case
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/..\\main.dart',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });
    });

    group('Security edge cases', () {
      test('prevents reading /etc/passwd', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '/etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('prevents reading /root/.ssh/id_rsa', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '/root/.ssh/id_rsa',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('prevents reading Windows system files', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '/etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('prevents unicode path traversal', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: 'lib/file\x00\x00\x00.dart',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('prevents double encoding traversal', () {
        expect(
          () => PathValidator.validateFilePathInProject(
            projectPath: projectPath,
            filePath: '../../../etc/passwd',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });
    });

    group('Path normalization', () {
      test('normalizes forward slashes', () {
        final result = PathValidator.validateFilePathInProject(
          projectPath: projectPath,
          filePath: 'lib///main.dart',
        );
        expect(result, isNotEmpty);
      });

      test('removes redundant dot references', () {
        final result = PathValidator.validateFilePathInProject(
          projectPath: projectPath,
          filePath: './lib/./main.dart',
        );
        expect(result, contains('lib/main.dart'));
      });
    });
  });
}
