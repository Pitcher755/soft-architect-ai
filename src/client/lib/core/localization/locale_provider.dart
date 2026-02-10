/// Locale provider for managing application language preferences.
///
/// This module provides Riverpod state management for the application's
/// current locale and persists the user's language selection to
/// SharedPreferences for restoration across app sessions.
///
/// Author: ArchitectZero
/// Created: 2026-02-10
///
/// Example:
/// ```dart
/// // Watch current locale
/// final locale = ref.watch(localeProvider);
///
/// // Change locale
/// ref.read(localeProvider.notifier).setLocale(Locale('es'));
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for locale state management using StateNotifier.
///
/// Returns the currently selected locale for the application.
/// Persists selection to SharedPreferences.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

/// Provider for human-readable current language name.
///
/// Returns the English or Spanish name of the current language based
/// on the current locale.
final currentLanguageNameProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'es' ? 'Español' : 'English';
});

/// State notifier for managing locale changes and persistence.
///
/// Handles:
/// - Initializing locale from SharedPreferences
/// - Changing locale and persisting selection
/// - Notifying listeners of locale changes
/// - Supporting multiple locales (currently EN/ES)
class LocaleNotifier extends StateNotifier<Locale> {
  /// Initialize with default locale
  LocaleNotifier() : super(_defaultLocale) {
    _loadSavedLocale();
  }

  /// Key for SharedPreferences storage
  static const String _localeKey = 'app_locale';

  /// Default locale fallback
  static const Locale _defaultLocale = Locale('es');

  /// List of supported locales
  static const List<Locale> supportedLocales = [Locale('en'), Locale('es')];

  /// Load previously saved locale from SharedPreferences.
  ///
  /// If no saved locale exists or if there's an error reading preferences,
  /// falls back to English (en).
  ///
  /// Called automatically during initialization.
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey) ?? 'es';

      // Validate locale is supported
      if (languageCode == 'es') {
        state = const Locale('es');
      } else {
        state = const Locale('en');
      }

      debugPrint('✅ Locale loaded: $languageCode');
    } catch (e) {
      debugPrint('⚠️ Error loading locale preference: $e');
      state = _defaultLocale;
    }
  }

  /// Change the application locale and persist to storage.
  ///
  /// Updates the current state and saves the selection to SharedPreferences
  /// for restoration on next session.
  ///
  /// Args:
  ///   - newLocale: The new locale to switch to
  ///
  /// Throws:
  ///   - Exception: If SharedPreferences write fails
  ///
  /// Example:
  /// ```dart
  /// final notifier = ref.read(localeProvider.notifier);
  /// await notifier.setLocale(Locale('es'));
  /// ```
  Future<void> setLocale(Locale newLocale) async {
    // Validate locale is supported
    if (!supportedLocales.contains(newLocale)) {
      return;
    }

    try {
      // Update state (triggers UI rebuild)
      state = newLocale;

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);

      debugPrint('✅ Locale changed and persisted: ${newLocale.languageCode}');
    } catch (e) {
      debugPrint('❌ Error saving locale preference: $e');
      rethrow;
    }
  }

  /// Get the current locale language code.
  ///
  /// Returns:
  ///   - 'en' for English
  ///   - 'es' for Spanish
  ///
  /// Example:
  /// ```dart
  /// final code = ref.read(localeProvider).languageCode;
  /// print(code); // 'en' or 'es'
  /// ```
  String getCurrentLanguageCode() => state.languageCode;

  /// Check if a locale is supported.
  ///
  /// Args:
  ///   - locale: Locale to check
  ///
  /// Returns:
  ///   - true if supported, false otherwise
  static bool isSupported(Locale locale) => supportedLocales.contains(locale);

  void toggleLocale() {}
}

/// Extension on Locale for convenience methods.
extension LocaleExtension on Locale {
  /// Get human-readable name for the locale.
  ///
  /// Returns:
  ///   - 'English' for en
  ///   - 'Español' for es
  ///   - locale code as fallback
  String getDisplayName() {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }

  /// Check if this is the Spanish locale.
  bool get isSpanish => languageCode == 'es';

  /// Check if this is the English locale.
  bool get isEnglish => languageCode == 'en';
}
