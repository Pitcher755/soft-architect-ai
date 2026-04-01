import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_extension.dart';

/// FileSystemScreen - Left panel for file system exploration
///
/// Displays project directory structure with expand/collapse functionality
/// Connected to FileSystemService for real file system operations
class FileSystemScreen extends ConsumerWidget {
  const FileSystemScreen({this.projectPath, super.key});

  /// Path to the project root directory (optional for now)
  final String? projectPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    return Container(
      color: c.mainBg,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, color: c.textSecondary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Files',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                    fontFamily: 'Fira Code',
                  ),
                ),
              ],
            ),
          ),

          // Content area (placeholder)
          Expanded(
            child: Container(
              color: c.mainBg,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Loading file system...',
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
