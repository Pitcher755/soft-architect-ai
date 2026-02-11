/// Theme preference options for the application.
///
/// Supports dark, light, and system-based themes.
/// System theme follows the OS's dark/light mode setting.
///
/// Example:
/// ```dart
/// final userTheme = ThemePreference.dark;
/// final themeData = userTheme == ThemePreference.dark
///     ? ThemeData.dark()
///     : ThemeData.light();
/// ```
enum ThemePreference {
  /// Dark theme (high contrast, easier on eyes in low light)
  dark,

  /// Light theme (high readability, suitable for bright environments)
  light,

  /// System theme (follows OS preference)
  system;

  /// Returns a human-readable display name.
  ///
  /// - `dark` → "Dark Mode 🌙"
  /// - `light` → "Light Mode ☀️"
  /// - `system` → "System Default ⚙️"
  String get displayName {
    switch (this) {
      case ThemePreference.dark:
        return 'Dark Mode 🌙';
      case ThemePreference.light:
        return 'Light Mode ☀️';
      case ThemePreference.system:
        return 'System Default ⚙️';
    }
  }

  /// Returns the icon emoji for this theme.
  ///
  /// - `dark` → "🌙"
  /// - `light` → "☀️"
  /// - `system` → "⚙️"
  String get iconEmoji {
    switch (this) {
      case ThemePreference.dark:
        return '🌙';
      case ThemePreference.light:
        return '☀️';
      case ThemePreference.system:
        return '⚙️';
    }
  }

  /// Creates a [ThemePreference] from a string value.
  ///
  /// Returns [ThemePreference.dark] if the value is unrecognized.
  ///
  /// Example:
  /// ```dart
  /// final pref = ThemePreference.fromString('light'); // returns ThemePreference.light
  /// ```
  static ThemePreference fromString(String value) => ThemePreference.values.firstWhere(
      (pref) => pref.name == value,
      orElse: () => ThemePreference.dark,
    );
}
