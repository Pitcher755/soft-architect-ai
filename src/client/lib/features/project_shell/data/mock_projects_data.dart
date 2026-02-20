// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_colors.dart';

/// Formats a relative date in Spanish
String _formatModified(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      return 'Hace ${diff.inMinutes}m';
    }
    return 'Hace ${diff.inHours}h';
  } else if (diff.inDays == 1) {
    return 'Ayer';
  } else if (diff.inDays < 7) {
    return 'Hace ${diff.inDays}d';
  }
  return '${dateTime.day}/${dateTime.month}';
}

/// Gets the phase color
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

/// Loads REAL projects from the filesystem
/// Searches in common project directories
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
      if (dir.existsSync()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is Directory) {
            final stat = entity.statSync();
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
    } on Exception catch (e) {
      // Ignorar errores de acceso a directorios
      debugPrint('⚠️ Error loading projects from $pathStr: $e');
    }
  }

  return projects;
}

/// Loads projects: REAL (filesystem) + MOCK (Educational Guide)
/// Returns combined list of Map with projects ready to display
Future<List<Map<String, dynamic>>> getMockProjectsData() async {
  final allProjects = <Map<String, dynamic>>[];

  // 1. Cargar proyectos reales del filesystem
  try {
    final realProjects = await _loadRealProjects();
    allProjects.addAll(realProjects);
    debugPrint('✅ Loaded ${realProjects.length} real projects');
  } on Exception catch (e) {
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
