import 'package:flutter/material.dart';

/// Optimized widget for rendering streaming messages.
///
/// Performance optimizations:
/// - RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - Minimal widget rebuilds
class StreamingMessageWidget extends StatelessWidget {
  const StreamingMessageWidget({
    required this.text,
    super.key,
    this.isStreaming = false,
  });

  /// Message text content.
  final String text;

  /// Flag indicating if message is still streaming.
  final bool isStreaming;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          if (isStreaming)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    ),
  );
}
