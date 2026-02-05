// lib/features/project_shell/presentation/widgets/markdown_preview_widget.dart
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Widget: Markdown content preview
/// Displays formatted markdown content or placeholder when no file is selected.
///
/// Design inspiration: GitHub Dark theme
/// - Background: #0D1117
/// - Text: #E6EDF3
/// - Secondary text: #8b949e
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({super.key, this.content, this.filename});

  /// Markdown content to display
  final String? content;

  /// Filename being displayed (for header)
  final String? filename;

  @override
  Widget build(BuildContext context) {
    developer.log('Building MarkdownPreviewWidget: filename=$filename');

    if (content == null || content!.isEmpty) {
      return const _EmptyPreview();
    }

    return _MarkdownContent(content: content!, filename: filename);
  }
}

/// Empty state when no file is selected
class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    const textSecondary = Color(0xFF8b949e);

    developer.log('Displaying empty markdown preview');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 64,
            color: textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a file to preview',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Markdown content display
class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.content, this.filename});
  final String content;
  final String? filename;

  @override
  Widget build(BuildContext context) {
    const mainBg = Color(0xFF0D1117);
    const textMain = Color(0xFFE6EDF3);

    return Column(
      children: [
        // Optional file header
        if (filename != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF30363d))),
              color: Color(0xFF161B22),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  size: 18,
                  color: Color(0xFF0d0df2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    filename!,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Markdown content
        Expanded(
          child: Container(
            color: mainBg,
            child: Markdown(
              data: content,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context).copyWith(
                  scaffoldBackgroundColor: mainBg,
                  textTheme: const TextTheme(
                    bodyMedium: TextStyle(
                      color: textMain,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              onTapLink: (text, href, title) {
                developer.log('Link tapped: $href');
                // TODO: Implement link handling (open in browser, etc.)
              },
            ),
          ),
        ),
      ],
    );
  }
}
