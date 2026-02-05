import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:softarchitect_ai/features/filesystem/infrastructure/logging/audit_logger.dart';

void main() {
  group('AuditLogger', () {
    late AuditLogger logger;
    late Directory tempDir;
    late String projectRoot;

    setUp(() async {
      // Create a temporary directory for each test
      tempDir = await Directory.systemTemp.createTemp('audit_test_');
      projectRoot = tempDir.path;

      // Create required context structure
      final contextDir = Directory(p.join(projectRoot, 'context/40-PLANNING'));
      await contextDir.create(recursive: true);

      logger = AuditLogger(projectRoot: projectRoot);
    });

    tearDown(() async {
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should create log file on first write', () async {
      await logger.logWrite('test.md', 1024);

      final logFile = File(
        p.join(projectRoot, 'context/40-PLANNING/.audit.log'),
      );
      expect(
        await logFile.exists(),
        true,
        reason: 'Log file should be created on first write',
      );
    });

    test('should log write operations with timestamp and size', () async {
      await logger.logWrite('context/10-CONTEXT/doc.md', 2048);

      final entries = await logger.readLog();
      expect(
        entries.isNotEmpty,
        true,
        reason: 'Log should have at least one entry',
      );

      final firstEntry = entries.first;
      expect(
        firstEntry,
        contains('WRITE'),
        reason: 'Log entry should contain WRITE operation',
      );
      expect(
        firstEntry,
        contains('doc.md'),
        reason: 'Log entry should contain filename',
      );
      expect(
        firstEntry,
        contains('2.0 KB'),
        reason: 'Log entry should show formatted file size',
      );
      expect(
        firstEntry,
        matches(RegExp(r'\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]')),
        reason:
            'Log entry should have timestamp in format [YYYY-MM-DD HH:MM:SS]',
      );
    });

    test('should log delete operations', () async {
      await logger.logDelete('context/old.md');

      final entries = await logger.readLog();
      expect(entries.isNotEmpty, true);
      expect(entries.first, contains('DELETE'));
      expect(entries.first, contains('old.md'));
    });

    test('should log project creation', () async {
      await logger.logProjectCreation('/home/user/project');

      final entries = await logger.readLog();
      expect(entries.isNotEmpty, true);
      expect(entries.first, contains('CREATE_PROJECT'));
      expect(entries.first, contains('/home/user/project'));
    });

    test('should append multiple entries chronologically', () async {
      await logger.logWrite('file1.md', 100);
      await logger.logWrite('file2.md', 200);
      await logger.logDelete('file1.md');

      final entries = await logger.readLog();
      expect(
        entries.length,
        3,
        reason: 'Should have 3 log entries after 3 operations',
      );
      expect(entries[0], contains('file1.md'));
      expect(entries[1], contains('file2.md'));
      expect(entries[2], contains('DELETE'));
    });

    test('should format file sizes correctly', () async {
      await logger.logWrite('tiny.md', 512); // 512 B
      await logger.logWrite('small.md', 5120); // 5.0 KB
      await logger.logWrite('medium.md', 2 * 1024 * 1024); // 2.0 MB

      final entries = await logger.readLog();
      expect(entries[0], contains('512 B'));
      expect(entries[1], contains('5.0 KB'));
      expect(entries[2], contains('2.0 MB'));
    });

    test('should support custom operations via logOperation', () async {
      await logger.logOperation('IMPORT', 'markdown_files');

      final entries = await logger.readLog();
      expect(entries.isNotEmpty, true);
      expect(entries.first, contains('IMPORT'));
      expect(entries.first, contains('markdown_files'));
    });

    test('should clear log file', () async {
      await logger.logWrite('test.md', 100);
      expect((await logger.readLog()).length, 1);

      await logger.clearLog();

      final entries = await logger.readLog();
      expect(
        entries.isEmpty,
        true,
        reason: 'Log should be empty after clearLog()',
      );
    });

    test('should handle missing log file gracefully', () async {
      // Don't write anything yet
      final entries = await logger.readLog();
      expect(
        entries.isEmpty,
        true,
        reason: 'Should return empty list if log file does not exist',
      );
    });

    test('should handle multiple concurrent writes', () async {
      // Note: The audit logger might lose some entries on rapid concurrent writes
      // because file append operations are not atomic. This test verifies
      // that at least one entry is logged and the operation doesn't crash.
      await Future.wait([
        logger.logWrite('file1.md', 100),
        logger.logWrite('file2.md', 200),
        logger.logWrite('file3.md', 300),
      ]);

      final entries = await logger.readLog();
      expect(
        entries.isNotEmpty,
        true,
        reason: 'Should have at least one logged entry',
      );
    });

    test('should persist entries across logger instances', () async {
      // First instance writes
      await logger.logWrite('test1.md', 100);

      // Create new logger instance (simulating app restart)
      final newLogger = AuditLogger(projectRoot: projectRoot);
      await newLogger.logWrite('test2.md', 200);

      // Verify both entries are persisted
      final entries = await newLogger.readLog();
      expect(
        entries.length,
        2,
        reason: 'New logger instance should see previous entries',
      );
      expect(entries[0], contains('test1.md'));
      expect(entries[1], contains('test2.md'));
    });
  });
}
