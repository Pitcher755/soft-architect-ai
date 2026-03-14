// tests/client/widget/features/filesystem/presentation/file_tree_widget_test.dart

// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/notifiers/file_system_notifier.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/providers/filesystem_providers.dart';
import 'package:softarchitect_ai/features/filesystem/presentation/widgets/file_tree_widget.dart';

void main() {
  group('FileTreeWidget - Auto-Refresh via Provider', () {
    testWidgets(
      'should respond to refreshCounter changes from provider',
      (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            projectRootProvider.overrideWith((ref) => '/test/path'),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final refreshCounter = ref.watch(
                      fileSystemNotifierProvider.select((s) => s.refreshCounter),
                    );
                    return Text('Counter: $refreshCounter');
                  },
                ),
              ),
            ),
          ),
        );

        // Verify initial counter is 0
        expect(find.text('Counter: 0'), findsOneWidget);

        // Trigger refresh
        container.read(fileSystemNotifierProvider.notifier).refresh();
        await tester.pump();

        // Verify counter incremented to 1
        expect(find.text('Counter: 1'), findsOneWidget);

        // Trigger another refresh
        container.read(fileSystemNotifierProvider.notifier).refresh();
        await tester.pump();

        // Verify counter incremented to 2
        expect(find.text('Counter: 2'), findsOneWidget);

        container.dispose();
      },
    );

    testWidgets(
      'should handle multiple consecutive refreshes',
      (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            projectRootProvider.overrideWith((ref) => '/test/path'),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final refreshCounter = ref.watch(
                      fileSystemNotifierProvider.select((s) => s.refreshCounter),
                    );
                    return Text('Counter: $refreshCounter');
                  },
                ),
              ),
            ),
          ),
        );

        final notifier = container.read(fileSystemNotifierProvider.notifier);

        // Trigger multiple refreshes
        notifier.refresh();
        await tester.pump();
        expect(find.text('Counter: 1'), findsOneWidget);

        notifier.refresh();
        await tester.pump();
        expect(find.text('Counter: 2'), findsOneWidget);

        notifier.refresh();
        await tester.pump();
        expect(find.text('Counter: 3'), findsOneWidget);

        container.dispose();
      },
    );

    testWidgets(
      'should rebuild FileTreeWidget when refreshCounter changes',
      (WidgetTester tester) async {
        // Use mock root node to avoid async file system reads
        final mockRoot = FileNode(
          id: '/mock',
          name: 'mock',
          path: '/mock',
          isDirectory: true,
          children: [
            FileNode(
              id: '/mock/file1.md',
              name: 'file1.md',
              path: '/mock/file1.md',
              isDirectory: false,
            ),
          ],
        );

        final container = ProviderContainer(
          overrides: [
            projectRootProvider.overrideWith((ref) => '/mock'),
          ],
        );

        int buildCount = 0;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    // Watch refresh counter to trigger rebuilds
                    ref.watch(
                      fileSystemNotifierProvider.select((s) => s.refreshCounter),
                    );
                    buildCount++;
                    return FileTreeWidget(
                      rootNode: mockRoot,
                      onFileSelected: (_) {},
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        final initialBuildCount = buildCount;

        // Trigger refresh
        container.read(fileSystemNotifierProvider.notifier).refresh();
        await tester.pump();

        // Verify widget rebuilt
        expect(buildCount, greaterThan(initialBuildCount));

        container.dispose();
      },
    );
  });

  group('FileTreeWidget - Basic Functionality with Mock Data', () {
    testWidgets(
      'should render with mock root node',
      (WidgetTester tester) async {
        final mockRoot = FileNode(
          id: '/test',
          name: 'test',
          path: '/test',
          isDirectory: true,
          children: [
            FileNode(
              id: '/test/README.md',
              name: 'README.md',
              path: '/test/README.md',
              isDirectory: false,
            ),
            FileNode(
              id: '/test/src',
              name: 'src',
              path: '/test/src',
              isDirectory: true,
              children: [
                FileNode(
                  id: '/test/src/main.dart',
                  name: 'main.dart',
                  path: '/test/src/main.dart',
                  isDirectory: false,
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: FileTreeWidget(
                  rootNode: mockRoot,
                  onFileSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify widget renders
        expect(find.byType(FileTreeWidget), findsOneWidget);
        expect(find.text('README.md'), findsOneWidget);
        expect(find.text('src'), findsOneWidget);
      },
    );

    testWidgets(
      'should call onFileSelected when file is tapped',
      (WidgetTester tester) async {
        FileNode? selectedNode;

        final mockRoot = FileNode(
          id: '/test',
          name: 'test',
          path: '/test',
          isDirectory: true,
          children: [
            FileNode(
              id: '/test/README.md',
              name: 'README.md',
              path: '/test/README.md',
              isDirectory: false,
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: FileTreeWidget(
                  rootNode: mockRoot,
                  onFileSelected: (node) {
                    selectedNode = node;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Tap on README.md
        await tester.tap(find.text('README.md'));
        await tester.pump();

        // Verify callback was called with correct node
        expect(selectedNode, isNotNull);
        expect(selectedNode!.name, equals('README.md'));
        expect(selectedNode!.path, equals('/test/README.md'));
      },
    );

    testWidgets(
      'should handle empty root node',
      (WidgetTester tester) async {
        final emptyRoot = FileNode(
          id: '/empty',
          name: 'empty',
          path: '/empty',
          isDirectory: true,
          children: [],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: FileTreeWidget(
                  rootNode: emptyRoot,
                  onFileSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Widget should render without crashing
        expect(find.byType(FileTreeWidget), findsOneWidget);
      },
    );
  });

  group('FileSystemNotifier - Unit Tests', () {
    test('refresh should increment counter', () {
      final notifier = FileSystemNotifier();
      final initial = notifier.state.refreshCounter;

      notifier.refresh();

      expect(notifier.state.refreshCounter, equals(initial + 1));
    });

    test('multiple refreshes should increment counter multiple times', () {
      final notifier = FileSystemNotifier();
      final initial = notifier.state.refreshCounter;

      notifier.refresh();
      notifier.refresh();
      notifier.refresh();

      expect(notifier.state.refreshCounter, equals(initial + 3));
    });

    test('setRootPath should update root path', () {
      final notifier = FileSystemNotifier();

      notifier.setRootPath('/new/path');

      expect(notifier.state.rootPath, equals('/new/path'));
    });

    test('setRootPath should not affect refresh counter', () {
      final notifier = FileSystemNotifier();
      final initialCounter = notifier.state.refreshCounter;

      notifier.setRootPath('/new/path');

      expect(notifier.state.refreshCounter, equals(initialCounter));
    });

    test('selectFile should set selected file', () {
      final notifier = FileSystemNotifier();

      notifier.selectFile('/path/to/file.dart');

      expect(notifier.state.selectedFile, equals('/path/to/file.dart'));
    });

    test('toggleFolder should expand collapsed folder', () {
      final notifier = FileSystemNotifier();
      const folderPath = '/path/to/folder';

      // Initially folder is not expanded
      expect(notifier.state.expandedPaths.contains(folderPath), isFalse);

      notifier.toggleFolder(folderPath);

      // Now folder is expanded
      expect(notifier.state.expandedPaths.contains(folderPath), isTrue);
    });

    test('toggleFolder should collapse expanded folder', () {
      final notifier = FileSystemNotifier();
      const folderPath = '/path/to/folder';

      // Expand folder first
      notifier.toggleFolder(folderPath);
      expect(notifier.state.expandedPaths.contains(folderPath), isTrue);

      // Toggle again to collapse
      notifier.toggleFolder(folderPath);

      // Now folder is collapsed
      expect(notifier.state.expandedPaths.contains(folderPath), isFalse);
    });
  });
}
