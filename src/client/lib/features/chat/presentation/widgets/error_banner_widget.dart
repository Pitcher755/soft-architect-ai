import 'package:flutter/material.dart';

/// Widget that displays error messages in a dismissible banner.
///
/// Provides user-friendly error notification with:
/// - Smooth animation entrance
/// - Auto-dismiss button
/// - Material Design error styling
class ErrorBannerWidget extends StatelessWidget {
  /// Creates a new ErrorBannerWidget.
  const ErrorBannerWidget({required this.message, this.onDismiss, super.key});

  /// Error message to display.
  final String message;

  /// Callback when banner is dismissed.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.error,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.error.withValues(alpha: 0.7),
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Error icon
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.error_outline, color: colorScheme.onError),
            ),
            // Error message
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onError,
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
                icon: Icon(Icons.close, color: colorScheme.onError),
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
}
