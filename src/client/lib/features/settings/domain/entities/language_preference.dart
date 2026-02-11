/// Language preference options for the application.
///
/// Supports English and Spanish locales.
/// Used throughout the app for UI localization and content display.
///
/// Example:
/// ```dart
/// final userLang = LanguagePreference.es;
/// if (userLang == LanguagePreference.en) {
///   print('Welcome!');
/// } else {
///   print('¡Bienvenido!');
/// }
/// ```
enum LanguagePreference {
  /// English locale (en_US)
  en,

  /// Spanish locale (es_ES)
  es;

  /// Returns the locale code for this preference.
  ///
  /// Example: `LanguagePreference.en.localeCode` returns `'en'`
  String get localeCode => name;

  /// Returns a human-readable display name.
  ///
  /// - `en` → "English 🇬🇧"
  /// - `es` → "Español 🇪🇸"
  String get displayName {
    switch (this) {
      case LanguagePreference.en:
        return 'English 🇬🇧';
      case LanguagePreference.es:
        return 'Español 🇪🇸';
    }
  }

  /// Returns the flag emoji for this language.
  ///
  /// - `en` → "🇬🇧"
  /// - `es` → "🇪🇸"
  String get flagEmoji {
    switch (this) {
      case LanguagePreference.en:
        return '🇬🇧';
      case LanguagePreference.es:
        return '🇪🇸';
    }
  }

  /// Creates a [LanguagePreference] from a locale code string.
  ///
  /// Returns [LanguagePreference.en] if the code is unrecognized.
  ///
  /// Example:
  /// ```dart
  /// final pref = LanguagePreference.fromLocaleCode('es'); // returns LanguagePreference.es
  /// ```
  static LanguagePreference fromLocaleCode(String code) {
    return LanguagePreference.values.firstWhere(
      (pref) => pref.localeCode == code,
      orElse: () => LanguagePreference.en,
    );
  }
}
