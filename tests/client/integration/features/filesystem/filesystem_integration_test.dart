// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/domain/exceptions/filesystem_exceptions.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/providers/filesystem_providers.dart';

void main() {
  group('FileSystem Integration Tests', () {
    late ProviderContainer container;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fs_integration_');
      container = ProviderContainer();

      // Set project root
      container.read(projectRootProvider.notifier).state = tempDir.path;
    });

    tearDown(() async {
      container.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should create project structure via repository', () async {
      final repository = container.read(fileSystemRepositoryProvider);
      expect(repository, isNotNull);

      await repository!.initProjectStructure(tempDir.path);

      // Verify structure
      expect(
        await Directory('${tempDir.path}/context/10-CONTEXT').exists(),
        true,
      );
      expect(
        await Directory('${tempDir.path}/context/20-REQUIREMENTS').exists(),
        true,
      );
    });

    test('should save and read file via repository', () async {
      final repository = container.read(fileSystemRepositoryProvider);
      await repository!.initProjectStructure(tempDir.path);

      const content = '# Test Document\n\nIntegration test content';
      await repository.saveFile(
        relativePath: 'context/10-CONTEXT/test.md',
        content: content,
      );

      final readContent = await repository.readFile(
        'context/10-CONTEXT/test.md',
      );
      expect(readContent, content);
    });

    test('should log operations via audit logger', () async {
      final repository = container.read(fileSystemRepositoryProvider);
      final logger = container.read(auditLoggerProvider);

      await repository!.initProjectStructure(tempDir.path);
      await repository.saveFile(
        relativePath: 'context/test.md',
        content: 'test',
      );

      // Manually log (in real impl, service calls logger)
      await logger!.logWrite('context/test.md', 4);

      final entries = await logger.readLog();
      expect(entries, isNotEmpty);
      expect(entries.last, contains('WRITE'));
    });

    test('should handle path traversal via repository', () async {
      final repository = container.read(fileSystemRepositoryProvider);

      expect(
        () => repository!.saveFile(
          relativePath: '../../../etc/passwd',
          content: 'malicious',
        ),
        throwsA(isA<PathTraversalException>()),
      );
    });

    test('should update providers reactively', () {
      // Initial state
      expect(container.read(projectRootProvider), tempDir.path);
      expect(container.read(fileSystemRepositoryProvider), isNotNull);

      // Update project root
      container.read(projectRootProvider.notifier).state = '/new/path';

      // Repository should update automatically
      final newRepo = container.read(fileSystemRepositoryProvider);
      expect(newRepo, isNotNull);
    });

    test('should return null repository when no project root', () {
      final emptyContainer = ProviderContainer();

      expect(emptyContainer.read(projectRootProvider), isNull);
      expect(emptyContainer.read(fileSystemRepositoryProvider), isNull);
      expect(emptyContainer.read(auditLoggerProvider), isNull);

      emptyContainer.dispose();
    });
  });
}
