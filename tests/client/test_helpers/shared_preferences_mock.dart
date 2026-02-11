/// Test helper for SharedPreferences mocking.
///
/// Encapsulates the usage of @visibleForTesting APIs to avoid warnings
/// in test files.
library;

// ignore_for_file: invalid_use_of_visible_for_testing_member

// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes mock SharedPreferences with given values.
///
/// This is a wrapper around SharedPreferences.setMockInitialValues()
/// to centralize the suppression of @visibleForTesting warnings.
void initMockSharedPreferences(Map<String, Object> values) {
  SharedPreferences.setMockInitialValues(values);
}
