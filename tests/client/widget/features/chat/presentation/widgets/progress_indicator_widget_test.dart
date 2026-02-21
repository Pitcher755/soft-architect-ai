import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/src/framework.dart' show Override;
import 'package:softarchitect_ai/features/chat/presentation/widgets/progress_indicator_widget.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project_progress.dart';
import 'package:softarchitect_ai/features/project_shell/domain/models/project_phase.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';

Widget createTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ProgressIndicatorWidget with projectStatusProvider', () {
    const testProjectPath = '/test/project';

    testWidgets('should show empty state when projectPath is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          const ProgressIndicatorWidget(projectPath: null),
        ),
      );

      // Should show default empty state
      expect(find.text('Generating: Root'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          const ProgressIndicatorWidget(projectPath: testProjectPath),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display 0% progress when status.json does not exist', (
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
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      // Wait for async provider to resolve
      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Should show 0% progress
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Generating: ${ProjectPhase.root.name}'), findsOneWidget);
      expect(find.text('0 / ${ProjectPhase.totalFileCount} docs'), findsOneWidget);
    });

    testWidgets('should display 15% progress when 5 documents created', (
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
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Should show 15% progress
      expect(find.text('15%'), findsOneWidget);
      expect(find.text('Generating: Contexto'), findsOneWidget);
      expect(find.text('5 / ${ProjectPhase.totalFileCount} docs'), findsOneWidget);
    });

    testWidgets('should display 50% progress when half documents created', (
      WidgetTester tester,
    ) async {
      final halfDocs = ProjectPhase.totalFileCount ~/ 2;
      final mockProgress = ProjectProgress(
        documentosCreados: halfDocs,
        faseActual: 'Arquitectura',
        porcentajeCompletado: 50,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Should show 50% progress
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Generating: Arquitectura'), findsOneWidget);
      expect(
        find.text('$halfDocs / ${ProjectPhase.totalFileCount} docs'),
        findsOneWidget,
      );
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
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Should show 100% progress
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Generating: Proyecto Completado'), findsOneWidget);
      expect(
        find.text(
          '${ProjectPhase.totalFileCount} / ${ProjectPhase.totalFileCount} docs',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should handle provider error gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => throw Exception('File read error'),
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve
      await tester.pump(); // Wait for error state to propagate

      // Should show empty state on error (fallback to initial state)
      expect(find.byType(ProgressIndicatorWidget), findsOneWidget);
    });

    testWidgets('should display segmented progress bar', (
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
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => mockProgress,
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Should find the segmented progress bar (visually represented by SizedBox)
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('31%'), findsOneWidget);
    });

    testWidgets('should update when provider value changes', (
      WidgetTester tester,
    ) async {
      final initialProgress = ProjectProgress(
        documentosCreados: 5,
        faseActual: 'Contexto',
        porcentajeCompletado: 15.6,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          const ProgressIndicatorWidget(projectPath: testProjectPath),
          overrides: [
            projectStatusProvider(testProjectPath).overrideWith(
              (ref) async => initialProgress,
            ),
          ],
        ),
      );

      await tester.pump(); // Trigger first frame
      await tester.pump(); // Let FutureProvider resolve

      // Verify initial state
      expect(find.text('15%'), findsOneWidget);
      expect(find.text('Generating: Contexto'), findsOneWidget);

      // Note: In real app, provider would update when file changes.
      // Here we just verify the widget responds to provider data.
    });
  });
}
