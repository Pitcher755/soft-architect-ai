import 'package:flutter/foundation.dart';

import 'accessibility_settings.dart';
import 'language_preference.dart';
import 'performance_settings.dart';
import 'theme_preference.dart';

/// Main settings entity aggregating all user preferences.
///
/// Immutable domain entity following Clean Architecture principles.
/// Contains user profile, storage, appearance, accessibility, and performance settings.
///
/// This entity is **pure business logic** with no dependencies on Flutter UI,
/// databases, or external packages (except for @immutable annotation).
///
/// Example:
/// ```dart
/// final settings = SettingsEntity(
///   userName: 'John Doe',
///   email: 'john@example.com',
///   language: LanguagePreference.en,
///   theme: ThemePreference.dark,
/// );
/// ```
@immutable
class SettingsEntity {
  /// Creates a [SettingsEntity] instance.
  ///
  /// All parameters have sensible defaults for first-time users.
  const SettingsEntity({
    this.userName = '',
    this.email = '',
    this.avatarUrl,
    this.storagePath = '',
    this.language = LanguagePreference.en,
    this.theme = ThemePreference.dark,
    this.accessibility = const AccessibilitySettings(),
    this.performance = const PerformanceSettings(),
  });

  // ============================================================================
  // FACTORY CONSTRUCTORS
  // ============================================================================

  /// Creates default settings for a new user.
  ///
  /// Uses sensible defaults for all fields.
  factory SettingsEntity.defaultSettings() => const SettingsEntity();

  /// Creates a [SettingsEntity] from a JSON map.
  ///
  /// Returns default settings if JSON is invalid or missing fields.
  factory SettingsEntity.fromJson(Map<String, dynamic> json) => SettingsEntity(
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      storagePath: json['storagePath'] as String? ?? '',
      language: LanguagePreference.fromLocaleCode(
        json['language'] as String? ?? 'en',
      ),
      theme: ThemePreference.fromString(json['theme'] as String? ?? 'dark'),
      accessibility: json['accessibility'] != null
          ? AccessibilitySettings.fromJson(
              json['accessibility'] as Map<String, dynamic>,
            )
          : const AccessibilitySettings(),
      performance: json['performance'] != null
          ? PerformanceSettings.fromJson(
              json['performance'] as Map<String, dynamic>,
            )
          : const PerformanceSettings(),
    );

  // ============================================================================
  // USER PROFILE
  // ============================================================================

  /// User's display name.
  ///
  /// Used in UI headers and profile sections.
  /// Empty string if not configured.
  final String userName;

  /// User's email address.
  ///
  /// Used for identification and potential future features (e.g., cloud sync).
  /// Empty string if not configured.
  final String email;

  /// URL or local path to user's avatar image.
  ///
  /// Null if no avatar set (use default placeholder).
  final String? avatarUrl;

  // ============================================================================
  // STORAGE
  // ============================================================================

  /// Default storage path for project files and databases.
  ///
  /// Should be a valid directory path on the local filesystem.
  /// Empty string if not configured (uses app default directory).
  final String storagePath;

  // ============================================================================
  // APPEARANCE
  // ===========================================================================

  /// Preferred language for UI and content.
  ///
  /// Controls localization throughout the app.
  final LanguagePreference language;

  /// Preferred theme (dark, light, or system).
  ///
  /// Controls the visual appearance and color scheme.
  final ThemePreference theme;

  // ===========================================================================
  // ACCESSIBILITY
  // ===========================================================================

  /// Accessibility-related settings.
  ///
  /// Includes font size, high contrast, screen reader support, etc.
  final AccessibilitySettings accessibility;

  // ===========================================================================
  // PERFORMANCE
  // ===========================================================================

  /// Performance-related settings.
  ///
  /// Includes cache limits, memory management, optimization flags.
  final PerformanceSettings performance;

  // ==========================================================================
  // VALUE OBJECT METHODS
  // ===========================================================================

  /// Creates a copy of this entity with optional overrides.
  ///
  /// Example:
  /// ```dart
  /// final updated = settings.copyWith(userName: 'Jane Doe');
  /// ```
  SettingsEntity copyWith({
    String? userName,
    String? email,
    String? avatarUrl,
    String? storagePath,
    LanguagePreference? language,
    ThemePreference? theme,
    AccessibilitySettings? accessibility,
    PerformanceSettings? performance,
  }) => SettingsEntity(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storagePath: storagePath ?? this.storagePath,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      accessibility: accessibility ?? this.accessibility,
      performance: performance ?? this.performance,
    );

  /// Converts this entity to a JSON map.
  ///
  /// Used for serialization to storage (via DTOs in the data layer).
  Map<String, dynamic> toJson() => {
      'userName': userName,
      'email': email,
      'avatarUrl': avatarUrl,
      'storagePath': storagePath,
      'language': language.localeCode,
      'theme': theme.name,
      'accessibility': accessibility.toJson(),
      'performance': performance.toJson(),
    };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsEntity &&
          runtimeType == other.runtimeType &&
          userName == other.userName &&
          email == other.email &&
          avatarUrl == other.avatarUrl &&
          storagePath == other.storagePath &&
          language == other.language &&
          theme == other.theme &&
          accessibility == other.accessibility &&
          performance == other.performance;

  @override
  int get hashCode =>
      userName.hashCode ^
      email.hashCode ^
      avatarUrl.hashCode ^
      storagePath.hashCode ^
      language.hashCode ^
      theme.hashCode ^
      accessibility.hashCode ^
      performance.hashCode;

  @override
  String toString() => 'SettingsEntity('
        'userName: $userName, '
        'email: $email, '
        'avatarUrl: $avatarUrl, '
        'storagePath: $storagePath, '
        'language: ${language.displayName}, '
        'theme: ${theme.displayName}, '
        'accessibility: $accessibility, '
        'performance: $performance'
        ')';
}
