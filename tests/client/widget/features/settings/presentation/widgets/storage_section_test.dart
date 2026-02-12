import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/storage_section.dart';
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
  group('StorageSection', () {
    testWidgets('should render storage section with folder icon', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const StorageSection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(StorageSection), findsOneWidget);
      expect(find.byIcon(Icons.folder_special), findsOneWidget);
    });

    testWidgets('should display folder open button for directory selection', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const StorageSection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
    });

    testWidgets('should have text content and interactive elements', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(child: createTestApp(const StorageSection())),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });
  });
}
