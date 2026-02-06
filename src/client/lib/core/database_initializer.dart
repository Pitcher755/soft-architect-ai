/// Database Initialization for SoftArchitect AI Flutter Client.
///
/// Simplified initialization that delegates platform-specific logic
/// to Riverpod providers.
///
/// Architecture: Client-First + Platform-Aware Providers
///   - Web: MockProjectRepository (in-memory, no dart:io)
///   - Desktop: ProjectRepositoryImpl delegated to project_providers.dart
///   - All database operations are local-only
///   - Frontend is the Single Source of Truth for project state
library;

import 'package:flutter/foundation.dart';

late final bool isWeb;
bool _isWebInitialized = false;

/// Initialize platform detection and logging.
///
/// This function should be called in main() before runApp().
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeSqfliteForDesktop();
///   runApp(const SoftArchitectApp());
/// }
/// ```
///
/// NOTE: Actual repository initialization is handled by Riverpod providers
/// in project_providers.dart which safely detect Platform APIs.
Future<void> initializeSqfliteForDesktop() async {
  // Prevent re-initialization in tests (late field can only be set once)
  if (_isWebInitialized) {
    return;
  }

  isWeb = kIsWeb;
  _isWebInitialized = true;

  if (kIsWeb) {
    debugPrint('ℹ️  Web platform detected - using MockProjectRepository');
  } else {
    debugPrint(
      'ℹ️  Desktop platform detected - using platform-aware providers',
    );
  }
}

/// Verify database initialization status.
///
/// Returns a status message for debugging purposes.
String getDatabaseInitStatus() {
  if (isWeb) {
    return 'ℹ️  Web platform - MockProjectRepository active';
  } else {
    return '✅ Desktop platform - project_providers handling '
        'repository selection';
  }
}
