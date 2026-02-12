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

  @override
  String get loadingProjects => 'Loading projects...';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageInterfaceTitle => 'Interface language';

  @override
  String get languageInterfaceSubtitle => 'Change application language';

  @override
  String get storageTitle => 'Storage';

  @override
  String get storageProjectDirTitle => 'Projects directory';

  @override
  String get storageProjectDirSubtitle =>
      'Default location to save new projects';

  @override
  String get changeDirectory => 'Change directory';

  @override
  String directoryUpdated(String path) {
    return 'Directory updated: $path';
  }

  @override
  String errorSelectingDirectory(String error) {
    return 'Error selecting directory: $error';
  }

  @override
  String get folderAlreadyExists =>
      'A folder with that name already exists in the selected path';

  @override
  String get workspaceSectionTitle => 'SoftArchitect AI Workspace';

  @override
  String get workspaceSubtitle =>
      'Interactive workspace for document generation';

  @override
  String get myProjects => 'My Projects';

  @override
  String get guideTitle => 'Welcome to SoftArchitect AI';

  @override
  String get guideDescription =>
      'This is your interactive guide. Learn how to use the tool here.';

  @override
  String get guideSteps =>
      'Steps: 1. Create a project with the + button. 2. Select an empty folder. 3. Start creating.';

  @override
  String get guideFeatures =>
      'Key features: Analysis of Architecture, Live Documentation, AI Chat, Hybrid';

  @override
  String get chatIATitle => 'AI Chat';

  @override
  String get chatIADescription =>
      'The central panel allows you to talk to your documents.';

  @override
  String get projectAlpha => 'PROJECT-ALPHA';

  @override
  String get projectContext => 'Context';

  @override
  String get projectArchitecture => 'Architecture';

  @override
  String get projectImplementation => 'Implementation';

  @override
  String get projectQuality => 'Quality';

  @override
  String get projectDocumentation => 'Documentation';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get avatarUpdated => 'Avatar updated successfully';

  @override
  String avatarUpdateError(String error) {
    return 'Error selecting avatar: $error';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get nameTitle => 'Full Name';

  @override
  String get avatarTitle => 'Avatar';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeModeTitle => 'Theme';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System';

  @override
  String get fontSizeTitle => 'Font Size';

  @override
  String get accessibilityTitle => 'Accessibility';

  @override
  String get zoomTitle => 'Zoom';

  @override
  String get enableZoomShortcuts => 'Enable zoom keyboard shortcuts';

  @override
  String get performanceTitle => 'Performance';

  @override
  String get enableAnimations => 'Enable animations';

  @override
  String get enableMemoryOptimization => 'Memory optimization';

  @override
  String get themeModeSubtitle => 'Change between light and dark theme';

  @override
  String get fontSizeSubtitle => 'Adjust text size across the application';

  @override
  String get zoomSubtitle => 'Adjust zoom for the entire application';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Customize your SoftArchitect AI experience';
}
