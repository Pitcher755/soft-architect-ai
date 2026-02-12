import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/appearance_section.dart';
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
  group('AppearanceSection', () {
    testWidgets('should render theme toggle switch', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const AppearanceSection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppearanceSection), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should render font size slider', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const AppearanceSection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should display font size percentage', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const AppearanceSection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsAtLeastNWidgets(2),
          reason: 'Should have text widgets including font size percentage');
    });

    testWidgets('theme switch updates notifier state', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const AppearanceSection()),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).themeMode, ThemeMode.dark);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).themeMode, ThemeMode.light);
    });

    testWidgets('slider and text submit update and validate font size', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const AppearanceSection()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).fontSize, greaterThan(1.0));

      final textField = find.byType(TextField);
      await tester.enterText(textField, '999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).fontSize, lessThanOrEqualTo(1.4));
    });
  });
}
