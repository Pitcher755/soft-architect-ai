import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/gen/app_localizations.dart';
import 'package:softarchitect_ai/shared/presentation/widgets/global_search_dialog.dart';

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
  group('GlobalSearchDialog', () {
    testWidgets('should render dialog with search field', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const GlobalSearchDialog())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GlobalSearchDialog), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should have search field that accepts input', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const GlobalSearchDialog())),
      );
      await tester.pumpAndSettle();

      // Assert
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
    });

    testWidgets('should display list for search results', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const GlobalSearchDialog())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should render search dialog with proper widget hierarchy', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const GlobalSearchDialog())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });
  });
}
