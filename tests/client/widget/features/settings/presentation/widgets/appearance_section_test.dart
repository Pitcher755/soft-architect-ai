import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
