import 'package:flutter/material.dart';

/// Service for displaying contextual snackbar notifications.
///
/// Provides different notification types with appropriate auto-hide behavior:
/// - Success/Info: Auto-hide after 5 seconds
/// - Error: Manual close required (never auto-hide)
/// - Retryable Error: Manual close required with retry action button
///
/// Example:
/// ```dart
/// final service = SnackbarService();
/// service.showSuccess(context, 'Document saved successfully');
/// service.showError(context, 'Connection failed', 'SYS_001');
/// ```
class SnackbarService {
  /// Show success notification (auto-hide after 5s).
  ///
  /// Use for successful operations like:
  /// - Document saved
  /// - Configuration updated
  /// - File uploaded
  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 5), // Auto-hide
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info notification (auto-hide after 5s).
  ///
  /// Use for informational messages like:
  /// - Processing started
  /// - Loading data
  /// - Status updates
  void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 5), // Auto-hide
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error notification (manual close required).
  ///
  /// Use for critical errors that require user acknowledgment.
  /// Never auto-hides - user must manually dismiss.
  ///
  /// Parameters:
  /// - [message]: User-friendly error message
  /// - [errorCode]: Technical error code for tracking
  void showError(BuildContext context, String message, String errorCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código: $errorCode',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(days: 365), // Never auto-hide
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show retryable error with action button.
  ///
  /// Use for transient errors that can be retried:
  /// - Network connection lost
  /// - Server temporarily unavailable
  /// - Resource temporarily locked
  ///
  /// Parameters:
  /// - [message]: User-friendly error message
  /// - [onRetry]: Callback function to execute when retry is pressed
  void showRetryableError(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(days: 365), // Never auto-hide
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onRetry();
          },
        ),
      ),
    );
  }
}
