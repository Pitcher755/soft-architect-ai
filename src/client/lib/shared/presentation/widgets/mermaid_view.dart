import 'dart:convert';

import 'package:flutter/material.dart';

/// Widget that renders a Mermaid diagram by encoding it as a mermaid.ink URL.
///
/// Sanitizes the raw LLM output before encoding to prevent HTTP 400 errors
/// caused by malformed arrow syntax, then displays the result inline using
/// [Image.network].
///
/// On failure the error builder distinguishes two cases:
/// - **Network / service errors** (HTTP 503, 429, `SocketException`):
///   displays a `cloud_off` icon with "Diagram temporarily unavailable".
/// - **Syntax errors** (HTTP 400 or any other failure): displays a
///   `warning_amber` icon with "Invalid diagram syntax".
class MermaidView extends StatelessWidget {
  const MermaidView({required this.code, super.key});

  /// Raw Mermaid source code, typically extracted from a fenced code block.
  final String code;

  /// Returns [code] with common LLM-generated syntax errors corrected.
  String get _sanitizedCode => code
      .replaceAll(RegExp(r'\|>\s*'), '| ')
      .replaceAll(RegExp(r'(?<!-)−>\|'), '-->|')
      .replaceAll('->|', '-->|');

  /// Builds the mermaid.ink image URL from the sanitized Mermaid source.
  ///
  /// Encodes the source as a Base64 URL-safe JSON payload accepted by
  /// `https://mermaid.ink/img/<payload>`.
  String get _imageUrl {
    final jsonPayload = jsonEncode({
      'code': _sanitizedCode,
      'mermaid': {'theme': 'dark', 'backgroundColor': 'transparent'},
    });
    final bytes = utf8.encode(jsonPayload);
    final base64Str = base64UrlEncode(bytes).replaceAll('=', '');
    return 'https://mermaid.ink/img/$base64Str';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('MERMAID.INK error: $error');
          debugPrint('Attempted URL: $_imageUrl');

          // Distinguish network/rate-limit errors (503, 429, socket) from
          // genuine diagram syntax errors (HTTP 400 from mermaid.ink) so the
          // fallback message is accurate.
          // HTTP 400 = bad diagram syntax → warning icon.
          // HTTP 503/429 or SocketException = service unavailable → cloud icon.
          final errorStr = error.toString();
          final isNetworkError =
              errorStr.contains('SocketException') ||
              errorStr.contains('statusCode: 503') ||
              errorStr.contains('statusCode: 429');

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNetworkError
                      ? Icons.cloud_off_rounded
                      : Icons.warning_amber_rounded,
                  color: isNetworkError ? Colors.blueGrey : Colors.orangeAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  isNetworkError
                      ? 'Diagram temporarily unavailable'
                      : 'Invalid diagram syntax',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isNetworkError) ...[
                  const SizedBox(height: 4),
                  Text(
                    'mermaid.ink is currently unreachable. Try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );
}
