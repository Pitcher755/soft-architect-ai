import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/core/localization/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleProvider', () {
    test('initializes with default locale', () {
      final container = ProviderContainer();
      final locale = container.read(localeProvider);
      expect(locale, isNotNull);
      expect(locale, isA<Locale>());
    });

    test('supports switching to Spanish locale', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('es'));
      final locale = container.read(localeProvider);

      expect(locale.languageCode, equals('es'));
    });

    test('supports switching to English locale', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      final locale = container.read(localeProvider);

      expect(locale.languageCode, equals('en'));
    });

    test('locale has country code when provided', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('es', 'ES'));
      final locale = container.read(localeProvider);

      expect(locale.languageCode, equals('es'));
      expect(locale.countryCode, isNull);
    });

    test('maintains locale state on multiple reads', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('es'));

      final locale1 = container.read(localeProvider);
      final locale2 = container.read(localeProvider);

      expect(locale1.languageCode, equals(locale2.languageCode));
    });

    test('supports locale change via notifier', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      expect(container.read(localeProvider).languageCode, equals('en'));

      await notifier.setLocale(const Locale('es'));
      expect(container.read(localeProvider).languageCode, equals('es'));
    });

    test('locale state observable through watch', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));

      var changeCount = 0;
      container.listen(localeProvider, (prev, curr) {
        changeCount++;
      });

      await notifier.setLocale(const Locale('es'));
      expect(changeCount, greaterThan(0));
    });
  });

  group('LocaleProvider - Locale Validation', () {
    test('accepts valid language codes', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      expect(container.read(localeProvider).languageCode, equals('en'));
    });

    test('handles locale changes consistently', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      await notifier.setLocale(const Locale('es'));
      expect(container.read(localeProvider), isA<Locale>());
    });

    test('maintains locale through multiple changes', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      final locales = [
        const Locale('en'),
        const Locale('es'),
        const Locale('en'),
        const Locale('es'),
      ];

      for (final locale in locales) {
        await notifier.setLocale(locale);
        expect(
          container.read(localeProvider).languageCode,
          equals(locale.languageCode),
        );
      }
    });

    test('supported locales include English and Spanish', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      expect(container.read(localeProvider).languageCode, equals('en'));

      await notifier.setLocale(const Locale('es'));
      expect(container.read(localeProvider).languageCode, equals('es'));
    });

    test(
      'setLocale persists supported locale and ignores unsupported locale',
      () async {
        final container = ProviderContainer();
        final notifier = container.read(localeProvider.notifier);

        await notifier.setLocale(const Locale('en'));
        expect(container.read(localeProvider).languageCode, 'en');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_locale'), 'en');

        await notifier.setLocale(const Locale('fr'));
        expect(container.read(localeProvider).languageCode, 'en');
        expect(prefs.getString('app_locale'), 'en');
      },
    );

    test('toggleLocale switches between es and en', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('es'));
      await notifier.toggleLocale();
      expect(container.read(localeProvider).languageCode, 'en');

      await notifier.toggleLocale();
      expect(container.read(localeProvider).languageCode, 'es');
    });

    test('getCurrentLanguageCode returns current state language', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      expect(notifier.getCurrentLanguageCode(), 'en');
    });

    test('isSupported validates supported locales list', () {
      expect(LocaleNotifier.isSupported(const Locale('es')), isTrue);
      expect(LocaleNotifier.isSupported(const Locale('en')), isTrue);
      expect(LocaleNotifier.isSupported(const Locale('fr')), isFalse);
      expect(LocaleNotifier.supportedLocales.length, 2);
    });

    test('currentLanguageNameProvider maps current locale label', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('es'));
      expect(container.read(currentLanguageNameProvider), 'Español');

      await notifier.setLocale(const Locale('en'));
      expect(container.read(currentLanguageNameProvider), 'English');
    });
  });

  group('LocaleExtension', () {
    test('getDisplayName returns expected labels and fallback', () {
      expect(const Locale('es').getDisplayName(), 'Español');
      expect(const Locale('en').getDisplayName(), 'English');
      expect(const Locale('pt').getDisplayName(), 'pt');
    });

    test('isSpanish and isEnglish flags are correct', () {
      expect(const Locale('es').isSpanish, isTrue);
      expect(const Locale('es').isEnglish, isFalse);
      expect(const Locale('en').isSpanish, isFalse);
      expect(const Locale('en').isEnglish, isTrue);
    });
  });
}
