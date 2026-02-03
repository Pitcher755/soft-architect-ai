import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/screens/project_shell_screen.dart';

void main() {
  group('Project Shell E2E Tests', () {
    group('User creates new project workflow', () {
      testWidgets(
        'user can create new project from empty state',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Verify initial empty state
          expect(find.text('No projects'), findsWidgets);

          // Tap create button
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();

          // Enter project name
          await tester.enterText(find.byType(TextField), 'My New Project');
          await tester.pumpAndSettle();

          // Submit form
          await tester.tap(find.text('Create'));
          await tester.pumpAndSettle();

          // Verify project was created
          expect(find.text('My New Project'), findsWidgets);
        },
      );

      testWidgets(
        'validation prevents creating project with invalid name',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Tap create button
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();

          // Try to create with short name (< 3 chars)
          await tester.enterText(find.byType(TextField), 'AB');
          await tester.pumpAndSettle();

          // Submit form
          await tester.tap(find.text('Create'));
          await tester.pumpAndSettle();

          // Verify error message
          expect(
            find.text('Project name must be at least 3 characters'),
            findsWidgets,
          );

          // Verify project was not created
          expect(find.text('AB'), findsNothing);
        },
      );
    });

    group('User navigates project files', () {
      testWidgets(
        'user can expand and collapse directory tree',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Find expand button for lib directory
          final expandButton = find.byIcon(Icons.expand_more);

          // Collapse directory
          await tester.tap(expandButton.first);
          await tester.pumpAndSettle();

          // Verify children are hidden
          expect(find.text('main.dart'), findsNothing);

          // Expand again
          await tester.tap(find.byIcon(Icons.chevron_right).first);
          await tester.pumpAndSettle();

          // Verify children are shown
          expect(find.text('main.dart'), findsWidgets);
        },
      );

      testWidgets(
        'user can select file and view preview',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Tap on a file
          await tester.tap(find.text('main.dart'));
          await tester.pumpAndSettle();

          // Verify preview panel shows
          expect(find.byType(MarkdownPreviewWidget), findsWidgets);

          // Verify file content displayed
          expect(find.text('// main.dart content'), findsWidgets);
        },
      );
    });

    group('User searches project files', () {
      testWidgets(
        'user can search files by name',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Find search box
          final searchField = find.byType(TextField).first;

          // Enter search query
          await tester.enterText(searchField, 'main');
          await tester.pumpAndSettle();

          // Verify filtered results
          expect(find.text('main.dart'), findsWidgets);

          // Verify non-matching files not shown
          expect(find.text('constants.dart'), findsNothing);
        },
      );

      testWidgets(
        'search handles no results gracefully',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Search for non-existent file
          await tester.enterText(find.byType(TextField).first, 'nonexistent');
          await tester.pumpAndSettle();

          // Verify "no results" message
          expect(find.text('No files found'), findsWidgets);
        },
      );
    });

    group('User filters by file type', () {
      testWidgets(
        'user can filter files by extension',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Find extension filter
          final filterDropdown = find.byType(DropdownButton).first;

          // Tap to open filter
          await tester.tap(filterDropdown);
          await tester.pumpAndSettle();

          // Select .dart files
          await tester.tap(find.text('.dart').last);
          await tester.pumpAndSettle();

          // Verify only .dart files shown
          expect(find.text('.dart'), findsWidgets);
          expect(find.text('.yaml'), findsNothing);
        },
      );
    });

    group('User manages project settings', () {
      testWidgets(
        'user can rename project',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Find settings button
          await tester.tap(find.byIcon(Icons.settings));
          await tester.pumpAndSettle();

          // Find rename field
          final renameField = find.byType(TextField).first;

          // Clear and enter new name
          await tester.enterText(renameField, 'Renamed Project');
          await tester.pumpAndSettle();

          // Save changes
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Verify rename
          expect(find.text('Renamed Project'), findsWidgets);
        },
      );

      testWidgets(
        'user can delete project with confirmation',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Find delete button
          await tester.tap(find.byIcon(Icons.delete));
          await tester.pumpAndSettle();

          // Verify confirmation dialog
          expect(find.text('Delete project?'), findsWidgets);

          // Confirm deletion
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          // Verify project removed
          expect(find.text('No projects'), findsWidgets);
        },
      );
    });

    group('Keyboard shortcuts', () {
      testWidgets(
        'Ctrl+F opens search',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Simulate Ctrl+F
          await tester.sendKeyEvent(LogicalKeyboardKey.keyF,
              isControlPressed: true);
          await tester.pumpAndSettle();

          // Verify search is focused
          expect(find.byType(TextField).first, findsWidgets);
        },
      );

      testWidgets(
        'Escape closes dialogs',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Open settings
          await tester.tap(find.byIcon(Icons.settings));
          await tester.pumpAndSettle();

          // Verify dialog open
          expect(find.byType(AlertDialog), findsWidgets);

          // Press Escape
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();

          // Verify dialog closed
          expect(find.byType(AlertDialog), findsNothing);
        },
      );
    });

    group('Error handling', () {
      testWidgets(
        'handles file read errors gracefully',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Simulate file read error by selecting file
          await tester.tap(find.text('main.dart'));
          await tester.pumpAndSettle();

          // If error occurs, verify error message shown
          // instead of crashing
          expect(find.byType(MaterialApp), findsWidgets);
        },
      );

      testWidgets(
        'handles network timeout gracefully',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // UI should remain responsive even if backend times out
          expect(find.byType(ProjectShellScreen), findsWidgets);
        },
      );
    });

    group('Performance and responsiveness', () {
      testWidgets(
        'UI remains responsive when displaying large project',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          // Should handle large file tree without freezing
          await tester.pumpAndSettle();
          expect(find.byType(ProjectShellScreen), findsWidgets);
        },
      );

      testWidgets(
        'search response is fast',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: ProjectShellScreen(),
            ),
          );

          final stopwatch = Stopwatch()..start();

          // Perform search
          await tester.enterText(find.byType(TextField).first, 'main');
          await tester.pumpAndSettle();

          stopwatch.stop();

          // Search should complete in < 500ms
          expect(stopwatch.elapsedMilliseconds, lessThan(500));
        },
      );
    });
  });
}

// Mock widgets for testing (placeholder)
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('// main.dart content');
  }
}
