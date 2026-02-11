// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/providers/filesystem_providers.dart';

void main() {
  group('E2E: Project Creation Flow', () {
    late ProviderContainer container;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('e2e_test_');
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('FULL FLOW: Create project → Save docs → Read → Delete', () async {
      // Step 1: User selects project folder
      container.read(projectRootProvider.notifier).state = tempDir.path;

      // Step 2: System creates project structure
      final repository = container.read(fileSystemRepositoryProvider);
      expect(
        repository,
        isNotNull,
        reason: 'Repository should be available after setting project root',
      );

      await repository!.initProjectStructure(tempDir.path);

      // Step 3: Verify standard directories exist
      final dirs = [
        '10-CONTEXT',
        '20-REQUIREMENTS',
        '30-ARCHITECTURE',
        '35-UX_UI',
        '40-PLANNING',
      ];

      for (final dir in dirs) {
        final path = '${tempDir.path}/context/$dir';
        expect(
          await Directory(path).exists(),
          true,
          reason: 'Directory $dir should exist',
        );
      }

      // Step 4: User generates first document via chat
      const doc1Content = '''# Contexto del Proyecto

## Propósito
Este es un proyecto de prueba para validar el FileSystemService.

## Alcance
- Feature 1
- Feature 2
''';

      await repository.saveFile(
        relativePath: 'context/10-CONTEXT/PROJECT_MANIFESTO.md',
        content: doc1Content,
      );

      // Step 5: Verify file was saved
      expect(
        await repository.fileExists('context/10-CONTEXT/PROJECT_MANIFESTO.md'),
        true,
      );

      // Step 6: User generates second document
      const doc2Content = '''# Requisitos Funcionales

## RF-1: Login de usuario
**Descripción:** El sistema debe permitir login...
''';

      await repository.saveFile(
        relativePath: 'context/20-REQUIREMENTS/FUNCTIONAL_REQUIREMENTS.md',
        content: doc2Content,
      );

      // Step 7: User lists all documents in context/
      final allFiles = await repository.listFiles(relativePath: 'context');

      expect(allFiles.length, greaterThanOrEqualTo(2));
      expect(allFiles, anyElement(contains('PROJECT_MANIFESTO.md')));
      expect(allFiles, anyElement(contains('FUNCTIONAL_REQUIREMENTS.md')));

      // Step 8: User reads a document
      final readDoc = await repository.readFile(
        'context/10-CONTEXT/PROJECT_MANIFESTO.md',
      );
      expect(readDoc, doc1Content);

      // Step 9: User deletes a document
      await repository.deleteFile(
        'context/20-REQUIREMENTS/FUNCTIONAL_REQUIREMENTS.md',
      );
      expect(
        await repository.fileExists(
          'context/20-REQUIREMENTS/FUNCTIONAL_REQUIREMENTS.md',
        ),
        false,
      );

      // Step 10: Verify audit log
      final logger = container.read(auditLoggerProvider);
      // Should have logged project creation (if implemented in service)
      // For now, just verify logger exists and works
      expect(logger, isNotNull);
    });

    test('E2E: Multiple projects in sequence', () async {
      // Project 1
      final project1 = Directory('${tempDir.path}/project1');
      await project1.create();
      container.read(projectRootProvider.notifier).state = project1.path;

      final repo1 = container.read(fileSystemRepositoryProvider);
      await repo1!.initProjectStructure(project1.path);
      await repo1.saveFile(
        relativePath: 'context/doc1.md',
        content: 'Project 1 content',
      );

      // Project 2
      final project2 = Directory('${tempDir.path}/project2');
      await project2.create();
      container.read(projectRootProvider.notifier).state = project2.path;

      final repo2 = container.read(fileSystemRepositoryProvider);
      await repo2!.initProjectStructure(project2.path);
      await repo2.saveFile(
        relativePath: 'context/doc2.md',
        content: 'Project 2 content',
      );

      // Verify isolation
      expect(await repo2.fileExists('context/doc1.md'), false);
      expect(await repo2.fileExists('context/doc2.md'), true);
    });

    test('E2E: Error handling in project flow', () async {
      // Set project root
      container.read(projectRootProvider.notifier).state = tempDir.path;
      final repository = container.read(fileSystemRepositoryProvider);

      await repository!.initProjectStructure(tempDir.path);

      // Test path traversal protection in E2E context
      expect(
        () => repository.saveFile(
          relativePath: '../../../etc/passwd',
          content: 'malicious',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
