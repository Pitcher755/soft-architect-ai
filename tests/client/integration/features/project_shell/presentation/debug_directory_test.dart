// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/directory_tree_widget.dart';

void main() {
  group('Directory Navigation Flow Integration Test', () {
    testWidgets('should render DirectoryTreeWidget without errors', (
      WidgetTester tester,
    ) async {
      // Given a simple directory structure
      final simpleRoot = FileNode(
        id: 'simple-root',
        name: 'simple-project',
        path: '/simple/project',
        isDirectory: true,
        children: [
          FileNode(
            id: 'readme',
            name: 'README.md',
            path: '/simple/project/README.md',
            isDirectory: false,
          ),
        ],
      );

      // When - Render the directory tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectoryTreeWidget(root: simpleRoot, onFileSelected: (_) {}),
          ),
        ),
      );

      // Wait for post-frame callbacks to complete
      await tester.pumpAndSettle();

      // Then - Widget should render without errors
      expect(find.byType(DirectoryTreeWidget), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Debug: Print all text widgets
      final textWidgets = tester.widgetList(find.byType(Text));
      print('Found ${textWidgets.length} Text widgets:');
      for (final widget in textWidgets) {
        print('  Text: "${(widget as Text).data}"');
      }
    });
  });
}
