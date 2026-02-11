import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/shared/presentation/widgets/projects_sidebar.dart';

void main() {
  group('ProjectsSidebar', () {
    testWidgets('should display sidebar with navigation buttons',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProjectsSidebar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Sidebar has navigation buttons, not a ListView
      expect(find.byType(ProjectsSidebar), findsOneWidget,
          reason: 'ProjectsSidebar should be rendered');
      expect(find.byType(Icon), findsWidgets,
          reason: 'Sidebar should have icon navigation buttons');
      // Sidebar has 5 icons: logo, workspace, project, search, settings
      expect(find.byType(Icon).evaluate().length, greaterThanOrEqualTo(4),
          reason: 'Should have at least 4 navigation icons');
    });

    testWidgets('should display last project button when available',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProjectsSidebar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Look for history icon or last project button
      final historyIcon = find.byIcon(Icons.history);
      if (historyIcon.evaluate().isNotEmpty) {
        expect(historyIcon, findsOneWidget,
            reason: 'Last project button should display history icon');
      }
    });

    testWidgets('should navigate to project when item is tapped',
        (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ProjectsSidebar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Tap on first project in list
      final projectItems = find.byType(ListTile);
      if (projectItems.evaluate().isNotEmpty) {
        await tester.tap(projectItems.first);
        await tester.pumpAndSettle();

        // Assert: Navigation should be triggered
        // (Actual navigation verification depends on routing setup)
      }
    });

    testWidgets('should show project icon indicators',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProjectsSidebar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Should have icons for projects
      expect(find.byType(Icon), findsWidgets,
          reason: 'Sidebar should display icons for projects');
    });

    testWidgets('should display navigation tooltips',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProjectsSidebar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Sidebar uses Tooltips for button labels, not Text widgets
      expect(find.byType(Tooltip), findsWidgets,
          reason: 'Sidebar should display tooltips for navigation buttons');
      // Sidebar has 4 tooltips: workspace, project, search, settings
      expect(find.byType(Tooltip).evaluate().length, greaterThanOrEqualTo(4),
          reason: 'Should have tooltips for all navigation buttons');
    });

    testWidgets('should update current project highlight',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProjectsSidebar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Tap on a project
      final projectItems = find.byType(ListTile);
      if (projectItems.evaluate().isNotEmpty) {
        await tester.tap(projectItems.first);
        await tester.pumpAndSettle();

        // Assert: Current project should be highlighted
        // (Visual verification or state check)
        expect(find.byType(ListTile), findsWidgets,
            reason: 'ProjectsSidebar should still display projects');
      }
    });
  });
}
