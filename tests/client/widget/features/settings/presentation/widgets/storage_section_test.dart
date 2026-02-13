import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageSection', () {
    setUp(() async {
      // Initialize mock SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should render storage section with folder icon', (
      WidgetTester tester,
    ) async {
      // Arrange: Create container and wait for async initialization
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for settingsProvider to initialize
      await container.read(settingsProvider.future);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const StorageSection()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(StorageSection), findsOneWidget);
      expect(find.byIcon(Icons.folder_special), findsOneWidget);
    });

    testWidgets('should display folder open button for directory selection', (
      WidgetTester tester,
    ) async {
      // Arrange: Create container and wait for async initialization
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for settingsProvider to initialize
      await container.read(settingsProvider.future);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const StorageSection()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
    });

    testWidgets('should have text content and interactive elements', (
      WidgetTester tester,
    ) async {
      // Arrange: Create container and wait for async initialization
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for settingsProvider to initialize
      await container.read(settingsProvider.future);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const StorageSection()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });

    testWidgets('should show default storage path when none configured', (
      WidgetTester tester,
    ) async {
      // Arrange: Create container and wait for async initialization
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for settingsProvider to initialize
      await container.read(settingsProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const StorageSection()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('~/Documents/SoftArchitect'), findsOneWidget);
    });

    testWidgets('tapping folder button handles picker error gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange: Create container and wait for async initialization
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for settingsProvider to initialize
      await container.read(settingsProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const StorageSection()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder_open));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
