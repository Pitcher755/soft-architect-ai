// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:io';
import 'package:path/path.dart' as p;

import '../../domain/entities/file_node.dart';

/// Servicio de Infraestructura especializado en lectura jerárquica.
///
/// Responsabilidad: Convertir la estructura física del disco (dart:io)
/// en entidades de dominio (FileNode) para la UI.
class FileTreeService {
  /// Construye el árbol completo a partir de una ruta raíz.
  static Future<FileNode> buildTreeFromPath(String rootPath) async {
    final rootDir = Directory(rootPath);

    // 1. Validación defensiva
    if (!await rootDir.exists()) {
      return FileNode(
        id: 'error_root',
        name: 'Ruta no encontrada',
        path: rootPath,
        isDirectory: true,
        children: [],
      );
    }

    final rootName = p.basename(rootPath);

    // 2. Recursión
    final node = await _buildNodeRecursive(rootDir);

    // 3. Retornamos la raíz con el nombre formateado (Mayúsculas para el proyecto)
    return FileNode(
      id: node.id,
      name: rootName.toUpperCase(),
      path: node.path,
      isDirectory: node.isDirectory,
      children: node.children,
    );
  }

  static Future<FileNode> _buildNodeRecursive(FileSystemEntity entity) async {
    final stat = await entity.stat();
    final isDirectory = stat.type == FileSystemEntityType.directory;
    final name = p.basename(entity.path);
    final children = <FileNode>[];

    if (isDirectory) {
      try {
        final dir = Directory(entity.path);
        final entities = await dir.list().toList();

        // Ordenamiento: Carpetas primero, luego archivos (alfabéticamente)
        entities.sort((a, b) {
          final aIsDir = FileSystemEntity.isDirectorySync(a.path);
          final bIsDir = FileSystemEntity.isDirectorySync(b.path);
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return p
              .basename(a.path)
              .toLowerCase()
              .compareTo(p.basename(b.path).toLowerCase());
        });

        for (final child in entities) {
          // Filtrar archivos ocultos (.git, .DS_Store, etc.)
          if (!p.basename(child.path).startsWith('.')) {
            children.add(await _buildNodeRecursive(child));
          }
        }
      } catch (e) {
        // Ignorar errores de acceso
      }
    }

    return FileNode(
      id: entity.path, // ID único = ruta absoluta
      name: name,
      path: entity.path,
      isDirectory: isDirectory,
      children: children,
    );
  }
}
