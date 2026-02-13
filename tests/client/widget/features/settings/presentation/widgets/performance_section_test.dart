import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/performance_section.dart';

void main() {
  group('PerformanceSection', () {
    testWidgets('should render animations toggle switch', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PerformanceSection), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should render memory optimization switch', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Switch), findsWidgets,
          reason: 'Should have at least 2 Switch widgets for animations and memory');
    });

    testWidgets('should display both performance settings', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PerformanceSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsWidgets,
          reason: 'Should display text labels for settings');
      expect(find.byType(Divider), findsWidgets,
          reason: 'Should have dividers between settings');
    });

    testWidgets('toggling switches updates settings state', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: PerformanceSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      await container.read(settingsProvider.future);
      expect(container.read(settingsProvider).requireValue.enableAnimations, isTrue);
      expect(container.read(settingsProvider).requireValue.enableMemoryOptimization, isTrue);

      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).requireValue.enableAnimations, isFalse);
      expect(container.read(settingsProvider).requireValue.enableMemoryOptimization, isFalse);
    });
  });
}
