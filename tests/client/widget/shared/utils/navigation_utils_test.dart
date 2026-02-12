import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/shared/utils/navigation_utils.dart';

void main() {
  group('navigation_utils snackbars', () {
    testWidgets('showError displays floating snackbar', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      );

      showError(ctx, 'boom');
      await tester.pumpAndSettle();

      expect(find.text('boom'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('showSuccess displays snackbar', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      );

      showSuccess(ctx, 'ok');
      await tester.pumpAndSettle();

      expect(find.text('ok'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
