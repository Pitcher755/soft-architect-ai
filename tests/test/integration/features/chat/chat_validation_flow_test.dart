import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chat Validation - FileSystem Integration', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('chat_validation_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('document save creates correct path structure', () async {
      // Arrange
      final projectPath = tempDir.path;
      const relativePath = '10-CONTEXT/PROJECT_MANIFESTO.md';
      const content = '# Project Manifesto\nThis is a test document.';
      final fullPath = '$projectPath/$relativePath';

      // Act: Create directories and save file (simulating FileSystemService.saveDocument)
      final file = File(fullPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content, flush: true);

      // Assert
      expect(await file.exists(), true);
      final savedContent = await file.readAsString();
      expect(savedContent, content);
    });

    test('multiple document saves create directory hierarchy', () async {
      // Arrange
      final projectPath = tempDir.path;
      final documents = [
        ('10-CONTEXT/PROJECT_MANIFESTO.md', '# Manifesto'),
        ('10-CONTEXT/VISION_PROMISE.md', '# Vision'),
        ('20-REQUIREMENTS_AND_SPEC/FUNCTIONAL_REQUIREMENTS.md', '# Functional'),
        ('30-ARCHITECTURE/DATABASE_SCHEMA.md', '# Database'),
      ];

      // Act
      for (final (path, fileContent) in documents) {
        final file = File('$projectPath/$path');
        await file.parent.create(recursive: true);
        await file.writeAsString(fileContent, flush: true);
      }

      // Assert
      for (final (path, _) in documents) {
        final file = File('$projectPath/$path');
        expect(await file.exists(), true, reason: 'File should exist at $path');
      }
    });

    test('document overwrite replaces existing content', () async {
      // Arrange
      final projectPath = tempDir.path;
      const relativePath = '10-CONTEXT/TEST.md';
      const originalContent = 'Original content';
      const updatedContent = 'Updated content';
      final fullPath = '$projectPath/$relativePath';

      // Act: Save original
      final file = File(fullPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(originalContent, flush: true);

      // Act: Overwrite
      await file.writeAsString(updatedContent, flush: true);

      // Assert
      final finalContent = await file.readAsString();
      expect(finalContent, updatedContent);
    });

    test('deeply nested directories are created correctly', () async {
      // Arrange
      final projectPath = tempDir.path;
      const deepPath = '30-ARCHITECTURE/database/schemas/users.md';
      const content = '# Database Schemas';
      final fullPath = '$projectPath/$deepPath';

      // Act
      final file = File(fullPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content, flush: true);

      // Assert
      expect(await file.exists(), true);
      expect(
        await Directory('$projectPath/30-ARCHITECTURE').exists(),
        true,
      );
      expect(
        await Directory('$projectPath/30-ARCHITECTURE/database').exists(),
        true,
      );
      expect(
        await Directory(
          '$projectPath/30-ARCHITECTURE/database/schemas',
        ).exists(),
        true,
      );
    });

    test('file list can be retrieved from directory', () async {
      // Arrange
      final projectPath = tempDir.path;
      final documents = [
        '10-CONTEXT/PROJECT_MANIFESTO.md',
        '10-CONTEXT/VISION_PROMISE.md',
        '10-CONTEXT/USER_JOURNEY.md',
      ];

      // Act: Create files
      for (final path in documents) {
        final file = File('$projectPath/$path');
        await file.parent.create(recursive: true);
        await file.writeAsString('Content', flush: true);
      }

      // Act: List files
      final contextDir = Directory('$projectPath/10-CONTEXT');
      final files =
          contextDir.listSync(recursive: false).whereType<File>().toList();

      // Assert
      expect(files.length, 3);
      expect(
        files.map((f) => f.path.split('/').last),
        containsAll(['PROJECT_MANIFESTO.md', 'VISION_PROMISE.md', 'USER_JOURNEY.md']),
      );
    });

    test('file content can be read back after save', () async {
      // Arrange
      final projectPath = tempDir.path;
      const relativePath = '10-CONTEXT/PROJECT_MANIFESTO.md';
      const expectedContent = '''# Project Manifesto

## Vision
Build amazing products.

## Values
- Quality
- Innovation
- Collaboration
''';

      // Act
      final fullPath = '$projectPath/$relativePath';
      final file = File(fullPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(expectedContent, flush: true);

      // Act: Read back
      final readContent = await file.readAsString();

      // Assert
      expect(readContent, expectedContent);
      expect(readContent.contains('Project Manifesto'), true);
      expect(readContent.contains('Vision'), true);
    });

    test('special characters in content are preserved', () async {
      // Arrange
      final projectPath = tempDir.path;
      const relativePath = '10-CONTEXT/SPECIAL_CHARS.md';
      const specialContent = '''# Test with special chars

## Español
- Criterio ✅ Completo
- Error ❌ Pendiente

## Symbols
- Alert: ⚠️
- Code: `final x = 1;`
- Emoji: 🚀 🎯 📊

## Unicode
- Greek: α β γ δ
- Math: ∑ ∫ ∞
''';

      // Act
      final fullPath = '$projectPath/$relativePath';
      final file = File(fullPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(specialContent, flush: true);

      // Act: Read back
      final readContent = await file.readAsString();

      // Assert
      expect(readContent, specialContent);
      expect(readContent.contains('Criterio ✅'), true);
      expect(readContent.contains('α β γ δ'), true);
    });
  });
}
