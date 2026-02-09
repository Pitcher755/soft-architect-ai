// lib/features/project_shell/presentation/providers/project_providers.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/project.dart';

// ╔════════════════════════════════════════════════╗
// ║      PROJECTS NOTIFIER (STATE MANAGEMENT)      ║
// ╚════════════════════════════════════════════════╝

/// Notifier para gestionar la lista de proyectos
/// - Carga proyectos desde SharedPreferences (persistencia)
/// - Incluye siempre la guía mock de SoftArchitect
/// - Permite agregar nuevos proyectos dinámicamente
class ProjectsNotifier extends Notifier<List<Project>> {
  static const String _storageKey = 'user_projects_v2';

  @override
  List<Project> build() {
    // Iniciar carga asíncrona
    _loadProjects();
    return [];
  }

  /// Carga proyectos desde SharedPreferences + Guía Mock
  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cargar proyectos reales (guardados en prefs)
    final savedJson = prefs.getStringList(_storageKey) ?? [];
    final userProjects = <Project>[];

    for (final str in savedJson) {
      try {
        final Map<String, dynamic> json = jsonDecode(str);
        userProjects.add(
          Project(
            id: json['id'] as String,
            name: json['name'] as String,
            path: json['path'] as String,
            createdAt: DateTime.parse(json['createdAt'] as String),
            lastOpened: json['lastOpened'] != null
                ? DateTime.parse(json['lastOpened'] as String)
                : null,
          ),
        );
      } catch (e) {
        debugPrint('❌ Error loading project: $e');
      }
    }

    // 2. Cargar la guía mock (siempre presente)
    final guideProject = Project(
      id: 'guide-softarchitect-01',
      name: 'Guía SoftArchitect',
      path: 'mock://softarchitect-guide',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastOpened: DateTime.now(),
    );

    // 3. Combinar y ordenar (más reciente primero)
    final all = [guideProject, ...userProjects];
    all.sort((a, b) {
      final aTime = a.lastOpened ?? a.createdAt;
      final bTime = b.lastOpened ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    state = all;
  }

  /// Agrega un nuevo proyecto a la lista y lo persiste
  Future<void> addProject(String name, String path, String description) async {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      path: path,
      createdAt: DateTime.now(),
      lastOpened: DateTime.now(),
    );

    // Actualizar estado (UI optimista)
    state = [newProject, ...state];

    // Persistir cambios
    await _saveToPrefs();
  }

  /// Guarda los proyectos reales en SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Solo guardamos proyectos que NO sean mock
    final realProjects = state
        .where((p) => !p.path.startsWith('mock://'))
        .toList();

    final encoded = realProjects
        .map(
          (p) => jsonEncode({
            'id': p.id,
            'name': p.name,
            'path': p.path,
            'createdAt': p.createdAt.toIso8601String(),
            'lastOpened': p.lastOpened?.toIso8601String(),
          }),
        )
        .toList();

    await prefs.setStringList(_storageKey, encoded);
    debugPrint('✅ Proyectos guardados: ${realProjects.length}');
  }
}

// ╔════════════════════════════════════════════════╗
// ║              PROVIDER DEFINITION                ║
// ╚════════════════════════════════════════════════╝

/// Provider principal para la lista de proyectos
/// Usage: ref.watch(projectsProvider)
final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  ProjectsNotifier.new,
);
