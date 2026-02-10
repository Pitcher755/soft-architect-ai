// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SoftArchitect AI';

  @override
  String get projectsPageTitle => 'Projects';

  @override
  String get newProjectButton => 'New Project';

  @override
  String get deleteProjectButton => 'Delete';

  @override
  String deleteProjectConfirm(String projectName) {
    return 'Are you sure you want to delete \'$projectName\'?';
  }

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get chatPageTitle => 'AI Chat';

  @override
  String get sendMessage => 'Send';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get newChat => 'New Chat';

  @override
  String get errorLoadingProject => 'Error loading project';

  @override
  String get errorLoadingProjects => 'Error loading projects';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get loading => 'Loading...';

  @override
  String get empty => 'No items';

  @override
  String get createProject => 'Create Project';

  @override
  String get browse => 'Browse...';

  @override
  String get validateAndSave => 'Validate & Save';

  @override
  String get refine => 'Refine';

  @override
  String get reject => 'Reject';

  @override
  String fileSaved(String outputFile) {
    return 'File saved to: $outputFile';
  }

  @override
  String get contentCopied => 'Content copied to clipboard';

  @override
  String saveError(String error) {
    return 'Save error: $error';
  }
}
