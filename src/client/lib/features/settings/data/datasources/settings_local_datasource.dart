import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for settings persistence using SharedPreferences.
///
/// Provides low-level access to read/write settings data as JSON.
/// This class is responsible for the technical details of storage,
/// while the repository handles business logic.
///
/// **Keys Namespace:** All keys use the `settings.*` prefix to avoid collisions.
///
/// Example usage:
/// ```dart
/// final dataSource = SettingsLocalDataSource();
/// await dataSource.saveSettings({
///   'userName': 'John Doe',
///   'language': 'en',
/// });
/// final data = await dataSource.loadSettings();
/// ```
class SettingsLocalDataSource {
  /// SharedPreferences key for storing settings JSON.
  static const String _kSettingsKey = 'settings.data';

  /// Loads settings data from SharedPreferences.
  ///
  /// Returns `null` if no settings exist yet (first launch).
  ///
  /// Throws:
  /// - [StorageReadException] if SharedPreferences access fails
  Future<Map<String, dynamic>?> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kSettingsKey);

      if (jsonString == null) {
        return null; // First launch, no settings yet
      }

      // Parse JSON string (already a string, need to decode)
      // NOTE: SharedPreferences doesn't store complex objects directly,
      // so we need to serialize/deserialize manually
      return _decodeJson(jsonString);
    } catch (e) {
      throw StorageReadException('Failed to load settings: $e');
    }
  }

  /// Saves settings data to SharedPreferences.
  ///
  /// Completely overwrites existing settings.
  ///
  /// Throws:
  /// - [StorageWriteException] if SharedPreferences access fails
  Future<void> saveSettings(Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = _encodeJson(json);

      final success = await prefs.setString(_kSettingsKey, jsonString);
      if (!success) {
        throw const StorageWriteException('Failed to save settings to SharedPreferences');
      }
    } catch (e) {
      throw StorageWriteException('Failed to save settings: $e');
    }
  }

  /// Clears all settings from SharedPreferences.
  ///
  /// Useful for testing or resetting the application.
  ///
  /// Throws:
  /// - [StorageWriteException] if SharedPreferences access fails
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSettingsKey);
    } catch (e) {
      throw StorageWriteException('Failed to clear settings: $e');
    }
  }

  /// Encodes a JSON map to a string using dart:convert.
  String _encodeJson(Map<String, dynamic> json) => jsonEncode(json);

  /// Decodes a JSON string to a map using dart:convert.
  Map<String, dynamic> _decodeJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      throw StorageReadException('Failed to decode JSON: $e');
    }
  }
}

/// Exception thrown when reading from storage fails.
class StorageReadException implements Exception {
  /// Creates a [StorageReadException] with the given message.
  const StorageReadException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'StorageReadException: $message';
}

/// Exception thrown when writing to storage fails.
class StorageWriteException implements Exception {
  /// Creates a [StorageWriteException] with the given message.
  const StorageWriteException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'StorageWriteException: $message';
}
