import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/models/project_phase.dart';
import 'package:softarchitect_ai/features/project_shell/domain/services/project_phase_service.dart';

void main() {
  group('ProjectPhaseService', () {
    Project buildProject(String path, {String id = 'proj-1'}) {
      return Project(
        id: id,
        name: 'Test',
        path: path,
        createdAt: DateTime(2026, 1, 1),
        lastOpened: DateTime(2026, 1, 2),
      );
    }

    test('returns quickStart for guide project', () {
      final project = buildProject('/tmp/x', id: 'guide-softarchitect-01');
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.quickStart);
      expect(ProjectPhaseService.calculateProgress(project, 0), 1);
      expect(ProjectPhaseService.getCurrentPhaseName(project, 0), 'Quick start');
      expect(ProjectPhaseService.getDocumentsInCurrentPhase(project, 0), 0);
      expect(ProjectPhaseService.isGuideProject(project), isTrue);
    });

    test('returns root when directory does not exist', () {
      final project = buildProject('/tmp/does-not-exist-xyz-123');
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.root);
    });

    test('detects context phase', () async {
      final dir = await Directory.systemTemp.createTemp('phase-context-');
      addTearDown(() => dir.delete(recursive: true));
      Directory('${dir.path}/context').createSync(recursive: true);

      final project = buildProject(dir.path);
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.context);
    });

    test('detects requirements phase', () async {
      final dir = await Directory.systemTemp.createTemp('phase-req-');
      addTearDown(() => dir.delete(recursive: true));
      Directory('${dir.path}/doc/20-REQUIREMENTS_AND_SPEC').createSync(recursive: true);

      final project = buildProject(dir.path);
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.requirements);
    });

    test('detects architecture phase', () async {
      final dir = await Directory.systemTemp.createTemp('phase-arch-');
      addTearDown(() => dir.delete(recursive: true));
      Directory('${dir.path}/src').createSync(recursive: true);

      final project = buildProject(dir.path);
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.architecture);
    });

    test('detects planning phase', () async {
      final dir = await Directory.systemTemp.createTemp('phase-plan-');
      addTearDown(() => dir.delete(recursive: true));
      Directory('${dir.path}/infrastructure').createSync(recursive: true);

      final project = buildProject(dir.path);
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.planning);
    });

    test('detects meta phase when CI exists', () async {
      final dir = await Directory.systemTemp.createTemp('phase-meta-');
      addTearDown(() => dir.delete(recursive: true));
      Directory('${dir.path}/.github').createSync(recursive: true);

      final project = buildProject(dir.path);
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.meta);
    });

    test('calculates bounded progress', () {
      final project = buildProject('/tmp/proj');
      expect(ProjectPhaseService.calculateProgress(project, 0), 0);
      expect(ProjectPhaseService.calculateProgress(project, ProjectPhase.totalFileCount ~/ 2),
          greaterThan(0));
      expect(ProjectPhaseService.calculateProgress(project, ProjectPhase.totalFileCount * 2), 1);
    });

    test('resolves current phase name and docs in phase', () {
      final project = buildProject('/tmp/proj');
      final name = ProjectPhaseService.getCurrentPhaseName(project, 2);
      final inCurrent = ProjectPhaseService.getDocumentsInCurrentPhase(project, 2);
      expect(name, ProjectPhase.root.name);
      expect(inCurrent, 2);
    });
  });
}
