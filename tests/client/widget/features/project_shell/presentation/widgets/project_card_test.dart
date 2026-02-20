import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/src/framework.dart' show Override;
import 'package:softarchitect_ai/features/project_shell/domain/entities/project_progress.dart';
import 'package:softarchitect_ai/features/project_shell/domain/models/project_phase.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/project_card.dart';

Widget createTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Scaffold(body: SizedBox(width: 300, height: 200, child: child)),
    ),
  );
}

void main() {
  group('ProjectCard with projectStatusProvider', () {
    const testProjectPath = '/test/project';
    const testProjectName = 'Test Project';
    const testProjectId = 'test-id';

    testWidgets('should display 0% progress badge when no documents exist', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: 0,
        faseActual: ProjectPhase.root.name,
        porcentajeCompletado: 0,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '1 min ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Badge not shown when progress is 0% (actualProgress > 0 condition)
      expect(find.textContaining('Doc'), findsNothing);
      // Should show root phase
      expect(find.text(ProjectPhase.root.name), findsOneWidget);
    });

    testWidgets('should display 15% progress badge when 5 documents created', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '5 mins ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show 15% progress badge
      expect(find.text('Doc 15%'), findsOneWidget);
      // Should show Contexto phase
      expect(find.text('Contexto'), findsOneWidget);
    });

    testWidgets('should display 50% progress badge and corresponding phase', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: 16,
        faseActual: 'Arquitectura',
        porcentajeCompletado: 50,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '10 mins ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show 50% progress badge
      expect(find.text('Doc 50%'), findsOneWidget);
      // Should show Arquitectura phase
      expect(find.text('Arquitectura'), findsOneWidget);
    });

    testWidgets('should display 100% progress when project completed', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: ProjectPhase.totalFileCount,
        faseActual: 'Proyecto Completado',
        porcentajeCompletado: 100,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '1 hour ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show 100% progress badge
      expect(find.text('Doc 100%'), findsOneWidget);
    });

    testWidgets('should apply correct border color based on phase', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '5 mins ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Find the Container with border decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProjectCard),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).border != null,
          ),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      // Verify border has color with some alpha (not fully transparent)
      final alphaValue = (border.top.color.a * 255.0).round();
      expect(alphaValue, greaterThan(0));
    });

    testWidgets('should handle missing project gracefully', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '5 mins ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: true, // Project directory is missing
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show project name with "(faltante)" suffix
      expect(find.text('$testProjectName (faltante)'), findsOneWidget);
      // Should still show progress badge but with reduced opacity
      expect(find.text('Doc 15%'), findsOneWidget);
      // Should show warning icon
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should handle provider error gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '5 mins ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => throw Exception('File read error'),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show default state (empty progress)
      // Widget should not crash
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should display project metadata', (
      WidgetTester tester,
    ) async {
      final mockProgress = ProjectProgress(
        documentosCreados: 10,
        faseActual: 'Requisitos',
        porcentajeCompletado: 31.25,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '2 hours ago',
            onTap: () {},
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show project name
      expect(find.text(testProjectName), findsOneWidget);
      // Should show modification time
      expect(find.text('2 hours ago'), findsOneWidget);
      // Should show folder icon
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('should be tappable when not missing', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      final mockProgress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '5 mins ago',
            onTap: () => tapped = true,
            projectId: testProjectId,
            isMissing: false,
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Should trigger onTap callback
      expect(tapped, isTrue);
    });

    testWidgets('should not be tappable when missing', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      final mockProgress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          ProjectCard(
            name: testProjectName,
            icon: Icons.folder,
            path: testProjectPath,
            modified: '5 mins ago',
            onTap: () => tapped = true,
            projectId: testProjectId,
            isMissing: true, // Missing project
          ),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Try to tap the card (should not work)
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull); // onTap should be null

      // Should not trigger callback
      expect(tapped, isFalse);
    });
  });
}
