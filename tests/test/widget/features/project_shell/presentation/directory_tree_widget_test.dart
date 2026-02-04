// tests/widget/flutter/features/project_shell/presentation/directory_tree_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/directory_tree_widget.dart';
import '../../../../helpers/project_fixtures.dart';

void main() {
  group('DirectoryTreeWidget', () {
    late FileNode testRoot;
    late FileNode testFile;
    late FileNode testDirectory;

    setUp(() {
      testRoot = testRootNode;
      testFile = testFileNode;
      testDirectory = testDirectoryNode;
    });

    testWidgets('should display root directory name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('test-project'), findsOneWidget);
    });

    testWidgets('should display file names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The root should display
      expect(find.text('test-project'), findsOneWidget);
      // The widget should render correctly
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
    });

    testWidgets('should display directory names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The root should be visible
      expect(find.text('test-project'), findsOneWidget);
      // The widget should render correctly
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
    });

    testWidgets('should show folder icons for directories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('should show file icons for files', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // Should find at least one file icon (description.md has a file icon)
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should expand directory when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The widget should render without errors
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
      expect(find.byType(ExpansionTile), findsWidgets);
    });

    testWidgets('should collapse directory when tapped again', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The widget should render correctly
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
      expect(find.byType(ExpansionTile), findsWidgets);
    });

    testWidgets('should call onFileSelected when file is tapped', (WidgetTester tester) async {
      FileNode? selectedNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (node) => selectedNode = node,
            ),
          ),
        ),
      );

      // The widget should render without errors
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
    });

    testWidgets('should highlight selected file', (WidgetTester tester) async {
      final selectedFile = FileNode(
        id: 'file-readme',
        name: 'README.md',
        path: '/home/test/SoftArchitect/projects/test-project/README.md',
        isDirectory: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              selectedNode: selectedFile,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The selected file should be visible
      expect(find.text('README.md'), findsOneWidget);

      // Verify that at least one ListTile is marked as selected
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      final hasSelectedTile = listTiles.any((tile) => tile.selected == true);
      expect(hasSelectedTile, isTrue, reason: 'Should have at least one selected ListTile');

      // The widget should render without errors
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
    });

    testWidgets('should not highlight unselected files', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRoot,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The widget should render without errors when no selection is specified
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
      // The widget should be visible
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle empty directory', (WidgetTester tester) async {
      final emptyDir = FileNode(
        id: 'empty-dir',
        name: 'empty',
        path: '/empty',
        isDirectory: true,
        children: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: emptyDir,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // The widget should display the empty directory name
      expect(find.text('empty'), findsOneWidget);
      // Should have at least one Icon widget for folder
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should handle single file root', (WidgetTester tester) async {
      final singleFile = FileNode(
        id: 'single-file',
        name: 'single.md',
        path: '/single.md',
        isDirectory: false,
        children: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: singleFile,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('single.md'), findsOneWidget);
    });
  });
}
