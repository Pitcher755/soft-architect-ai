import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/theme/app_colors.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/widgets/project_card.dart';

void main() {
  Widget _build(Widget child, {double width = 1024}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Scaffold(
          body: Center(
            child: SizedBox(width: width / 2, child: child),
          ),
        ),
      ),
    );
  }

  ProjectCard makeCard({
    VoidCallback? onTap,
    String path = '/tmp/my-project',
    String projectId = 'test-project-123',
    bool isMissing = false,
  }) {
    return ProjectCard(
      name: 'Proyecto Demo',
      icon: Icons.folder,
      iconColor: AppColors.iconBlue,
      phase: 'Arquitectura',
      phaseColor: AppColors.dirArchitecture,
      path: path,
      modified: 'hoy',
      onTap: onTap ?? () {},
      projectId: projectId,
      isMissing: isMissing,
    );
  }

  group('ProjectCard', () {
    testWidgets('renders main content and metadata', (tester) async {
      await tester.pumpWidget(_build(makeCard()));
      expect(find.text('Proyecto Demo'), findsOneWidget);
      expect(find.text('Arquitectura'), findsOneWidget);
      expect(find.text('hoy'), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('invokes onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_build(makeCard(onTap: () => tapped = true)));
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('shortens long last path segment with ellipsis', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(
          makeCard(path: '/tmp/this-is-a-very-very-long-project-folder-name'),
        ),
      );
      expect(find.textContaining('...'), findsWidgets);
    });

    testWidgets('handles empty path safely', (tester) async {
      await tester.pumpWidget(_build(makeCard(path: '')));
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('builds on small screen branch', (tester) async {
      await tester.pumpWidget(_build(makeCard(), width: 480));
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('builds on medium screen branch', (tester) async {
      await tester.pumpWidget(_build(makeCard(), width: 700));
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('shows full path in tooltip', (tester) async {
      const path = '/tmp/sample-project';
      await tester.pumpWidget(_build(makeCard(path: path)));
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, path);
    });
  });
}
