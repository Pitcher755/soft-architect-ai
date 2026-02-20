import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/shared/presentation/widgets/projects_sidebar.dart';

// This generates a MockFilePicker class
@GenerateMocks([])
class MockFilePicker extends Mock implements FilePicker {}

void main() {
  group('ProjectsSidebar File Menu Tests', () {
    testWidgets(
      'should display menu button with correct icon',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Menu button should display terminal icon
        expect(
          find.byIcon(Icons.terminal),
          findsOneWidget,
          reason: 'Menu button should display terminal icon',
        );
      },
    );

    testWidgets(
      'should display all menu options when menu is opened',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Tap menu button to open
        final menuButton = find.byIcon(Icons.terminal);
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        // Assert - All menu options should be visible
        expect(
          find.text('Abrir Proyecto'),
          findsOneWidget,
          reason: 'Menu should have "Abrir Proyecto" option',
        );
        expect(
          find.text('Ajustes'),
          findsOneWidget,
          reason: 'Menu should have "Ajustes" option',
        );
        expect(
          find.text('Cerrar Proyecto'),
          findsOneWidget,
          reason: 'Menu should have "Cerrar Proyecto" option',
        );
        expect(
          find.text('Salir'),
          findsOneWidget,
          reason: 'Menu should have "Salir" option',
        );
      },
    );

    testWidgets(
      'should display correct icons for each menu option',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu
        final menuButton = find.byIcon(Icons.terminal);
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        // Assert - Check for specific icons
        expect(
          find.byIcon(Icons.folder_open_rounded),
          findsOneWidget,
          reason: 'Open Project should have folder icon',
        );
        expect(
          find.byIcon(Icons.settings_rounded),
          findsWidgets,
          reason: 'Settings should have settings icon',
        );
        expect(
          find.byIcon(Icons.close_rounded),
          findsOneWidget,
          reason: 'Close Project should have close icon',
        );
        expect(
          find.byIcon(Icons.exit_to_app_rounded),
          findsOneWidget,
          reason: 'Exit should have exit icon',
        );
      },
    );

    testWidgets(
      'should show exit confirmation dialog when Salir is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu and tap Salir
        await tester.tap(find.byIcon(Icons.terminal));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salir'));
        await tester.pumpAndSettle();

        // Assert - Confirmation dialog should appear
        expect(
          find.text('⚠️ Salir de la Aplicación'),
          findsOneWidget,
          reason: 'Exit confirmation dialog should be displayed',
        );
        expect(
          find.text('¿Estás seguro de que deseas cerrar SoftArchitect AI?'),
          findsOneWidget,
          reason: 'Exit confirmation message should be displayed',
        );
        expect(
          find.text('Cancelar'),
          findsWidgets,
          reason: 'Cancel button should be displayed',
        );
      },
    );

    testWidgets(
      'should dismiss exit dialog when Cancelar is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu, tap Salir, then Cancelar
        await tester.tap(find.byIcon(Icons.terminal));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salir'));
        await tester.pumpAndSettle();

        // Find and tap the Cancel button in the dialog
        final cancelButtons = find.text('Cancelar');
        await tester.tap(cancelButtons.last);
        await tester.pumpAndSettle();

        // Assert - Dialog should be dismissed
        expect(
          find.text('⚠️ Salir de la Aplicación'),
          findsNothing,
          reason: 'Exit dialog should be dismissed',
        );
        expect(
          find.byType(ProjectsSidebar),
          findsOneWidget,
          reason: 'Sidebar should still be displayed',
        );
      },
    );

    testWidgets(
      'should show close project confirmation dialog',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu and tap Cerrar Proyecto
        await tester.tap(find.byIcon(Icons.terminal));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cerrar Proyecto'));
        await tester.pumpAndSettle();

        // Assert - Confirmation dialog should appear
        expect(
          find.text('⚠️ Cerrar Proyecto'),
          findsOneWidget,
          reason: 'Close project confirmation dialog should be displayed',
        );
        expect(
          find.text('¿Estás seguro de que deseas cerrar el proyecto?'),
          findsOneWidget,
          reason: 'Close confirmation message should be displayed',
        );
      },
    );

    testWidgets(
      'should dismiss close project dialog when cancelled',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu, tap Cerrar Proyecto, then Cancelar
        await tester.tap(find.byIcon(Icons.terminal));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cerrar Proyecto'));
        await tester.pumpAndSettle();

        final cancelButtons = find.text('Cancelar');
        await tester.tap(cancelButtons.last);
        await tester.pumpAndSettle();

        // Assert - Dialog should be dismissed
        expect(
          find.text('⚠️ Cerrar Proyecto'),
          findsNothing,
          reason: 'Close project dialog should be dismissed',
        );
      },
    );

    testWidgets(
      'should have menu dividers between sections',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu
        await tester.tap(find.byIcon(Icons.terminal));
        await tester.pumpAndSettle();

        // Assert - Should have PopupMenuDivider widgets
        expect(
          find.byType(PopupMenuDivider),
          findsWidgets,
          reason: 'Menu should have dividers between sections',
        );
      },
    );

    testWidgets(
      'should have Abrir Proyecto option in menu',
      (WidgetTester tester) async {
        // Note: We don't test the actual FilePicker behavior in widget tests
        // as it requires platform-specific mocking. This test verifies
        // the menu structure and option availability.

        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open menu
        await tester.tap(find.byIcon(Icons.terminal));
        await tester.pumpAndSettle();

        // Assert - Abrir Proyecto option should be available
        expect(
          find.text('Abrir Proyecto'),
          findsOneWidget,
          reason: 'Menu should have Abrir Proyecto option',
        );
        expect(
          find.byIcon(Icons.folder_open_rounded),
          findsOneWidget,
          reason: 'Abrir Proyecto should have folder icon',
        );

        // Note: Actual file picker behavior is tested in integration tests
        // with proper platform channel mocking
      },
    );

    testWidgets(
      'menu button should have proper styling',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Menu button container should exist with proper decoration
        final containerFinder = find.ancestor(
          of: find.byIcon(Icons.terminal),
          matching: find.byType(Container),
        );

        expect(
          containerFinder,
          findsWidgets,
          reason: 'Menu button should be wrapped in styled Container',
        );
      },
    );
  });

  group('ProjectsSidebar Menu Integration Tests', () {
    testWidgets(
      'should maintain state after opening and closing menu',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Open and close menu multiple times
        for (var i = 0; i < 3; i++) {
          await tester.tap(find.byIcon(Icons.terminal));
          await tester.pumpAndSettle();

          // Close by tapping outside
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }

        // Assert - Sidebar should remain functional
        expect(
          find.byType(ProjectsSidebar),
          findsOneWidget,
          reason: 'Sidebar should remain stable',
        );
        expect(
          find.byIcon(Icons.terminal),
          findsOneWidget,
          reason: 'Menu button should still be accessible',
        );
      },
    );

    testWidgets(
      'should update icon count with new exit menu option',
      (WidgetTester tester) async {
        // This test ensures that adding the "Salir" option
        // doesn't break the existing icon count assertions
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: ProjectsSidebar())),
          ),
        );
        await tester.pumpAndSettle();

        // The sidebar itself should have core navigation icons
        // (terminal, workspace, project, search, settings)
        final allIcons = find.byType(Icon);
        expect(
          allIcons.evaluate().length,
          greaterThanOrEqualTo(4),
          reason: 'Should have at least 4 navigation icons',
        );
      },
    );
  });
}
