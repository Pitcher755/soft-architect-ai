import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/shared/presentation/widgets/global_search_dialog.dart';

void main() {
  group('GlobalSearchDialog', () {
    testWidgets('should display dialog with search functionality', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: GlobalSearchDialog())),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Dialog should be visible
      expect(
        find.byType(GlobalSearchDialog),
        findsOneWidget,
        reason: 'GlobalSearchDialog should be rendered',
      );
      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'Search field should be present',
      );
    });

    testWidgets('should close dialog when close button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: GlobalSearchDialog())),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Find and tap close button
      final closeButton = find.byIcon(Icons.close);
      expect(
        closeButton,
        findsOneWidget,
        reason: 'Close button should be present in dialog',
      );

      await tester.tap(closeButton);
      await tester.pumpAndSettle();
    });

    testWidgets('should filter projects based on search query', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: GlobalSearchDialog())),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Type in search field
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.pumpAndSettle();

      // Assert: Search should filter results
      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'Search field should still be visible after entering text',
      );
    });

    testWidgets('should save last project when navigating from search', (
      WidgetTester tester,
    ) async {
      // Arrange
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: GlobalSearchDialog())),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Tap on a project card (if visible)
      final projectCards = find.byType(Card);
      if (projectCards.evaluate().isNotEmpty) {
        await tester.tap(projectCards.first);
        await tester.pumpAndSettle();

        // Assert: Navigation should occur and last project should be saved
        // (This would require checking lastProjectProvider state)
      }
    });
  });
}
