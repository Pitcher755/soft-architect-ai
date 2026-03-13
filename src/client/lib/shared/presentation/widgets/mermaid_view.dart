import 'dart:convert';

import 'package:flutter/material.dart';

/// Widget that renders a Mermaid diagram by encoding it as a mermaid.ink URL.
///
/// Sanitizes the raw LLM output before encoding to prevent HTTP 400 errors
/// caused by malformed arrow syntax, then displays the result inline using
/// [Image.network].
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Invalid diagram syntax. Check the console for details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
