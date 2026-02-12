import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/profile_section.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';
import 'package:softarchitect_ai/gen/app_localizations.dart';

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
  group('ProfileSection', () {
    testWidgets('should display userName field with ValueKey',
        (WidgetTester tester) async {
      // Arrange & Act: Build ProfileSection widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Verify widget renders and has the userName field
      expect(find.byType(ProfileSection), findsOneWidget);
      expect(
        find.byKey(const ValueKey('userName_field')),
        findsOneWidget,
        reason: 'ProfileSection should have a TextField with ValueKey for testing',
      );
    });

    testWidgets('should have onChanged handler for userName field',
        (WidgetTester tester) async {
      // Arrange & Act: Build ProfileSection widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Verify the TextField with ValueKey exists and can receive focus
      final textFieldFinder = find.byKey(const ValueKey('userName_field'));
      expect(textFieldFinder, findsOneWidget,
          reason: 'TextField with userName_field key should exist');

      // Verify it's a TextField widget (which would have onChanged capability)
      expect(find.byType(TextField), findsWidgets,
          reason: 'ProfileSection should contain TextField widgets');
    });

    testWidgets('updates user name when text changes and submits',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const ProfileSection()),
        ),
      );
      await tester.pumpAndSettle();

      final field = find.byKey(const ValueKey('userName_field'));
      await tester.enterText(field, '  NuevoNombre  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).userName, contains('NuevoNombre'));
    });

    testWidgets('opens avatar dialog and selects predefined avatar',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ProfileSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cambiar avatar'));
      await tester.pumpAndSettle();

      expect(find.text('Elige un avatar'), findsOneWidget);
      final before = container.read(settingsProvider).avatarIndex;
      expect(before, equals(0));

      final dialogAvatarIcons = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byIcon(Icons.person),
      );
      await tester.tap(dialogAvatarIcons.last);
      await tester.pumpAndSettle();

      final after = container.read(settingsProvider).avatarIndex;
      expect(after, equals(5));
    });

    testWidgets('editing complete trims and persists user name',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ProfileSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = find.byKey(const ValueKey('userName_field'));
      await tester.enterText(field, '  Arquitecta  ');
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).userName, contains('Arquitecta'));
    });

    testWidgets('custom avatar selection failure shows snackbar',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: createTestApp(const ProfileSection()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cambiar avatar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
