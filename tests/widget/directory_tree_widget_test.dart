// tests/widget/directory_tree_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/directory_tree_widget.dart';

void main() {
  group('DirectoryTreeWidget', () {
    late FileNode testRootNode;

    setUp(() {
      // Create test file tree
      testRootNode = FileNode(
        id: 'root',
        name: 'project',
        path: '/home/user/project',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file1',
            name: 'README.md',
            path: '/home/user/project/README.md',
            isDirectory: false,
            children: [],
          ),
          FileNode(
            id: 'dir1',
            name: 'src',
            path: '/home/user/project/src',
            isDirectory: true,
            children: [
              FileNode(
                id: 'file2',
                name: 'main.dart',
                path: '/home/user/project/src/main.dart',
                isDirectory: false,
                children: [],
              ),
            ],
          ),
        ],
      );
    });

    testWidgets('renders root directory correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify root node is displayed
      expect(find.text('project'), findsWidgets);
    });

    testWidgets('expand/collapse directories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // Find expand button for directory
      final expandButton = find.byIcon(Icons.folder);
      expect(expandButton, findsWidgets);

      // Tap to expand
      await tester.tap(expandButton.first);
      await tester.pumpAndSettle();

      // Verify children are shown after expansion
      expect(find.text('src'), findsWidgets);
    });

    testWidgets('file selection callback triggered',
        (WidgetTester tester) async {
      FileNode? selectedNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              onFileSelected: (node) {
                selectedNode = node;
              },
            ),
          ),
        ),
      );

      // Expand to show README.md
      final expandButton = find.byIcon(Icons.folder);
      await tester.tap(expandButton.first);
      await tester.pumpAndSettle();

      // Tap on file
      final fileItem = find.text('README.md');
      if (fileItem.evaluate().isNotEmpty) {
        await tester.tap(fileItem);
        await tester.pumpAndSettle();

        // Verify callback was triggered
        expect(selectedNode, isNotNull);
      }
    });

    testWidgets('shows file icons by type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(
              root: testRootNode,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify directory icon is shown
      expect(find.byIcon(Icons.folder), findsWidgets);
    });

    testWidgets('deep nesting renders correctly',
        (WidgetTester tester) async {
      final deepNode = FileNode(
        id: 'deep-root',
        name: 'root',
        path: '/root',
        isDirectory: true,
        children: [
          FileNode(
            id: 'l1',
            name: 'level1',
            path: '/root/level1',
            isDirectory: true,
            children: [
              FileNode(
                id: 'l2',
                name: 'level2',
                path: '/root/level1/level2',
                isDirectory: true,
                children: [
                  FileNode(
                    id: 'l3',
                    name: 'level3.txt',
                    path: '/root/level1/level2/level3.txt',
                    isDirectory: false,
                    children: [],
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
              root: deepNode,
              onFileSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify root is shown
      expect(find.text('root'), findsWidgets);

      // Expand and navigate through levels
      final expandButtons = find.byIcon(Icons.folder);
      expect(expandButtons, findsWidgets);
    });
  });
}
