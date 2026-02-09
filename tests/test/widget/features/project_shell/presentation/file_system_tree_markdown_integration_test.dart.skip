import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/directory_node.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/notifiers/markdown_preview_notifier.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/file_system_tree_widget.dart';

void main() {
  group('FileSystemTreeWidget + MarkdownPreviewWidget Integration', () {
    testWidgets('Selecting file in tree updates preview notifier', (
      WidgetTester tester,
    ) async {
      // Arrange - Create a directory tree with a markdown file
      final mockTree = DirectoryNode(
        name: 'context',
        path: '/project/context',
        isDirectory: true,
        children: [
          DirectoryNode(
            name: 'VISION.md',
            path: '/project/context/VISION.md',
            isDirectory: false,
          ),
        ],
      );

      // Container to hold the notifier state for assertion
      late MarkdownPreviewState capturedState;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: FileSystemTreeWidget(
                      rootPath: '/project/context',
                      initialTree: mockTree,
                    ),
                  ),
                  // Consumer to capture preview state
                  Expanded(
                    flex: 1,
                    child: Consumer(
                      builder: (context, ref, child) {
                        capturedState = ref.watch(
                          markdownPreviewNotifierProvider,
                        );
                        return Center(
                          child: Text(capturedState.filePath ?? 'No file'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Tap on the file in the tree
      await tester.tap(find.text('VISION.md'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Assert - The markdown preview notifier should be updated
      expect(capturedState.filePath, equals('/project/context/VISION.md'));
      expect(capturedState.content, isNotNull);
      expect(capturedState.content, contains('VISION.md'));
    });

    testWidgets('Selecting multiple files updates preview each time', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockTree = DirectoryNode(
        name: 'context',
        path: '/project/context',
        isDirectory: true,
        children: [
          DirectoryNode(
            name: 'file1.md',
            path: '/project/context/file1.md',
            isDirectory: false,
          ),
          DirectoryNode(
            name: 'file2.md',
            path: '/project/context/file2.md',
            isDirectory: false,
          ),
        ],
      );

      late MarkdownPreviewState capturedState;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: FileSystemTreeWidget(
                      rootPath: '/project/context',
                      initialTree: mockTree,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Consumer(
                      builder: (context, ref, child) {
                        capturedState = ref.watch(
                          markdownPreviewNotifierProvider,
                        );
                        return Center(
                          child: Text(capturedState.filePath ?? 'No file'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act & Assert - Select first file
      await tester.tap(find.text('file1.md'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(capturedState.filePath, equals('/project/context/file1.md'));

      // Act & Assert - Select second file
      await tester.tap(find.text('file2.md'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(capturedState.filePath, equals('/project/context/file2.md'));
    });

    testWidgets('Selecting nested file updates preview correctly', (
      WidgetTester tester,
    ) async {
      // Arrange - Create nested directory structure
      final mockTree = DirectoryNode(
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
        ],
      );

      late MarkdownPreviewState capturedState;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: FileSystemTreeWidget(
                      rootPath: '/project/context',
                      initialTree: mockTree,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Consumer(
                      builder: (context, ref, child) {
                        capturedState = ref.watch(
                          markdownPreviewNotifierProvider,
                        );
                        return Center(
                          child: Text(capturedState.filePath ?? 'No file'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Expand folder first
      await tester.tap(find.text('10-CONTEXT'));
      await tester.pumpAndSettle();

      // Act - Select nested file
      await tester.tap(find.text('VISION.md'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Assert - The markdown preview should have the nested file
      expect(
        capturedState.filePath,
        equals('/project/context/10-CONTEXT/VISION.md'),
      );
    });
  });
}
