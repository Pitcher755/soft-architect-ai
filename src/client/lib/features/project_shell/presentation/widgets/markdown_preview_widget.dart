import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// A markdown content preview widget styled like VS Code.
///
/// Features:
/// - Displays formatted markdown with syntax highlighting
/// - Shows file header with icon and name
/// - Empty state when no file is selected
/// - Selectable text for copying content
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({this.content, this.filename, super.key});

  /// Markdown content to display
  final String? content;

  /// Filename being displayed (for header)
  final String? filename;

  @override
  Widget build(BuildContext context) {
    developer.log(
      'MarkdownPreviewWidget: filename=$filename, '
      'hasContent=${content != null && content!.isNotEmpty}',
    );

    if (content == null || content!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContentView();
  }

  /// Build empty state UI
  Widget _buildEmptyState() {
    const textSecondary = Color(0xFF8b949e);
    const mainBg = Color(0xFF0D1117);

    return Container(
      color: mainBg,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: textSecondary),
            SizedBox(height: 16),
            Text(
              'Select a file to preview',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Build content preview view
  Widget _buildContentView() {
    const mainBg = Color(0xFF0D1117);
    const sidebarBg = Color(0xFF161B22);
    const borderDark = Color(0xFF30363d);
    const textMain = Color(0xFFE6EDF3);
    const primary = Color(0xFF0d0df2);

    return Column(
      children: [
        // Header with filename
        if (filename != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: sidebarBg,
              border: Border(bottom: BorderSide(color: borderDark)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 18, color: primary),
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
              data: content ?? '',
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  color: textMain,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                h2: const TextStyle(
                  color: textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                h3: const TextStyle(
                  color: textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                p: const TextStyle(color: textMain, fontSize: 14, height: 1.6),
                code: const TextStyle(
                  color: Color(0xFF79c0ff),
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: borderDark),
                  borderRadius: BorderRadius.circular(4),
                ),
                codeblockPadding: const EdgeInsets.all(12),
                blockquote: const TextStyle(
                  color: Color(0xFF8b949e),
                  fontStyle: FontStyle.italic,
                ),
                em: const TextStyle(fontStyle: FontStyle.italic),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                a: const TextStyle(color: Color(0xFF79c0ff)),
              ),
              onTapLink: (text, href, title) {
                developer.log('Link tapped: $href');
                // TODO: Implement link handling
              },
            ),
          ),
        ),
      ],
    );
  }
}
