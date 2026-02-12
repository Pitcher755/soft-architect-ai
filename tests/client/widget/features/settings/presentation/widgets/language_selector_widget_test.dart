import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/language_selector_widget.dart';
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
  group('LanguageSelectorWidget', () {
    testWidgets('should display language selector as list tile', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const LanguageSelectorWidget())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should have language dropdown for selection', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const LanguageSelectorWidget())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Icon), findsAtLeastNWidgets(1));
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });

    testWidgets('opens dropdown and shows EN/ES options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const LanguageSelectorWidget())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Inglés'), findsWidgets);
      expect(find.text('Español'), findsWidgets);
    });
  });

  group('LanguageToggleButton', () {
    testWidgets('renders with uppercase locale code', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const LanguageToggleButton())),
      );
      await tester.pumpAndSettle();

      expect(find.text('ES'), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('toggles language when pressed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const LanguageToggleButton())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('EN'), findsOneWidget);
    });
  });
}
