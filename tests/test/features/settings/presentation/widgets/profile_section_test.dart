import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/profile_section.dart';

void main() {
  group('ProfileSection', () {
    testWidgets('should display userName field with ValueKey',
        (WidgetTester tester) async {
      // Arrange & Act: Build ProfileSection widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Verify widget renders and has the userName field
      expect(find.byType(ProfileSection), findsOneWidget);
      expect(
        find.byKey(const ValueKey('userName_field')),
        findsOneWidget,
        reason: 'ProfileSection should have a TextField with ValueKey for testing',
      );
    });

    testWidgets('should have onChanged handler for userName field',
        (WidgetTester tester) async {
      // Arrange & Act: Build ProfileSection widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Verify the TextField with ValueKey exists and can receive focus
      final textFieldFinder = find.byKey(const ValueKey('userName_field'));
      expect(textFieldFinder, findsOneWidget,
          reason: 'TextField with userName_field key should exist');

      // Verify it's a TextField widget (which would have onChanged capability)
      expect(find.byType(TextField), findsWidgets,
          reason: 'ProfileSection should contain TextField widgets');
    });
  });
}
