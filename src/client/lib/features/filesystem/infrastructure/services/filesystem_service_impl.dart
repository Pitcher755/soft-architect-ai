// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/exceptions/filesystem_exceptions.dart';
import '../../domain/repositories/filesystem_repository.dart';
import '../security/path_validator.dart';

/// Concrete implementation of [FileSystemRepository] using dart:io.
///
/// **Security:**
/// - All paths validated before I/O
/// - Errors wrapped in domain exceptions
/// - Idempotent operations for safety
class FileSystemServiceImpl implements FileSystemRepository {
  FileSystemServiceImpl({required this.projectRoot}) {
    _validator = PathValidator(projectRoot: projectRoot);
  }
  final String projectRoot;
  late final PathValidator _validator;

  /// Standard directory structure for new projects.
  static const List<String> _standardDirs = [
    'context/10-CONTEXT',
    'context/20-REQUIREMENTS',
    'context/30-ARCHITECTURE',
    'context/35-UX_UI',
    'context/40-PLANNING',
  ];

  @override
  Future<void> initProjectStructure(String projectRoot) async {
    try {
      // Create root directory
      final rootDir = Directory(projectRoot);
      if (!await rootDir.exists()) {
        await rootDir.create(recursive: true);
      }

      // Create standard subdirectories
      for (final dirPath in _standardDirs) {
        final fullPath = p.join(projectRoot, dirPath);
        final dir = Directory(fullPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        // Create .gitkeep to preserve empty dirs in git
        final gitkeep = File(p.join(fullPath, '.gitkeep'));
        if (!await gitkeep.exists()) {
          await gitkeep.writeAsString('');
        }
      }

      // Create context/README.md
      final contextReadme = File(p.join(projectRoot, 'context/README.md'));
      if (!await contextReadme.exists()) {
        await contextReadme.writeAsString(_getContextReadmeTemplate());
      }

      // Create root README.md
      final rootReadme = File(p.join(projectRoot, 'README.md'));
      if (!await rootReadme.exists()) {
        await rootReadme.writeAsString(_getRootReadmeTemplate());
      }
    } on FileSystemException catch (e) {
      if (e.message.contains('Permission denied')) {
        throw PermissionDeniedException(projectRoot);
      } else if (e.message.contains('No space left')) {
        throw DiskSpaceException(projectRoot, 0);
      }
      rethrow;
    }
  }

  @override
  Future<File> saveFile({
    required String relativePath,
    required String content,
    bool createDirs = true,
  }) async {
    // Security: Validate path first
    final absolutePath = _validator.validate(relativePath);

    try {
      final file = File(absolutePath);

      // Create parent directories if requested
      if (createDirs) {
        final parentDir = file.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
      }

      // Write file (UTF-8 encoding)
      await file.writeAsString(content);

      return file;
    } on FileSystemException catch (e) {
      if (e.message.contains('Permission denied')) {
        throw PermissionDeniedException(absolutePath);
      } else if (e.message.contains('No space left')) {
        throw DiskSpaceException(absolutePath, content.length);
      }
      rethrow;
    }
  }

  @override
  Future<String> readFile(String relativePath) async {
    final absolutePath = _validator.validate(relativePath);
    final file = File(absolutePath);

    if (!await file.exists()) {
      throw FileNotFoundException(absolutePath);
    }

    try {
      return await file.readAsString();
    } on FileSystemException catch (e) {
      if (e.message.contains('Permission denied')) {
        throw PermissionDeniedException(absolutePath);
      }
      rethrow;
    }
  }

  @override
  Future<bool> fileExists(String relativePath) async {
    final absolutePath = _validator.validate(relativePath);
    return File(absolutePath).exists();
  }

  @override
  Future<List<String>> listFiles({
    required String relativePath,
    List<String>? extensions,
  }) async {
    final absolutePath = _validator.validate(relativePath);
    final dir = Directory(absolutePath);

    if (!await dir.exists()) {
      return [];
    }

    final files = <String>[];
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        // Filter by extensions if provided
        if (extensions != null) {
          final ext = p.extension(entity.path);
          if (!extensions.contains(ext)) {
            continue;
          }
        }

        // Convert to relative path
        final relPath = _validator.getRelativePath(entity.path);
        if (relPath != null) {
          files.add(relPath);
        }
      }
    }

    return files;
  }

  @override
  Future<void> deleteFile(String relativePath) async {
    final absolutePath = _validator.validate(relativePath);
    final file = File(absolutePath);

    if (!await file.exists()) {
      throw FileNotFoundException(absolutePath);
    }

    try {
      await file.delete();
    } on FileSystemException catch (e) {
      if (e.message.contains('Permission denied')) {
        throw PermissionDeniedException(absolutePath);
      }
      rethrow;
    }
  }

  // Template generators

  String _getContextReadmeTemplate() => '''# Documentación del Proyecto

## Estructura

- **10-CONTEXT**: Contexto de negocio y alcance del proyecto
- **20-REQUIREMENTS**: Requisitos funcionales y no funcionales
- **30-ARCHITECTURE**: Decisiones de arquitectura y ADRs
- **35-UX_UI**: Diseño y experiencia de usuario
- **40-PLANNING**: Planificación, roadmap y tracking

---

> Generado automáticamente por SoftArchitect AI
''';

  String _getRootReadmeTemplate() => '''# Nuevo Proyecto

## Descripción

_Proyecto creado con SoftArchitect AI_

## Estructura de Documentación

Ver [context/README.md](context/README.md) para la organización completa.

---

> Generado automáticamente
''';
}
