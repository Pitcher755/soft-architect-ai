import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_colors.dart';

/// Formatea una fecha relativa en español
String _formatModified(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inDays == 0) {
    if (diff.inHours == 0) return 'Hace ${diff.inMinutes}m';
    return 'Hace ${diff.inHours}h';
  } else if (diff.inDays == 1) {
    return 'Ayer';
  } else if (diff.inDays < 7) {
    return 'Hace ${diff.inDays}d';
  }
  return '${dateTime.day}/${dateTime.month}';
}

/// Obtiene el color de fase
Color _getPhaseColor(String phase) {
  switch (phase.toLowerCase()) {
    case 'contexto':
      return const Color(0xFFFCD34D);
    case 'arquitectura':
      return const Color(0xFF60A5FA);
    case 'implementación':
      return const Color(0xFF10B981);
    case 'calidad':
      return const Color(0xFFEC4899);
    case 'documentación':
      return AppColors.info;
    default:
      return AppColors.primary;
  }
}

/// Carga proyectos REALES del sistema de archivos
/// Se buscan en directorios comunes de proyectos
Future<List<Map<String, dynamic>>> _loadRealProjects() async {
  final projects = <Map<String, dynamic>>[];
  final homeDir = Directory.current.path;
  final commonPaths = [
    p.join(homeDir, 'projects'),
    p.join(homeDir, 'SoftArchitect'),
    p.join(homeDir, 'Proyectos'),
  ];

  for (final pathStr in commonPaths) {
    try {
      final dir = Directory(pathStr);
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is Directory) {
            final stat = await entity.stat();
            final name = p.basename(entity.path);
            projects.add({
              'id': name,
              'name': name,
              'icon': Icons.folder_open,
              'iconColor': AppColors.primary,
              'phase': 'Contexto',
              'phaseColor': _getPhaseColor('Contexto'),
              'path': entity.path,
              'modified': _formatModified(stat.modified),
            });
          }
        }
      }
    } catch (e) {
      // Ignorar errores de acceso a directorios
      debugPrint('⚠️ Error loading projects from $pathStr: $e');
    }
  }

  return projects;
}

/// Carga proyectos: REALES (filesystem) + MOCK (Guía educativa)
/// Retorna lista combinada de Map con proyectos listos para mostrar
Future<List<Map<String, dynamic>>> getMockProjectsData() async {
  final allProjects = <Map<String, dynamic>>[];

  // 1. Cargar proyectos reales del filesystem
  try {
    final realProjects = await _loadRealProjects();
    allProjects.addAll(realProjects);
    debugPrint('✅ Loaded ${realProjects.length} real projects');
  } catch (e) {
    debugPrint('❌ Error loading real projects: $e');
  }

  // 2. Agregar el proyecto mock/guía (siempre incluido)
  allProjects.add({
    'id': 'softarchitect-guide',
    'name': 'Guía SoftArchitect',
    'icon': Icons.menu_book_rounded,
    'iconColor': AppColors.primary,
    'phase': 'Documentación',
    'phaseColor': AppColors.info,
    'path': 'mock://softarchitect-guide', // Ruta virtual para hybrid system
    'modified': 'Siempre disponible',
  });

  return allProjects;
}
