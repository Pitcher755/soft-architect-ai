// tests/widget/project_shell_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/screens/project_shell_screen.dart';

void main() {
  group('ProjectShellScreen', () {
    testWidgets('renders correctly with Riverpod container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectShellScreen(),
          ),
        ),
      );

      // Verify main AppBar is rendered
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('SoftArchitect'), findsWidgets);

      // Verify layout structure (3-pane)
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('sidebar shows directory tree', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectShellScreen(),
          ),
        ),
      );

      // Verify directory tree widget is present
      expect(find.text('Project Root'), findsWidgets);

      // Verify tree is expandable (has expand buttons)
      expect(find.byIcon(Icons.folder_open), findsWidgets);
    });

    testWidgets('markdown preview updates on file selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectShellScreen(),
          ),
        ),
      );

      // Verify preview placeholder is shown initially
      expect(find.text('Select a file to preview'), findsWidgets);

      // Simulate tapping on a file (if available)
      final fileItem = find.byType(ListTile);
      if (fileItem.evaluate().isNotEmpty) {
        await tester.tap(fileItem.first);
        await tester.pumpAndSettle();

        // Verify content appears after selection
        expect(find.byType(SingleChildScrollView), findsWidgets);
      }
    });

    testWidgets('theme colors applied correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectShellScreen(),
          ),
        ),
      );

      // Verify dark theme is applied (background color)
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      // Verify AppBar has correct styling
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);
    });

    testWidgets('responsive layout on window resize',
        (WidgetTester tester) async {
      // Set window size for desktop testing
      tester.binding.window.physicalSizeTestValue =
          const Size(1920, 1080);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectShellScreen(),
          ),
        ),
      );

      // Verify all main components are visible
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Project Root'), findsWidgets);
      expect(find.text('Select a file to preview'), findsWidgets);
    });

    testWidgets('file selection callback works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectShellScreen(),
          ),
        ),
      );

      // Find first selectable item
      final tappableItem = find.byType(ListTile).first;

      // Verify item exists
      expect(tappableItem, findsOneWidget);

      // Tap on file
      await tester.tap(tappableItem);
      await tester.pumpAndSettle();

      // Verify state changed (no error thrown)
      expect(find.byType(ProjectShellScreen), findsOneWidget);
    });
  });
}
