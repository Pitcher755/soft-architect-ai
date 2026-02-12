import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/gen/app_localizations.dart';
import 'package:softarchitect_ai/gen/app_localizations_en.dart';
import 'package:softarchitect_ai/gen/app_localizations_es.dart';

void main() {
  group('AppLocalizations Localization Delegate', () {
    test('delegate supports English locale', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), true);
    });

    test('delegate supports Spanish locale', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('es')), true);
    });

    test('should load English localization', () async {
      final localization = await AppLocalizations.delegate.load(
        const Locale('en'),
      );
      expect(localization, isA<AppLocalizations>());
    });

    test('should load Spanish localization', () async {
      final localization = await AppLocalizations.delegate.load(
        const Locale('es'),
      );
      expect(localization, isA<AppLocalizations>());
    });

    test('delegate is not null', () {
      expect(AppLocalizations.delegate, isNotNull);
    });

    test('delegate is LocalizationsDelegate', () {
      expect(AppLocalizations.delegate, isA<LocalizationsDelegate>());
    });

    test('supported locales are not empty', () {
      expect(AppLocalizations.supportedLocales, isNotEmpty);
    });

    test('supported locales contain English', () {
      final supported = AppLocalizations.supportedLocales;
      final hasEnglish = supported.any((locale) => locale.languageCode == 'en');
      expect(hasEnglish, true);
    });

    test('supported locales contain Spanish', () {
      final supported = AppLocalizations.supportedLocales;
      final hasSpanish = supported.any((locale) => locale.languageCode == 'es');
      expect(hasSpanish, true);
    });
  });

  group('AppLocalizations instance', () {
    late AppLocalizations localeEn;
    late AppLocalizations localeEs;
    late Locale localeEnObj;
    late Locale localeEsObj;

    setUpAll(() async {
      localeEnObj = const Locale('en');
      localeEsObj = const Locale('es');
      localeEn = await AppLocalizations.delegate.load(localeEnObj);
      localeEs = await AppLocalizations.delegate.load(localeEsObj);
    });

    test('English instance returns correct locale', () {
      expect(localeEnObj.languageCode, equals('en'));
    });

    test('Spanish instance returns correct locale', () {
      expect(localeEsObj.languageCode, equals('es'));
    });

    test('instances are different for different locales', () {
      expect(localeEnObj, isNot(localeEsObj));
    });

    test('English and Spanish instances are both AppLocalizations', () {
      expect(localeEn, isA<AppLocalizations>());
      expect(localeEs, isA<AppLocalizations>());
    });
  });

  group('AppLocalizations Fallback Handling', () {
    test('unsupported locale is not supported and throws on load', () async {
      expect(
        AppLocalizations.delegate.isSupported(const Locale('fr')),
        isFalse,
      );

      await expectLater(
        () => AppLocalizations.delegate.load(const Locale('fr')),
        throwsA(isA<FlutterError>()),
      );
    });

    test('null country code is handled', () {
      const locale = Locale('en');
      final result = AppLocalizations.delegate.isSupported(locale);
      expect(result, isTrue);
    });

    test('with country code is handled', () {
      const locale = Locale('es', 'ES');
      final result = AppLocalizations.delegate.isSupported(locale);
      expect(result, true);
    });

    test('EN and ES generated classes expose expected strings', () {
      final en = AppLocalizationsEn();
      final es = AppLocalizationsEs();

      final values = <String>[
        en.appTitle,
        en.projectsPageTitle,
        en.newProjectButton,
        en.deleteProjectButton,
        en.deleteProjectConfirm('X'),
        en.settingsPageTitle,
        en.settingsLanguageLabel,
        en.selectLanguage,
        en.languageEnglish,
        en.languageSpanish,
        en.chatPageTitle,
        en.sendMessage,
        en.clearHistory,
        en.newChat,
        en.errorLoadingProject,
        en.errorLoadingProjects,
        en.cancel,
        en.save,
        en.edit,
        en.close,
        en.confirmed,
        en.loading,
        en.empty,
        en.createProject,
        en.browse,
        en.validateAndSave,
        en.refine,
        en.reject,
        en.fileSaved('/tmp/a'),
        en.contentCopied,
        en.saveError('x'),
        en.loadingProjects,
        en.today,
        en.yesterday,
        en.daysAgo(3),
        en.languageTitle,
        en.languageInterfaceTitle,
        en.languageInterfaceSubtitle,
        en.storageTitle,
        en.storageProjectDirTitle,
        en.storageProjectDirSubtitle,
        en.changeDirectory,
        en.directoryUpdated('/tmp'),
        en.errorSelectingDirectory('e'),
        en.folderAlreadyExists,
        en.workspaceSectionTitle,
        en.workspaceSubtitle,
        en.myProjects,
        en.guideTitle,
        en.guideDescription,
        en.guideSteps,
        en.guideFeatures,
        en.chatIATitle,
        en.chatIADescription,
        en.projectAlpha,
        en.projectContext,
        en.projectArchitecture,
        en.projectImplementation,
        en.projectQuality,
        en.projectDocumentation,
        en.spanish,
        en.english,
        en.avatarUpdated,
        en.avatarUpdateError('e'),
        en.profileTitle,
        en.nameTitle,
        en.avatarTitle,
        en.appearanceTitle,
        en.themeModeTitle,
        en.darkMode,
        en.lightMode,
        en.systemMode,
        en.fontSizeTitle,
        en.accessibilityTitle,
        en.zoomTitle,
        en.enableZoomShortcuts,
        en.performanceTitle,
        en.enableAnimations,
        en.enableMemoryOptimization,
        en.themeModeSubtitle,
        en.fontSizeSubtitle,
        en.zoomSubtitle,
        en.settingsTitle,
        en.settingsSubtitle,
        es.appTitle,
        es.projectsPageTitle,
        es.newProjectButton,
        es.deleteProjectButton,
        es.deleteProjectConfirm('X'),
        es.settingsPageTitle,
        es.settingsLanguageLabel,
        es.selectLanguage,
        es.languageEnglish,
        es.languageSpanish,
        es.chatPageTitle,
        es.sendMessage,
        es.clearHistory,
        es.newChat,
        es.errorLoadingProject,
        es.errorLoadingProjects,
        es.cancel,
        es.save,
        es.edit,
        es.close,
        es.confirmed,
        es.loading,
        es.empty,
        es.createProject,
        es.browse,
        es.validateAndSave,
        es.refine,
        es.reject,
        es.fileSaved('/tmp/a'),
        es.contentCopied,
        es.saveError('x'),
        es.loadingProjects,
        es.today,
        es.yesterday,
        es.daysAgo(3),
        es.languageTitle,
        es.languageInterfaceTitle,
        es.languageInterfaceSubtitle,
        es.storageTitle,
        es.storageProjectDirTitle,
        es.storageProjectDirSubtitle,
        es.changeDirectory,
        es.directoryUpdated('/tmp'),
        es.errorSelectingDirectory('e'),
        es.folderAlreadyExists,
        es.workspaceSectionTitle,
        es.workspaceSubtitle,
        es.myProjects,
        es.guideTitle,
        es.guideDescription,
        es.guideSteps,
        es.guideFeatures,
        es.chatIATitle,
        es.chatIADescription,
        es.projectAlpha,
        es.projectContext,
        es.projectArchitecture,
        es.projectImplementation,
        es.projectQuality,
        es.projectDocumentation,
        es.spanish,
        es.english,
        es.avatarUpdated,
        es.avatarUpdateError('e'),
        es.profileTitle,
        es.nameTitle,
        es.avatarTitle,
        es.appearanceTitle,
        es.themeModeTitle,
        es.darkMode,
        es.lightMode,
        es.systemMode,
        es.fontSizeTitle,
        es.accessibilityTitle,
        es.zoomTitle,
        es.enableZoomShortcuts,
        es.performanceTitle,
        es.enableAnimations,
        es.enableMemoryOptimization,
        es.themeModeSubtitle,
        es.fontSizeSubtitle,
        es.zoomSubtitle,
        es.settingsTitle,
        es.settingsSubtitle,
      ];

      expect(values.every((v) => v.isNotEmpty), isTrue);
    });
  });
}
