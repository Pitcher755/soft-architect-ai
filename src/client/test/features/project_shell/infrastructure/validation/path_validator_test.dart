import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/infrastructure/validation/path_validator.dart';
import 'package:softarchitect_ai/features/project_shell/infrastructure/validation/validation_constants.dart';

void main() {
  group('PathValidator', () {
    group('validateFilePathInProject', () {
      test('accepts valid relative path', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/main.dart'),
          returnsNormally,
        );
      });

      test('accepts path with multiple subdirectories', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/features/project_shell/presentation/screens/project_shell_screen.dart'),
          returnsNormally,
        );
      });

      test('rejects absolute path with leading slash', () {
        expect(
          () => PathValidator.validateFilePathInProject('/etc/passwd'),
          throwsException,
        );
      });

      test('rejects path traversal with ../', () {
        expect(
          () => PathValidator.validateFilePathInProject('../../../etc/passwd'),
          throwsException,
        );
      });

      test('rejects path with .. in middle', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/../../../etc/passwd'),
          throwsException,
        );
      });

      test('rejects Windows absolute path', () {
        expect(
          () => PathValidator.validateFilePathInProject('C:\\Windows\\System32'),
          throwsException,
        );
      });

      test('rejects path with tilde expansion', () {
        expect(
          () => PathValidator.validateFilePathInProject('~/etc/passwd'),
          throwsException,
        );
      });

      test('rejects path with disallowed components', () {
        expect(
          () => PathValidator.validateFilePathInProject('.env'),
          throwsException,
        );
      });

      test('accepts file with allowed extension', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/main.dart'),
          returnsNormally,
        );
      });

      test('accepts markdown file', () {
        expect(
          () => PathValidator.validateFilePathInProject('README.md'),
          returnsNormally,
        );
      });

      test('accepts python file', () {
        expect(
          () => PathValidator.validateFilePathInProject('scripts/setup.py'),
          returnsNormally,
        );
      });

      test('rejects executable file', () {
        expect(
          () => PathValidator.validateFilePathInProject('script.exe'),
          throwsException,
        );
      });

      test('rejects shell script', () {
        expect(
          () => PathValidator.validateFilePathInProject('script.sh'),
          throwsException,
        );
      });

      test('rejects batch file', () {
        expect(
          () => PathValidator.validateFilePathInProject('script.bat'),
          throwsException,
        );
      });

      test('respects maximum path depth', () {
        final deepPath = List.generate(15, (i) => 'dir$i').join('/') + '/file.dart';
        expect(
          () => PathValidator.validateFilePathInProject(deepPath),
          throwsException,
        );
      });

      test('accepts path at maximum depth limit', () {
        final deepPath = List.generate(10, (i) => 'dir$i').join('/') + '/file.dart';
        expect(
          () => PathValidator.validateFilePathInProject(deepPath),
          returnsNormally,
        );
      });
    });

    group('isFileExtensionAllowed', () {
      test('allows dart files', () {
        expect(PathValidator.isFileExtensionAllowed('main.dart'), isTrue);
      });

      test('allows markdown files', () {
        expect(PathValidator.isFileExtensionAllowed('README.md'), isTrue);
      });

      test('allows python files', () {
        expect(PathValidator.isFileExtensionAllowed('script.py'), isTrue);
      });

      test('allows json files', () {
        expect(PathValidator.isFileExtensionAllowed('config.json'), isTrue);
      });

      test('allows yaml files', () {
        expect(PathValidator.isFileExtensionAllowed('pubspec.yaml'), isTrue);
      });

      test('allows txt files', () {
        expect(PathValidator.isFileExtensionAllowed('notes.txt'), isTrue);
      });

      test('disallows executable files', () {
        expect(PathValidator.isFileExtensionAllowed('program.exe'), isFalse);
      });

      test('disallows shell scripts', () {
        expect(PathValidator.isFileExtensionAllowed('script.sh'), isFalse);
      });

      test('disallows batch files', () {
        expect(PathValidator.isFileExtensionAllowed('script.bat'), isFalse);
      });

      test('disallows dll files', () {
        expect(PathValidator.isFileExtensionAllowed('library.dll'), isFalse);
      });

      test('disallows so files', () {
        expect(PathValidator.isFileExtensionAllowed('library.so'), isFalse);
      });

      test('case insensitive extension check', () {
        expect(PathValidator.isFileExtensionAllowed('main.DART'), isTrue);
        expect(PathValidator.isFileExtensionAllowed('README.MD'), isTrue);
      });

      test('files without extension are rejected', () {
        expect(PathValidator.isFileExtensionAllowed('Dockerfile'), isFalse);
      });
    });

    group('validateProjectPath', () {
      test('accepts valid project path', () {
        expect(
          () => PathValidator.validateProjectPath('/home/user/projects/MyProject'),
          returnsNormally,
        );
      });

      test('rejects path with .. traversal', () {
        expect(
          () => PathValidator.validateProjectPath('/home/../../../etc'),
          throwsException,
        );
      });

      test('rejects path that is too deep', () {
        final deepPath = '/home/' + List.generate(15, (i) => 'dir$i').join('/');
        expect(
          () => PathValidator.validateProjectPath(deepPath),
          throwsException,
        );
      });

      test('accepts relative paths', () {
        expect(
          () => PathValidator.validateProjectPath('projects/MyProject'),
          returnsNormally,
        );
      });
    });

    group('Security edge cases', () {
      test('rejects null byte injection', () {
        expect(
          () => PathValidator.validateFilePathInProject('file\x00.dart'),
          throwsException,
        );
      });

      test('rejects unicode tricks', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/../../etc'),
          throwsException,
        );
      });

      test('rejects encoded traversal attempts', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/%2e%2e/etc'),
          throwsException,
        );
      });

      test('handles whitespace in filenames', () {
        expect(
          () => PathValidator.validateFilePathInProject('lib/my file.dart'),
          returnsNormally,
        );
      });

      test('rejects multiple consecutive slashes', () {
        // Paths like //etc//passwd should be normalized and rejected
        expect(
          () => PathValidator.validateFilePathInProject('//etc//passwd'),
          throwsException,
        );
      });
    });
  });
}
