import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/core/security/path_validator.dart';

void main() {
  group('PathValidator (project_shell/core)', () {
    test('builds safe path inside project', () {
      final full = PathValidator.validateFilePathInProject(
        projectPath: '/tmp/project',
        filePath: 'doc/readme.md',
      );
      expect(full, '/tmp/project/doc/readme.md');
    });

    test('rejects absolute and traversal paths', () {
      expect(
        () => PathValidator.validateFilePathInProject(
          projectPath: '/tmp/project',
          filePath: '/etc/passwd',
        ),
        throwsA(isA<PathTraversalException>()),
      );

      expect(
        () => PathValidator.validateFilePathInProject(
          projectPath: '/tmp/project',
          filePath: '../outside.md',
        ),
        throwsA(isA<PathTraversalException>()),
      );
    });

    test('validateProjectPath rejects invalid values', () {
      expect(
        () => PathValidator.validateProjectPath(''),
        throwsA(isA<PathTraversalException>()),
      );
      expect(
        () => PathValidator.validateProjectPath('relative/path'),
        throwsA(isA<PathTraversalException>()),
      );
    });

    test('file extension checks work for extension and basename', () {
      expect(PathValidator.isFileExtensionAllowed('README'), isTrue);
      expect(PathValidator.isFileExtensionAllowed('doc.md'), isTrue);
      expect(PathValidator.isFileExtensionAllowed('malware.exe'), isFalse);

      expect(
        () => PathValidator.validateFileExtensionOrThrow('malware.exe'),
        throwsA(isA<InvalidFileTypeException>()),
      );
    });
  });
}
