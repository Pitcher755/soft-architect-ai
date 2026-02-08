import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../../core/theme/app_colors.dart';

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
  Widget _buildEmptyState() => Container(
    color: AppColors.mainBg,
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Select a file to preview',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    ),
  );

  /// Build content preview view
  Widget _buildContentView() {
    final headerWidget = filename != null
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceBg,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    filename!,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Column(
      children: [
        headerWidget,
        // Markdown content
        Expanded(
          child: Container(
            color: AppColors.mainBg,
            child: Markdown(
              data: content ?? '',
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                h2: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                h3: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                p: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.6,
                ),
                code: const TextStyle(
                  color: AppColors.primaryLight,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                codeblockPadding: const EdgeInsets.all(12),
                blockquote: const TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                em: const TextStyle(fontStyle: FontStyle.italic),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                a: const TextStyle(color: AppColors.primaryLight),
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
