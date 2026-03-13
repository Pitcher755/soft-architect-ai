import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/constants/project_structure_constants.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/models/project_phase.dart';
import 'package:softarchitect_ai/features/project_shell/domain/services/project_phase_service.dart';

class FakeProjectFileScanner {
  FakeProjectFileScanner(this.files);

  final List<String> files;
  int calls = 0;
  String? lastPath;

  List<String> getProjectFiles(String projectPath) {
    calls++;
    lastPath = projectPath;
    return files;
  }
}

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
      expect(
        ProjectPhaseService.getProjectPhase(project),
        ProjectPhase.quickStart,
      );
      expect(ProjectPhaseService.calculateProgress(project, 0), 1);
      expect(
        ProjectPhaseService.getCurrentPhaseName(project, 0),
        'Quick start',
      );
      expect(ProjectPhaseService.getDocumentsInCurrentPhase(project, 0), 0);
      expect(ProjectPhaseService.isGuideProject(project), isTrue);
    });

    test('returns root when directory does not exist', () {
      final project = buildProject('/tmp/does-not-exist-xyz-123');
      expect(ProjectPhaseService.getProjectPhase(project), ProjectPhase.root);
    });

    test('calculates phase 0 and 0 progress with empty file list', () {
      final result = ProjectPhaseService.calculateProgressFromFiles(const []);
      expect(result.currentPhase, 0);
      expect(result.docsCompleted, 0);
      expect(result.totalDocs, ProjectStructureConstants.totalExpectedDocs);
      expect(result.progress, 0);
    });

    test('fetches files from scanner and calculates progress', () {
      final scanner = FakeProjectFileScanner(const ['AGENTS.md', 'README.md']);
      final service = ProjectPhaseService(fileScanner: scanner.getProjectFiles);

      final result = service.analyzeProjectPath('/tmp/test_project');

      expect(scanner.calls, 1);
      expect(scanner.lastPath, '/tmp/test_project');
      expect(result.docsCompleted, 2);
      expect(result.currentPhase, 0);
      expect(result.progress, closeTo(2 / 24, 0.0001));
    });

    test('instance calculator computes deterministic doc N/24', () {
      final scanner = FakeProjectFileScanner(const []);
      final service = ProjectPhaseService(fileScanner: scanner.getProjectFiles);

      final result = service.calculateProgressForFiles(const [
        'AGENTS.md',
        'README.md',
        'context/10-CONTEXT/DOMAIN_LANGUAGE.md',
      ]);

      expect(result.docsCompleted, 3);
      expect(result.progress, closeTo(3 / 24, 0.0001));
      expect(result.currentPhase, 0);
    });

    test('calculates phase 1 when root and context docs are completed', () {
      final result = ProjectPhaseService.calculateProgressFromFiles(const [
        'AGENTS.md',
        'README.md',
        'context/10-CONTEXT/DOMAIN_LANGUAGE.md',
        'context/10-CONTEXT/PROJECT_MANIFESTO.md',
        'context/10-CONTEXT/USER_JOURNEY_MAP.md',
      ]);

      expect(result.currentPhase, 1);
      expect(result.docsCompleted, 5);
      expect(result.progress, closeTo(5 / 24, 0.0001));
    });

    test('counts optional root docs for Doc N/24 progress', () {
      final result = ProjectPhaseService.calculateProgressFromFiles(const [
        'AGENTS.md',
        'README.md',
        'RULES.md',
        'CONTRIBUTING.md',
      ]);

      expect(result.currentPhase, 0);
      expect(result.docsCompleted, 4);
      expect(result.progress, closeTo(4 / 24, 0.0001));
    });

    test('detects context phase from real filesystem', () async {
      final dir = await Directory.systemTemp.createTemp('phase-context-');
      addTearDown(() => dir.delete(recursive: true));
      File('${dir.path}/AGENTS.md').writeAsStringSync('# agents');
      File('${dir.path}/README.md').writeAsStringSync('# readme');
      Directory('${dir.path}/context/10-CONTEXT').createSync(recursive: true);
      File(
        '${dir.path}/context/10-CONTEXT/DOMAIN_LANGUAGE.md',
      ).writeAsStringSync('');
      File(
        '${dir.path}/context/10-CONTEXT/PROJECT_MANIFESTO.md',
      ).writeAsStringSync('');
      File(
        '${dir.path}/context/10-CONTEXT/USER_JOURNEY_MAP.md',
      ).writeAsStringSync('');

      final project = buildProject(dir.path);
      expect(
        ProjectPhaseService.getProjectPhase(project),
        ProjectPhase.context,
      );

      final snapshot = ProjectPhaseService.analyzeProject(dir.path);
      expect(snapshot.currentPhase, 1);
      expect(snapshot.docsCompleted, 5);
    });

    test('detects requirements phase with canonical context folders', () async {
      final dir = await Directory.systemTemp.createTemp('phase-req-');
      addTearDown(() => dir.delete(recursive: true));
      File('${dir.path}/AGENTS.md').writeAsStringSync('');
      File('${dir.path}/README.md').writeAsStringSync('');
      Directory('${dir.path}/context/10-CONTEXT').createSync(recursive: true);
      Directory(
        '${dir.path}/context/20-REQUIREMENTS',
      ).createSync(recursive: true);

      for (final file in const [
        'DOMAIN_LANGUAGE.md',
        'PROJECT_MANIFESTO.md',
        'USER_JOURNEY_MAP.md',
      ]) {
        File('${dir.path}/context/10-CONTEXT/$file').writeAsStringSync('');
      }

      for (final file in const [
        'COMPLIANCE_MATRIX.md',
        'REQUIREMENTS_MASTER.md',
        'SECURITY_PRIVACY_POLICY.md',
        'USER_STORIES_MASTER.json',
      ]) {
        File('${dir.path}/context/20-REQUIREMENTS/$file').writeAsStringSync('');
      }

      final project = buildProject(dir.path);
      expect(
        ProjectPhaseService.getProjectPhase(project),
        ProjectPhase.requirements,
      );
    });

    test('supports requirements alias folder 20-REQUIREMENTS_AND_SPEC', () {
      final result = ProjectPhaseService.calculateProgressFromFiles(const [
        'AGENTS.md',
        'README.md',
        'context/10-CONTEXT/DOMAIN_LANGUAGE.md',
        'context/10-CONTEXT/PROJECT_MANIFESTO.md',
        'context/10-CONTEXT/USER_JOURNEY_MAP.md',
        'context/20-REQUIREMENTS_AND_SPEC/COMPLIANCE_MATRIX.md',
        'context/20-REQUIREMENTS_AND_SPEC/REQUIREMENTS_MASTER.md',
        'context/20-REQUIREMENTS_AND_SPEC/SECURITY_PRIVACY_POLICY.md',
        'context/20-REQUIREMENTS_AND_SPEC/USER_STORIES_MASTER.json',
      ]);

      expect(result.currentPhase, 2);
      expect(result.docsCompleted, 9);
    });

    test('does not advance to next phase when mandatory docs are missing', () {
      final result = ProjectPhaseService.calculateProgressFromFiles(const [
        'AGENTS.md',
        'README.md',
        'context/10-CONTEXT/DOMAIN_LANGUAGE.md',
      ]);

      expect(result.currentPhase, 0);
      expect(result.docsCompleted, 3);
    });

    test('detects architecture phase', () async {
      final dir = await Directory.systemTemp.createTemp('phase-arch-');
      addTearDown(() => dir.delete(recursive: true));
      File('${dir.path}/AGENTS.md').writeAsStringSync('');
      File('${dir.path}/README.md').writeAsStringSync('');
      Directory('${dir.path}/context/10-CONTEXT').createSync(recursive: true);
      Directory(
        '${dir.path}/context/20-REQUIREMENTS',
      ).createSync(recursive: true);
      Directory(
        '${dir.path}/context/30-ARCHITECTURE',
      ).createSync(recursive: true);

      for (final file in const [
        'DOMAIN_LANGUAGE.md',
        'PROJECT_MANIFESTO.md',
        'USER_JOURNEY_MAP.md',
      ]) {
        File('${dir.path}/context/10-CONTEXT/$file').writeAsStringSync('');
      }

      for (final file in const [
        'COMPLIANCE_MATRIX.md',
        'REQUIREMENTS_MASTER.md',
        'SECURITY_PRIVACY_POLICY.md',
        'USER_STORIES_MASTER.json',
      ]) {
        File('${dir.path}/context/20-REQUIREMENTS/$file').writeAsStringSync('');
      }

      for (final file in const [
        'API_INTERFACE_CONTRACT.md',
        'ARCH_DECISION_RECORDS.md',
        'DATA_MODEL_SCHEMA.md',
        'PROJECT_STRUCTURE_MAP.md',
        'SECURITY_THREAT_MODEL.md',
        'TECH_STACK_DECISION.md',
      ]) {
        File('${dir.path}/context/30-ARCHITECTURE/$file').writeAsStringSync('');
      }

      final project = buildProject(dir.path);
      expect(
        ProjectPhaseService.getProjectPhase(project),
        ProjectPhase.architecture,
      );
    });

    test('calculates bounded progress', () {
      final project = buildProject('/tmp/proj');
      expect(ProjectPhaseService.calculateProgress(project, 0), 0);
      expect(
        ProjectPhaseService.calculateProgress(
          project,
          ProjectStructureConstants.totalExpectedDocs ~/ 2,
        ),
        greaterThan(0),
      );
      expect(
        ProjectPhaseService.calculateProgress(
          project,
          ProjectStructureConstants.totalExpectedDocs * 2,
        ),
        1,
      );
    });

    test('resolves current phase name and docs in phase', () {
      final project = buildProject('/tmp/proj');
      final name = ProjectPhaseService.getCurrentPhaseName(project, 2);
      final inCurrent = ProjectPhaseService.getDocumentsInCurrentPhase(
        project,
        2,
      );
      expect(name, ProjectPhase.root.name);
      expect(inCurrent, 2);
    });
  });
}
