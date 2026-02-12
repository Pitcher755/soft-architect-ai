import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SoftArchitect AI'**
  String get appTitle;

  /// Title of the projects list page
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsPageTitle;

  /// Button label for creating a new project
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProjectButton;

  /// Button label for deleting a project
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteProjectButton;

  /// Confirmation message for project deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{projectName}\'?'**
  String deleteProjectConfirm(String projectName);

  /// Title of the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// Label for language selection in settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// Dialog title for language selection
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language name: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language name: Spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// Title of the chat interface
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get chatPageTitle;

  /// Button label for sending a message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// Button label for clearing chat history
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Button label for starting a new chat
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// Error message when project fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading project'**
  String get errorLoadingProject;

  /// Error message when projects list fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading projects'**
  String get errorLoadingProjects;

  /// Button label for canceling an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button label for saving changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button label for editing
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button label for closing a dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Confirmation message
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// Loading indicator message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get empty;

  /// Button label for creating a new project
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// Button label for browsing files/directories
  ///
  /// In en, this message translates to:
  /// **'Browse...'**
  String get browse;

  /// Button label for validating and saving content
  ///
  /// In en, this message translates to:
  /// **'Validate & Save'**
  String get validateAndSave;

  /// Button label for refining content
  ///
  /// In en, this message translates to:
  /// **'Refine'**
  String get refine;

  /// Button label for rejecting content
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Success message when file is saved
  ///
  /// In en, this message translates to:
  /// **'File saved to: {outputFile}'**
  String fileSaved(String outputFile);

  /// Success message when content is copied
  ///
  /// In en, this message translates to:
  /// **'Content copied to clipboard'**
  String get contentCopied;

  /// Error message when save fails
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String saveError(String error);

  /// Loading message for projects grid
  ///
  /// In en, this message translates to:
  /// **'Loading projects...'**
  String get loadingProjects;

  /// Relative date: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Relative date: yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Relative date: X days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// Settings section title for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Language setting item title
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get languageInterfaceTitle;

  /// Language setting item subtitle
  ///
  /// In en, this message translates to:
  /// **'Change application language'**
  String get languageInterfaceSubtitle;

  /// Settings section title for storage
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// Storage setting for project directory
  ///
  /// In en, this message translates to:
  /// **'Projects directory'**
  String get storageProjectDirTitle;

  /// Storage setting subtitle for project directory
  ///
  /// In en, this message translates to:
  /// **'Default location to save new projects'**
  String get storageProjectDirSubtitle;

  /// Tooltip for change directory button
  ///
  /// In en, this message translates to:
  /// **'Change directory'**
  String get changeDirectory;

  /// Success message when directory is updated
  ///
  /// In en, this message translates to:
  /// **'Directory updated: {path}'**
  String directoryUpdated(String path);

  /// Error message when directory selection fails
  ///
  /// In en, this message translates to:
  /// **'Error selecting directory: {error}'**
  String errorSelectingDirectory(String error);

  /// Error message when project folder already exists
  ///
  /// In en, this message translates to:
  /// **'A folder with that name already exists in the selected path'**
  String get folderAlreadyExists;

  /// Title for the workspace section
  ///
  /// In en, this message translates to:
  /// **'SoftArchitect AI Workspace'**
  String get workspaceSectionTitle;

  /// Subtitle/description for the workspace
  ///
  /// In en, this message translates to:
  /// **'Interactive workspace for document generation'**
  String get workspaceSubtitle;

  /// Header for the projects list section
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get myProjects;

  /// Guide section title
  ///
  /// In en, this message translates to:
  /// **'Welcome to SoftArchitect AI'**
  String get guideTitle;

  /// Guide section description
  ///
  /// In en, this message translates to:
  /// **'This is your interactive guide. Learn how to use the tool here.'**
  String get guideDescription;

  /// Guide steps text
  ///
  /// In en, this message translates to:
  /// **'Steps: 1. Create a project with the + button. 2. Select an empty folder. 3. Start creating.'**
  String get guideSteps;

  /// Guide features text
  ///
  /// In en, this message translates to:
  /// **'Key features: Analysis of Architecture, Live Documentation, AI Chat, Hybrid'**
  String get guideFeatures;

  /// Chat IA section title
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get chatIATitle;

  /// Chat IA description
  ///
  /// In en, this message translates to:
  /// **'The central panel allows you to talk to your documents.'**
  String get chatIADescription;

  /// Sample project name
  ///
  /// In en, this message translates to:
  /// **'PROJECT-ALPHA'**
  String get projectAlpha;

  /// Project context phase
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get projectContext;

  /// Project architecture phase
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get projectArchitecture;

  /// Project implementation phase
  ///
  /// In en, this message translates to:
  /// **'Implementation'**
  String get projectImplementation;

  /// Project quality phase
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get projectQuality;

  /// Project documentation phase
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get projectDocumentation;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Success message when avatar is updated
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully'**
  String get avatarUpdated;

  /// Error message when avatar selection fails
  ///
  /// In en, this message translates to:
  /// **'Error selecting avatar: {error}'**
  String avatarUpdateError(String error);

  /// Settings section title for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Label for user name input
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameTitle;

  /// Label for avatar selection
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatarTitle;

  /// Settings section title for appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Label for theme selection
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeModeTitle;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// Label for font size adjustment
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeTitle;

  /// Settings section title for accessibility
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityTitle;

  /// Label for zoom adjustment
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoomTitle;

  /// Toggle for zoom shortcut keys (Ctrl+, Ctrl-, Ctrl+0)
  ///
  /// In en, this message translates to:
  /// **'Enable zoom keyboard shortcuts'**
  String get enableZoomShortcuts;

  /// Settings section title for performance
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performanceTitle;

  /// Toggle for UI animations
  ///
  /// In en, this message translates to:
  /// **'Enable animations'**
  String get enableAnimations;

  /// Toggle for memory optimization features
  ///
  /// In en, this message translates to:
  /// **'Memory optimization'**
  String get enableMemoryOptimization;

  /// Subtitle for theme mode selection
  ///
  /// In en, this message translates to:
  /// **'Change between light and dark theme'**
  String get themeModeSubtitle;

  /// Subtitle for font size adjustment
  ///
  /// In en, this message translates to:
  /// **'Adjust text size across the application'**
  String get fontSizeSubtitle;

  /// Subtitle for global zoom adjustment
  ///
  /// In en, this message translates to:
  /// **'Adjust zoom for the entire application'**
  String get zoomSubtitle;

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Subtitle for the settings page
  ///
  /// In en, this message translates to:
  /// **'Customize your SoftArchitect AI experience'**
  String get settingsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
