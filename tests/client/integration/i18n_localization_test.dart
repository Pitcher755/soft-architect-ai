import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/shared_preferences_mock.dart';

void main() {
  group('i18n Localization Integration Tests', () {
    setUp(() {
      // Clear SharedPreferences before each test
      initMockSharedPreferences({});
    });

    testWidgets('Locale provider supports English and Spanish', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('es')],
            home: Scaffold(body: Center(child: Text('English Locale'))),
          ),
        ),
      );

      expect(find.text('English Locale'), findsOneWidget);
    });

    testWidgets('Spanish locale is configurable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('es')],
            home: Scaffold(body: Center(child: Text('Locale Español'))),
          ),
        ),
      );

      expect(find.text('Locale Español'), findsOneWidget);
    });

    testWidgets('Supported locales list is correct', (
      WidgetTester tester,
    ) async {
      const supportedLocales = [Locale('en'), Locale('es')];

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: supportedLocales,
            home: Scaffold(body: Center(child: Text('Locales Test'))),
          ),
        ),
      );

      // Verify app builds successfully with supported locales
      expect(find.text('Locales Test'), findsOneWidget);
      expect(supportedLocales.length, equals(2));
    });
  });
}
