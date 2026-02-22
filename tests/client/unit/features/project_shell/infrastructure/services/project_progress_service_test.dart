import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:softarchitect_ai/features/project_shell/domain/entities/project_progress.dart';
import 'package:softarchitect_ai/features/project_shell/infrastructure/services/project_progress_service.dart';

void main() {
  group('ProjectProgress Entity', () {
    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'documentosCreados': 10,
        'faseActual': 'Fase 1: Contexto',
        'porcentajeCompletado': 31.25,
        'lastUpdated': '2026-02-20T12:30:00.000Z',
      };

      final progress = ProjectProgress.fromJson(json);

      expect(progress.documentosCreados, 10);
      expect(progress.faseActual, 'Fase 1: Contexto');
      expect(progress.porcentajeCompletado, 31.25);
      expect(progress.lastUpdated, DateTime.parse('2026-02-20T12:30:00.000Z'));
    });

    test('fromJson should use defaults for missing fields', () {
      final json = <String, dynamic>{};

      final progress = ProjectProgress.fromJson(json);

      expect(progress.documentosCreados, 0);
      expect(progress.faseActual, 'Fase 0: Preparación');
      expect(progress.porcentajeCompletado, 0.0);
      expect(progress.lastUpdated, isA<DateTime>());
    });

    test('toJson should produce valid JSON', () {
      final progress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.parse('2026-02-20T10:00:00.000Z'),
      );

      final json = progress.toJson();

      expect(json['documentosCreados'], 5);
      expect(json['faseActual'], 'Fase 1: Contexto');
      expect(json['porcentajeCompletado'], 15.6);
      expect(json['lastUpdated'], '2026-02-20T10:00:00.000Z');
    });

    test('copyWith should create new instance with updated values', () {
      final original = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.parse('2026-02-20T10:00:00.000Z'),
      );

      final updated = original.copyWith(
        documentosCreados: 10,
        porcentajeCompletado: 31.25,
      );

      expect(updated.documentosCreados, 10);
      expect(updated.faseActual, 'Fase 1: Contexto'); // No cambió
      expect(updated.porcentajeCompletado, 31.25);
      expect(updated.lastUpdated, original.lastUpdated); // No cambió
    });

    test('equality should work correctly', () {
      final progress1 = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.parse('2026-02-20T10:00:00.000Z'),
      );

      final progress2 = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.parse('2026-02-20T10:00:00.000Z'),
      );

      final progress3 = ProjectProgress(
        documentosCreados: 10,
        faseActual: 'Fase 2: Requisitos',
        porcentajeCompletado: 31.25,
        lastUpdated: DateTime.parse('2026-02-20T11:00:00.000Z'),
      );

      expect(progress1, equals(progress2));
      expect(progress1, isNot(equals(progress3)));
      expect(progress1.hashCode, equals(progress2.hashCode));
    });
  });

  group('ProjectProgressService', () {
    late Directory tempDir;
    late String projectRoot;

    setUp(() async {
      // Crear directorio temporal para cada test
      tempDir = await Directory.systemTemp.createTemp('progress_test_');
      projectRoot = tempDir.path;
    });

    tearDown(() async {
      // Limpiar después de cada test
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('calculateProgress should count .md files in context/', () async {
      // Crear estructura de directorios
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Crear archivos .md
      await File(
        p.join(contextDir.path, 'documento1.md'),
      ).writeAsString('# Doc 1');
      await File(
        p.join(contextDir.path, 'documento2.md'),
      ).writeAsString('# Doc 2');
      await File(
        p.join(contextDir.path, 'documento3.md'),
      ).writeAsString('# Doc 3');

      // Calcular progreso
      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      expect(progress.documentosCreados, 3);
      expect(progress.faseActual, isNotEmpty);
      expect(progress.porcentajeCompletado, greaterThanOrEqualTo(0));
      expect(progress.porcentajeCompletado, lessThanOrEqualTo(100));
    });

    test('calculateProgress should exclude README.md', () async {
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Crear archivos .md
      await File(
        p.join(contextDir.path, 'documento1.md'),
      ).writeAsString('# Doc 1');
      await File(
        p.join(contextDir.path, 'README.md'),
      ).writeAsString('# README');
      await File(
        p.join(contextDir.path, 'readme.md'),
      ).writeAsString('# readme');

      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      // Solo debe contar documento1.md (excluyendo README*)
      expect(progress.documentosCreados, 1);
    });

    test('calculateProgress should exclude untitled.md', () async {
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Crear archivos .md
      await File(
        p.join(contextDir.path, 'documento1.md'),
      ).writeAsString('# Doc 1');
      await File(
        p.join(contextDir.path, 'untitled.md'),
      ).writeAsString('# Untitled');
      await File(
        p.join(contextDir.path, 'Untitled-1.md'),
      ).writeAsString('# Untitled 1');

      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      // Solo debe contar documento1.md
      expect(progress.documentosCreados, 1);
    });

    test('calculateProgress should return 0 for missing context/', () async {
      // No crear carpeta context/
      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      expect(progress.documentosCreados, 0);
      expect(progress.faseActual, 'Raíz'); // Primera fase con 0 documentos
      expect(progress.porcentajeCompletado, 0.0);
    });

    test('calculateProgress should scan recursively', () async {
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Crear archivos en diferentes niveles
      await File(p.join(contextDir.path, 'doc1.md')).writeAsString('# Doc 1');

      final subDir = Directory(p.join(contextDir.path, 'subdirectory'));
      await subDir.create();
      await File(p.join(subDir.path, 'doc2.md')).writeAsString('# Doc 2');

      final deepDir = Directory(p.join(subDir.path, 'deep'));
      await deepDir.create();
      await File(p.join(deepDir.path, 'doc3.md')).writeAsString('# Doc 3');

      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      // Debe contar los 3 archivos recursivamente
      expect(progress.documentosCreados, 3);
    });

    test('saveProgress should create .softarchitect folder', () async {
      final progress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await ProjectProgressService.saveProgress(
        projectRoot: projectRoot,
        progress: progress,
      );

      final progressDir = Directory(p.join(projectRoot, '.softarchitect'));
      expect(await progressDir.exists(), isTrue);
    });

    test('saveProgress should write valid JSON', () async {
      final progress = ProjectProgress(
        documentosCreados: 10,
        faseActual: 'Fase 2: Requisitos',
        porcentajeCompletado: 31.25,
        lastUpdated: DateTime.parse('2026-02-20T12:00:00.000Z'),
      );

      await ProjectProgressService.saveProgress(
        projectRoot: projectRoot,
        progress: progress,
      );

      final statusFile = File(
        p.join(projectRoot, '.softarchitect', 'status.json'),
      );
      expect(await statusFile.exists(), isTrue);

      final content = await statusFile.readAsString();
      expect(content, contains('"documentosCreados": 10'));
      expect(content, contains('"faseActual": "Fase 2: Requisitos"'));
      expect(content, contains('"porcentajeCompletado": 31.25'));
    });

    test('loadProgress should return null for missing file', () async {
      final result = await ProjectProgressService.loadProgress(projectRoot);
      expect(result, isNull);
    });

    test('loadProgress should parse existing JSON', () async {
      // Primero guardar un progreso
      final originalProgress = ProjectProgress(
        documentosCreados: 8,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 25.0,
        lastUpdated: DateTime.parse('2026-02-20T10:00:00.000Z'),
      );

      await ProjectProgressService.saveProgress(
        projectRoot: projectRoot,
        progress: originalProgress,
      );

      // Ahora cargar
      final loadedProgress = await ProjectProgressService.loadProgress(
        projectRoot,
      );

      expect(loadedProgress, isNotNull);
      expect(loadedProgress!.documentosCreados, 8);
      expect(loadedProgress.faseActual, 'Fase 1: Contexto');
      expect(loadedProgress.porcentajeCompletado, 25.0);
    });

    test('loadProgress should handle malformed JSON gracefully', () async {
      // Crear archivo con JSON malformado
      final progressDir = Directory(p.join(projectRoot, '.softarchitect'));
      await progressDir.create(recursive: true);

      final statusFile = File(p.join(progressDir.path, 'status.json'));
      await statusFile.writeAsString('{ "invalid": json }');

      // Debe retornar null en lugar de lanzar excepción
      final result = await ProjectProgressService.loadProgress(projectRoot);
      expect(result, isNull);
    });

    test(
      'updateAfterDocumentSave should calculate and persist progress',
      () async {
        // Crear estructura con documentos
        final contextDir = Directory(p.join(projectRoot, 'context'));
        await contextDir.create(recursive: true);

        await File(p.join(contextDir.path, 'doc1.md')).writeAsString('# Doc 1');
        await File(p.join(contextDir.path, 'doc2.md')).writeAsString('# Doc 2');

        // Ejecutar updateAfterDocumentSave
        final progress = await ProjectProgressService.updateAfterDocumentSave(
          projectRoot,
        );

        // Verificar que calculó correctamente
        expect(progress.documentosCreados, 2);

        // Verificar que persistió
        final statusFile = File(
          p.join(projectRoot, '.softarchitect', 'status.json'),
        );
        expect(await statusFile.exists(), isTrue);

        // Verificar que se puede cargar
        final loadedProgress = await ProjectProgressService.loadProgress(
          projectRoot,
        );
        expect(loadedProgress, isNotNull);
        expect(loadedProgress!.documentosCreados, 2);
      },
    );

    test('phase determination should be consistent', () async {
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Crear 1 documento (debería estar en Fase 0 o Fase 1)
      await File(p.join(contextDir.path, 'doc1.md')).writeAsString('# Doc 1');
      var progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );
      final phase1 = progress.faseActual;

      // Crear más documentos
      await File(p.join(contextDir.path, 'doc2.md')).writeAsString('# Doc 2');
      await File(p.join(contextDir.path, 'doc3.md')).writeAsString('# Doc 3');
      progress = await ProjectProgressService.calculateProgress(projectRoot);
      final phase2 = progress.faseActual;

      // La fase debe ser consistente (no vacía)
      expect(phase1, isNotEmpty);
      expect(phase2, isNotEmpty);
      // Con más documentos, puede avanzar o mantener fase
      expect(phase2, isA<String>());
    });

    test('percentage calculation should be 0-100 range', () async {
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Test con diferentes cantidades de documentos
      for (var i = 0; i < 5; i++) {
        await File(
          p.join(contextDir.path, 'doc$i.md'),
        ).writeAsString('# Doc $i');
        final progress = await ProjectProgressService.calculateProgress(
          projectRoot,
        );

        expect(progress.porcentajeCompletado, greaterThanOrEqualTo(0.0));
        expect(progress.porcentajeCompletado, lessThanOrEqualTo(100.0));
      }
    });

    test('should ignore non-.md files', () async {
      final contextDir = Directory(p.join(projectRoot, 'context'));
      await contextDir.create(recursive: true);

      // Crear archivos de diferentes tipos
      await File(p.join(contextDir.path, 'doc1.md')).writeAsString('# Doc 1');
      await File(
        p.join(contextDir.path, 'doc2.txt'),
      ).writeAsString('Text file');
      await File(p.join(contextDir.path, 'doc3.pdf')).writeAsBytes([1, 2, 3]);
      await File(p.join(contextDir.path, 'doc4.docx')).writeAsBytes([4, 5, 6]);

      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      // Solo debe contar doc1.md
      expect(progress.documentosCreados, 1);
    });

    test('should handle empty project gracefully', () async {
      // Proyecto completamente vacío (sin carpeta context/)
      final progress = await ProjectProgressService.calculateProgress(
        projectRoot,
      );

      expect(progress.documentosCreados, 0);
      expect(progress.faseActual, 'Raíz'); // Primera fase con 0 documentos
      expect(progress.porcentajeCompletado, 0.0);
      expect(progress.lastUpdated, isA<DateTime>());
    });

    test('should update timestamp on each save', () async {
      final progress1 = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await ProjectProgressService.saveProgress(
        projectRoot: projectRoot,
        progress: progress1,
      );

      // Esperar un momento
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final progress2 = ProjectProgress(
        documentosCreados: 6,
        faseActual: 'Fase 1: Contexto',
        porcentajeCompletado: 18.75,
        lastUpdated: DateTime.now(),
      );

      await ProjectProgressService.saveProgress(
        projectRoot: projectRoot,
        progress: progress2,
      );

      // Cargar y verificar que el timestamp se actualizó
      final loaded = await ProjectProgressService.loadProgress(projectRoot);
      expect(loaded, isNotNull);
      expect(loaded!.lastUpdated.isAfter(progress1.lastUpdated), isTrue);
    });
  });
}
