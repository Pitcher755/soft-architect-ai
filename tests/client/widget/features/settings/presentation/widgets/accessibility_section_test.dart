import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/accessibility_section.dart';
import 'package:softarchitect_ai/gen/app_localizations.dart';

/// Helper to create MaterialApp with proper i18n setup for tests
Widget createTestApp(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: child),
);

void main() {
  group('AccessibilitySection', () {
    testWidgets('should render global zoom slider', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const AccessibilitySection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AccessibilitySection), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should render zoom shortcuts switch', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const AccessibilitySection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should display zoom percentage', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const AccessibilitySection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsAtLeastNWidgets(2),
          reason: 'Should have text widgets including zoom percentage');
    });

    testWidgets('slider and switch update accessibility settings', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const AccessibilitySection()),
        ),
      );
      await tester.pumpAndSettle();

      await container.read(settingsProvider.future);
      expect(container.read(settingsProvider).requireValue.enableZoomShortcuts, isTrue);
      expect(container.read(settingsProvider).requireValue.globalZoom, 1.0);

      await tester.drag(find.byType(Slider), const Offset(140, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).requireValue.globalZoom, greaterThan(1.0));
      expect(container.read(settingsProvider).requireValue.enableZoomShortcuts, isFalse);
    });
  });
}
