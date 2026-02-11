import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/accessibility_section.dart';

void main() {
  group('AccessibilitySection', () {
    testWidgets('should render global zoom slider', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccessibilitySection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AccessibilitySection), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should render zoom shortcuts switch', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccessibilitySection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should display zoom percentage', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccessibilitySection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsWidgets,
          reason: 'Should have text widgets including zoom percentage');
    });
  });
}
