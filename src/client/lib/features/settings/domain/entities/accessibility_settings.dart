import 'package:flutter/foundation.dart';

/// Accessibility settings for the application.
///
/// Immutable value object containing all accessibility-related preferences
/// such as font size, high contrast mode, and screen reader support.
///
/// Example:
/// ```dart
/// final settings = AccessibilitySettings(
///   fontSize: 16.0,
///   highContrast: false,
///   screenReaderEnabled: false,
/// );
/// ```
@immutable
class AccessibilitySettings {

  /// Creates a default [AccessibilitySettings] with standard values.
  ///
  /// Suitable for users without specific accessibility needs.
  factory AccessibilitySettings.defaultSettings() {
    return const AccessibilitySettings();
  }

  /// Creates an [AccessibilitySettings] from a JSON map.
  ///
  /// Returns default settings if JSON is invalid or missing fields.
  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      highContrast: json['highContrast'] as bool? ?? false,
      screenReaderEnabled: json['screenReaderEnabled'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }
  /// Creates an [AccessibilitySettings] instance.
  ///
  /// All parameters have sensible defaults for standard accessibility.
  const AccessibilitySettings({
    this.fontSize = 14.0,
    this.highContrast = false,
    this.screenReaderEnabled = false,
    this.reducedMotion = false,
  });

  /// Base font size for UI text (in logical pixels).
  ///
  /// Range: 10.0 - 24.0 (default: 14.0)
  /// Larger values improve readability for users with vision impairments.
  final double fontSize;

  /// Enables high contrast mode for better visibility.
  ///
  /// When enabled, increases color contrast ratios to meet WCAG AAA standards.
  /// Useful for users with low vision or color blindness.
  final bool highContrast;

  /// Enables screen reader compatibility mode.
  ///
  /// When enabled, adds semantic labels to all interactive elements
  /// for better integration with OS-level screen readers (TalkBack, VoiceOver).
  final bool screenReaderEnabled;

  /// Reduces or disables animations and transitions.
  ///
  /// When enabled, minimizes motion effects to reduce vestibular disorders
  /// or motion sensitivity issues.
  final bool reducedMotion;

  /// Creates a copy of this settings with optional overrides.
  ///
  /// Example:
  /// ```dart
  /// final newSettings = settings.copyWith(fontSize: 18.0);
  /// ```
  AccessibilitySettings copyWith({
    double? fontSize,
    bool? highContrast,
    bool? screenReaderEnabled,
    bool? reducedMotion,
  }) => AccessibilitySettings(
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );

  /// Converts this settings object to a JSON map.
  ///
  /// Used for serialization to storage (SharedPreferences, JSON files).
  Map<String, dynamic> toJson() => {
      'fontSize': fontSize,
      'highContrast': highContrast,
      'screenReaderEnabled': screenReaderEnabled,
      'reducedMotion': reducedMotion,
    };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilitySettings &&
          runtimeType == other.runtimeType &&
          fontSize == other.fontSize &&
          highContrast == other.highContrast &&
          screenReaderEnabled == other.screenReaderEnabled &&
          reducedMotion == other.reducedMotion;

  @override
  int get hashCode =>
      fontSize.hashCode ^
      highContrast.hashCode ^
      screenReaderEnabled.hashCode ^
      reducedMotion.hashCode;

  @override
  String toString() => 'AccessibilitySettings('
        'fontSize: $fontSize, '
        'highContrast: $highContrast, '
        'screenReaderEnabled: $screenReaderEnabled, '
        'reducedMotion: $reducedMotion'
        ')';
}
