import 'package:flutter/material.dart';

/// Widget that displays error messages in a dismissible banner.
///
/// Provides user-friendly error notification with:
/// - Smooth animation entrance
/// - Auto-dismiss button
/// - Material Design error styling
class ErrorBannerWidget extends StatelessWidget {
  /// Creates a new ErrorBannerWidget.
  const ErrorBannerWidget({
    required this.message,
    this.onDismiss,
    super.key,
  });

  /// Error message to display.
  final String message;

  /// Callback when banner is dismissed.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red[900],
          border: Border(
            bottom: BorderSide(color: Colors.red[700]!, width: 2),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Error icon
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.error_outline, color: Colors.white),
            ),
            // Error message
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Dismiss button
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
                tooltip: 'Dismiss error',
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
}
