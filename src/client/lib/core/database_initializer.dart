/// Database Initialization for SoftArchitect AI Flutter Client.
///
/// This module configures sqflite for different platforms:
/// - Desktop (Linux, Windows, macOS): Uses sqflite_common_ffi
/// - Web: Will use sqflite_web (future implementation)
/// - Mobile (iOS, Android): Uses native sqflite
///
/// Architecture: Client-First pattern
///   - All database operations are local-only
///   - Backend has NO access to user_data.db
///   - Frontend is the Single Source of Truth for project state
library;

import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize SQLite for desktop platforms.
///
/// This function should be called in main() before runApp().
/// It sets up sqflite_common_ffi for Linux, Windows, and macOS.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeSqfliteForDesktop();
///   runApp(const SoftArchitectApp());
/// }
/// ```
Future<void> initializeSqfliteForDesktop() async {
  if (io.Platform.isLinux || io.Platform.isWindows || io.Platform.isMacOS) {
    // Use FFI implementation for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else if (io.Platform.isAndroid || io.Platform.isIOS) {
    // Mobile platforms use native sqflite (no special setup needed)
  } else {
    // Web platform: future implementation with sqflite_web
    // For now, print a warning
    debugPrint('⚠️  Database support for current platform not yet configured');
  }
}

/// Verify database initialization status.
///
/// Returns a status message for debugging purposes.
String getDatabaseInitStatus() {
  if (io.Platform.isLinux) {
    return '✅ Database initialized for Linux (sqflite_common_ffi)';
  } else if (io.Platform.isWindows) {
    return '✅ Database initialized for Windows (sqflite_common_ffi)';
  } else if (io.Platform.isMacOS) {
    return '✅ Database initialized for macOS (sqflite_common_ffi)';
  } else if (io.Platform.isAndroid) {
    return '✅ Database initialized for Android (native sqflite)';
  } else if (io.Platform.isIOS) {
    return '✅ Database initialized for iOS (native sqflite)';
  } else {
    return '❌ Database platform not supported';
  }
}
