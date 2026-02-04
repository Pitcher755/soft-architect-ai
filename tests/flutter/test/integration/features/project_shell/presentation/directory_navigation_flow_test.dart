import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/directory_tree_widget.dart';
import '../../../helpers/project_fixtures.dart';

void main() {
  group('Directory Navigation Flow Integration Test', () {
    testWidgets('should handle complete directory navigation workflow', (WidgetTester tester) async {
      FileNode? selectedFile;

      // Given a complex directory structure
      final complexRoot = FileNode(
        id: 'complex-root',
        name: 'complex-project',
        path: '/complex/project',
        isDirectory: true,
        children: [
          FileNode(
            id: 'readme',
            name: 'README.md',
            path: '/complex/project/README.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'src-dir',
            name: 'src',
            path: '/complex/project/src',
            isDirectory: true,
            children: [
              FileNode(
                id: 'main-dart',
                name: 'main.dart',
                path: '/complex/project/src/main.dart',
                isDirectory: false,
              ),
              FileNode(
                id: 'lib-dir',
                name: 'lib',
                path: '/complex/project/src/lib',
                isDirectory: true,
                children: [
                  FileNode(
                    id: 'utils-dart',
                    name: 'utils.dart',
                    path: '/complex/project/src/lib/utils.dart',
                    isDirectory: false,
                  ),
                  FileNode(
                    id: 'models-dart',
                    name: 'models.dart',
                    path: '/complex/project/src/lib/models.dart',
                    isDirectory: false,
                  ),
                ],
              ),
            ],
          ),
          FileNode(
            id: 'test-dir',
            name: 'test',
            path: '/complex/project/test',
            isDirectory: true,
            children: [
              FileNode(
                id: 'main-test',
                name: 'main_test.dart',
                path: '/complex/project/test/main_test.dart',
                isDirectory: false,
              ),
            ],
          ),
        ],
      );

      // When - Render the directory tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: complexRoot,
              onFileSelected: (node) => selectedFile = node,
            ),
          ),
        ),
      );

      // Then - Initially only root level items should be visible
      expect(find.text('README.md'), findsOneWidget);
      expect(find.text('src'), findsOneWidget);
      expect(find.text('test'), findsOneWidget);

      // Nested items should not be visible initially
      expect(find.text('main.dart'), findsNothing);
      expect(find.text('utils.dart'), findsNothing);
      expect(find.text('main_test.dart'), findsNothing);

      // When - Expand src directory
      await tester.tap(find.text('src'));
      await tester.pumpAndSettle();

      // Then - src contents should be visible
      expect(find.text('main.dart'), findsOneWidget);
      expect(find.text('lib'), findsOneWidget);
      expect(find.text('utils.dart'), findsNothing); // lib not expanded yet

      // When - Expand lib directory
      await tester.tap(find.text('lib'));
      await tester.pumpAndSettle();

      // Then - lib contents should be visible
      expect(find.text('utils.dart'), findsOneWidget);
      expect(find.text('models.dart'), findsOneWidget);

      // When - Select a file
      await tester.tap(find.text('utils.dart'));
      await tester.pumpAndSettle();

      // Then - File should be selected
      expect(selectedFile, isNotNull);
      expect(selectedFile?.name, equals('utils.dart'));
      expect(selectedFile?.isDirectory, isFalse);

      // When - Select another file
      await tester.tap(find.text('models.dart'));
      await tester.pumpAndSettle();

      // Then - New file should be selected
      expect(selectedFile?.name, equals('models.dart'));

      // When - Expand test directory
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      // Then - test contents should be visible
      expect(find.text('main_test.dart'), findsOneWidget);

      // When - Select test file
      await tester.tap(find.text('main_test.dart'));
      await tester.pumpAndSettle();

      // Then - Test file should be selected
      expect(selectedFile?.name, equals('main_test.dart'));

      // When - Collapse src directory
      await tester.tap(find.text('src'));
      await tester.pumpAndSettle();

      // Then - src contents should be hidden
      expect(find.text('main.dart'), findsNothing);
      expect(find.text('lib'), findsNothing);
      expect(find.text('utils.dart'), findsNothing);
      expect(find.text('models.dart'), findsNothing);

      // But test contents should still be visible
      expect(find.text('main_test.dart'), findsOneWidget);
    });

    testWidgets('should handle selection highlighting correctly', (WidgetTester tester) async {
      FileNode? selectedFile;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              onFileSelected: (node) => selectedFile = node,
            ),
          ),
        ),
      );

      // Initially no selection
      var listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final tile in listTiles) {
        expect(tile.selected, isFalse);
      }

      // Expand directory and select file
      await tester.tap(find.text('docs'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('architecture.md'));
      await tester.pumpAndSettle();

      // Re-render with selected node
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              selectedNode: selectedFile,
              onFileSelected: (node) => selectedFile = node,
            ),
          ),
        ),
      );

      // Find the selected ListTile
      final selectedTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('architecture.md'),
          matching: find.byType(ListTile),
        ),
      );

      expect(selectedTile.selected, isTrue);
    });

    testWidgets('should handle deep nesting correctly', (WidgetTester tester) async {
      // Create a deeply nested structure
      final deepNested = FileNode(
        id: 'level1',
        name: 'level1',
        path: '/level1',
        isDirectory: true,
        children: [
          FileNode(
            id: 'level2',
            name: 'level2',
            path: '/level1/level2',
            isDirectory: true,
            children: [
              FileNode(
                id: 'level3',
                name: 'level3',
                path: '/level1/level2/level3',
                isDirectory: true,
                children: [
                  FileNode(
                    id: 'deep-file',
                    name: 'deep.txt',
                    path: '/level1/level2/level3/deep.txt',
                    isDirectory: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: deepNested,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // Initially only level1 visible
      expect(find.text('level1'), findsOneWidget);
      expect(find.text('level2'), findsNothing);

      // Expand level1
      await tester.tap(find.text('level1'));
      await tester.pumpAndSettle();
      expect(find.text('level2'), findsOneWidget);
      expect(find.text('level3'), findsNothing);

      // Expand level2
      await tester.tap(find.text('level2'));
      await tester.pumpAndSettle();
      expect(find.text('level3'), findsOneWidget);
      expect(find.text('deep.txt'), findsNothing);

      // Expand level3
      await tester.tap(find.text('level3'));
      await tester.pumpAndSettle();
      expect(find.text('deep.txt'), findsOneWidget);
    });

    testWidgets('should maintain expansion state correctly', (WidgetTester tester) async {
      FileNode? selectedFile;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              onFileSelected: (node) => selectedFile = node,
            ),
          ),
        ),
      );

      // Expand docs
      await tester.tap(find.text('docs'));
      await tester.pumpAndSettle();
      expect(find.text('architecture.md'), findsOneWidget);

      // Select file
      await tester.tap(find.text('architecture.md'));
      await tester.pumpAndSettle();

      // Re-render (simulating state change)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              selectedNode: selectedFile,
              onFileSelected: (node) => selectedFile = node,
            ),
          ),
        ),
      );

      // docs should still be expanded
      expect(find.text('architecture.md'), findsOneWidget);
    });
  });
}
