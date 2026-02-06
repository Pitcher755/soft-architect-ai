import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/notifiers/chat_notifier.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../filesystem/presentation/screens/file_system_screen.dart';
import '../widgets/markdown_preview_widget.dart';

/// ProjectWorkspaceScreen - The main 3-column IDE-like workspace
///
/// Architecture:
/// - Left (250px): FileSystemScreen (file explorer)
/// - Center (flex): ChatScreen (sequential chat + proposals)
/// - Right (450px): MarkdownPreviewWidget (live preview)
class ProjectWorkspaceScreen extends ConsumerWidget {
  const ProjectWorkspaceScreen({required this.projectPath, super.key});

  /// Path to the project root directory
  final String projectPath;

  /// Calculate which phase/stage based on document index
  String _getPhase(int docIndex) {
    if (docIndex <= 5) {
      return 'Vision';
    }
    if (docIndex <= 10) {
      return 'Architecture';
    }
    if (docIndex <= 15) {
      return 'Implementation';
    }
    if (docIndex <= 20) {
      return 'Testing';
    }
    return 'Deployment';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch chat state for progress tracking
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: _buildAppBar(
        context: context,
        docIndex: chatState.currentDocIndex,
        totalDocs: chatState.totalDocs,
        phase: _getPhase(chatState.currentDocIndex),
      ),
      body: Row(
        children: [
          // LEFT PANEL: File System Explorer (250px fixed)
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: AppColors.sidebarBg,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: FileSystemScreen(projectPath: projectPath),
          ),

          // CENTER PANEL: Sequential Chat (flex)
          const Expanded(child: ChatScreen()),

          // RIGHT PANEL: Markdown Preview (450px fixed)
          Container(
            width: 450,
            decoration: const BoxDecoration(
              color: AppColors.sidebarBg,
              border: Border(left: BorderSide(color: AppColors.border)),
            ),
            child: const MarkdownPreviewWidget(),
          ),
        ],
      ),
    );
  }

  /// Build AppBar with title, progress indicator, and phase info
  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required int docIndex,
    required int totalDocs,
    required String phase,
  }) {
    final progress = totalDocs > 0 ? docIndex / totalDocs : 0.0;

    return AppBar(
      backgroundColor: AppColors.sidebarBg,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      title: Row(
        children: [
          // Project title
          const Text(
            'SoftArchitect AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(width: 24),

          // Progress section (expandable)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Document counter + Phase
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Doc $docIndex/$totalDocs',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMain,
                        fontFamily: 'Fira Code',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Phase: $phase',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.info,
                          fontFamily: 'Fira Code',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      toolbarHeight: 80,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textMain,
              size: 20,
            ),
            onPressed: () {
              // Will be handled by router
              Navigator.of(context).pop();
            },
            tooltip: 'Back to Dashboard',
          ),
        ),
      ),
    );
  }
}
