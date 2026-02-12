// ignore_for_file: avoid_slow_async_io
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:softarchitect_ai/features/filesystem/domain/exceptions/filesystem_exceptions.dart';
import 'package:softarchitect_ai/features/filesystem/infrastructure/services/filesystem_service_impl.dart';

void main() {
  group('FileSystemServiceImpl', () {
    late FileSystemServiceImpl service;
    late Directory tempDir;
    late String projectRoot;

    setUp(() async {
      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('filesystem_test_');
      projectRoot = tempDir.path;
      service = FileSystemServiceImpl(projectRoot: projectRoot);
    });

    tearDown(() async {
      // Cleanup
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('initProjectStructure', () {
      test('should create standard directory structure', () async {
        await service.initProjectStructure(projectRoot);

        // Verify directories exist
        expect(
          await Directory(p.join(projectRoot, 'context/10-CONTEXT')).exists(),
          true,
        );
        expect(
          await Directory(
            p.join(projectRoot, 'context/20-REQUIREMENTS'),
          ).exists(),
          true,
        );
        expect(
          await Directory(
            p.join(projectRoot, 'context/30-ARCHITECTURE'),
          ).exists(),
          true,
        );
        expect(
          await Directory(p.join(projectRoot, 'context/35-UX_UI')).exists(),
          true,
        );
        expect(
          await Directory(p.join(projectRoot, 'context/40-PLANNING')).exists(),
          true,
        );
      });

      test('should create .gitkeep files in each directory', () async {
        await service.initProjectStructure(projectRoot);

        expect(
          await File(
            p.join(projectRoot, 'context/10-CONTEXT/.gitkeep'),
          ).exists(),
          true,
        );
        expect(
          await File(
            p.join(projectRoot, 'context/20-REQUIREMENTS/.gitkeep'),
          ).exists(),
          true,
        );
      });

      test('should create README files', () async {
        await service.initProjectStructure(projectRoot);

        expect(await File(p.join(projectRoot, 'README.md')).exists(), true);
        expect(
          await File(p.join(projectRoot, 'context/README.md')).exists(),
          true,
        );
      });

      test('should be idempotent (safe to call multiple times)', () async {
        await service.initProjectStructure(projectRoot);

        // Call again - should not throw
        await service.initProjectStructure(projectRoot);

        // Verify still exists
        expect(
          await Directory(p.join(projectRoot, 'context/10-CONTEXT')).exists(),
          true,
        );
      });
    });

    group('saveFile', () {
      test('should save file with content', () async {
        await service.initProjectStructure(projectRoot);

        final content = '# Test Document\n\nHello World!';
        await service.saveFile(
          relativePath: 'context/10-CONTEXT/test.md',
          content: content,
        );

        final file = File(p.join(projectRoot, 'context/10-CONTEXT/test.md'));
        expect(await file.exists(), true);
        expect(await file.readAsString(), content);
      });

      test('should create parent directories if missing', () async {
        final content = 'Test content';
        await service.saveFile(
          relativePath: 'new/nested/dir/file.txt',
          content: content,
          createDirs: true,
        );

        final file = File(p.join(projectRoot, 'new/nested/dir/file.txt'));
        expect(await file.exists(), true);
      });

      test('should reject path traversal', () async {
        expect(
          () => service.saveFile(
            relativePath: '../../../etc/passwd',
            content: 'hacked',
          ),
          throwsA(isA<PathTraversalException>()),
        );
      });
    });

    group('readFile', () {
      test('should read existing file', () async {
        await service.initProjectStructure(projectRoot);

        final content = '# Test\n\nContent here';
        await service.saveFile(
          relativePath: 'context/10-CONTEXT/test.md',
          content: content,
        );

        final read = await service.readFile('context/10-CONTEXT/test.md');
        expect(read, content);
      });

      test('should throw FileNotFoundException for missing file', () async {
        expect(
          () => service.readFile('nonexistent.md'),
          throwsA(isA<FileNotFoundException>()),
        );
      });
    });

    group('fileExists', () {
      test('should return true for existing file', () async {
        await service.initProjectStructure(projectRoot);
        await service.saveFile(
          relativePath: 'context/test.md',
          content: 'test',
        );

        expect(await service.fileExists('context/test.md'), true);
      });

      test('should return false for non-existent file', () async {
        expect(await service.fileExists('nonexistent.md'), false);
      });
    });

    group('listFiles', () {
      test('should list all files in directory', () async {
        await service.initProjectStructure(projectRoot);
        await service.saveFile(
          relativePath: 'context/10-CONTEXT/doc1.md',
          content: 'test',
        );
        await service.saveFile(
          relativePath: 'context/10-CONTEXT/doc2.md',
          content: 'test',
        );
        await service.saveFile(
          relativePath: 'context/20-REQUIREMENTS/req.md',
          content: 'test',
        );

        final files = await service.listFiles(relativePath: 'context');

        expect(files.length, greaterThanOrEqualTo(3));
        expect(files, contains(contains('10-CONTEXT/doc1.md')));
        expect(files, contains(contains('10-CONTEXT/doc2.md')));
      });

      test('should filter by extensions', () async {
        await service.initProjectStructure(projectRoot);
        await service.saveFile(relativePath: 'context/doc.md', content: 'test');
        await service.saveFile(
          relativePath: 'context/data.json',
          content: '{}',
        );
        await service.saveFile(
          relativePath: 'context/notes.txt',
          content: 'notes',
        );

        final mdFiles = await service.listFiles(
          relativePath: 'context',
          extensions: ['.md'],
        );

        expect(mdFiles, contains(contains('doc.md')));
        expect(mdFiles, isNot(contains(contains('data.json'))));
      });
    });

    group('deleteFile', () {
      test('should delete existing file', () async {
        await service.initProjectStructure(projectRoot);
        await service.saveFile(
          relativePath: 'context/temp.md',
          content: 'test',
        );

        expect(await service.fileExists('context/temp.md'), true);

        await service.deleteFile('context/temp.md');

        expect(await service.fileExists('context/temp.md'), false);
      });

      test('should throw FileNotFoundException for missing file', () async {
        expect(
          () => service.deleteFile('nonexistent.md'),
          throwsA(isA<FileNotFoundException>()),
        );
      });
    });
  });
}
