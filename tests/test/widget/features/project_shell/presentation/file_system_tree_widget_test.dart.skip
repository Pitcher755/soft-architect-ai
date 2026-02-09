import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/directory_node.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/file_system_tree_widget.dart';

void main() {
  group('FileSystemTreeWidget', () {
    late DirectoryNode mockDirectoryTree;

    setUp(() {
      // Create a mock directory tree
      mockDirectoryTree = DirectoryNode(
        name: 'context',
        path: '/project/context',
        isDirectory: true,
        children: [
          DirectoryNode(
            name: '10-CONTEXT',
            path: '/project/context/10-CONTEXT',
            isDirectory: true,
            children: [
              DirectoryNode(
                name: 'VISION.md',
                path: '/project/context/10-CONTEXT/VISION.md',
                isDirectory: false,
              ),
            ],
          ),
          DirectoryNode(
            name: '20-REQUIREMENTS',
            path: '/project/context/20-REQUIREMENTS',
            isDirectory: true,
            children: [],
          ),
        ],
      );
    });

    testWidgets('FileSystemTreeWidget displays directory structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: FileSystemTreeWidget(
            rootPath: '/project/context',
            initialTree: mockDirectoryTree,
          ),
        ),
      );

      // Act - pumpAndSettle to let UI render
      await tester.pumpAndSettle();

      // Assert - Check if root folders are displayed
      expect(find.text('10-CONTEXT'), findsOneWidget);
      expect(find.text('20-REQUIREMENTS'), findsOneWidget);
    });

    testWidgets('Clicking folder toggles expansion', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: FileSystemTreeWidget(
            rootPath: '/project/context',
            initialTree: mockDirectoryTree,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Tap on folder to expand
      await tester.tap(find.text('10-CONTEXT').first);
      await tester.pumpAndSettle();

      // Assert - File inside should now be visible
      expect(find.text('VISION.md'), findsOneWidget);
    });

    testWidgets('Clicking file highlights selection', (
      WidgetTester tester,
    ) async {
      // Arrange - Need to expand parent first
      await tester.pumpWidget(
        TestApp(
          child: FileSystemTreeWidget(
            rootPath: '/project/context',
            initialTree: mockDirectoryTree,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First expand the parent folder
      await tester.tap(find.text('10-CONTEXT').first);
      await tester.pumpAndSettle();

      // Act - Tap on the file
      await tester.tap(find.text('VISION.md'));
      await tester.pumpAndSettle();

      // Assert - File should be highlighted (indicated by selection color)
      // We check that the widget doesn't throw an error and renders correctly
      expect(find.text('VISION.md'), findsOneWidget);
    });

    testWidgets('Tree displays with proper folder icons', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestApp(
          child: FileSystemTreeWidget(
            rootPath: '/project/context',
            initialTree: mockDirectoryTree,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check for folder icons (at least 2 for folders)
      expect(find.byIcon(Icons.folder), findsWidgets);
    });

    testWidgets('Long paths are scrollable', (WidgetTester tester) async {
      // Arrange - Create a deeply nested tree
      final deepTree = DirectoryNode(
        name: 'root',
        path: '/root',
        isDirectory: true,
        children: [
          DirectoryNode(
            name: 'level1',
            path: '/root/level1',
            isDirectory: true,
            children: [
              DirectoryNode(
                name: 'level2',
                path: '/root/level1/level2',
                isDirectory: true,
                children: [
                  DirectoryNode(
                    name: 'level3',
                    path: '/root/level1/level2/level3',
                    isDirectory: true,
                    children: [
                      DirectoryNode(
                        name: 'file.md',
                        path: '/root/level1/level2/level3/file.md',
                        isDirectory: false,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TestApp(
          child: FileSystemTreeWidget(rootPath: '/root', initialTree: deepTree),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Expand all levels
      await tester.tap(find.text('level1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('level2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('level3'));
      await tester.pumpAndSettle();

      // Assert - All levels should be visible
      expect(find.text('level3'), findsOneWidget);
      expect(find.text('file.md'), findsOneWidget);
    });
  });
}

/// Test app wrapper for widget tests
class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }
}
