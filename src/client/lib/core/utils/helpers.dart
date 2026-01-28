import 'package:flutter/material.dart';

/// Helper utilities for the application.
/// Pure functions without side effects.

/// Validates if a string is a valid email.
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

/// Truncates a string to a maximum length, adding ellipsis if needed.
String truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

/// Debounces a function call, ignoring rapid subsequent calls.
class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  VoidCallback? _callback;

  void call(VoidCallback callback) {
    _callback = callback;
    Future.delayed(duration, () {
      if (_callback == callback) {
        callback();
      }
    });
  }
}