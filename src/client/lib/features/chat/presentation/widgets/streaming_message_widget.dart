import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../filesystem/presentation/providers/filesystem_providers.dart';
import '../../../project_shell/core/services/file_system_service.dart';
import '../../../project_shell/infrastructure/services/project_progress_service.dart';
import '../notifiers/chat_notifier.dart';
import 'smart_message_renderer.dart';

/// Optimized widget for rendering streaming messages.
class StreamingMessageWidget extends ConsumerWidget {
  const StreamingMessageWidget({
    required this.text,
    super.key,
    this.isStreaming = false,
  });

  final String text;
  final bool isStreaming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SmartMessageRenderer(
                rawContent: text,
                isUser: false,
                onSaveDocument: (path, cleanContent) async {
                  debugPrint(
                    '📄 Attempting to save streaming document at: $path',
                  );

                  try {
                    final projectRoot = ref.read(projectRootProvider);
                    if (projectRoot == null) {
                      throw Exception(
                        'Project root not configured. '
                        'Open a project first.',
                      );
                    }

                    final normalizedPath = path.startsWith('/')
                        ? path.substring(1)
                        : path;

                    final fsService = FileSystemServiceImpl();
                    await fsService.saveDocument(
                      projectPath: projectRoot,
                      relativePath: normalizedPath,
                      content: cleanContent,
                    );

                    // Update project progress
                    try {
                      await ProjectProgressService.updateAfterDocumentSave(
                        projectRoot,
                      );
                    } on Exception catch (e) {
                      debugPrint('⚠️ Error updating progress: $e');
                    }

                    ref.invalidate(fileSystemNotifierProvider);
                    ref.read(fileSystemNotifierProvider.notifier).refresh();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Document saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } on Exception catch (e) {
                    debugPrint('❌ Error saving the document: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error saving: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                onSendChatMessage: (refineMessage) async {
                  await ref
                      .read(chatNotifierProvider.notifier)
                      .sendMessageStream(refineMessage);
                },
              ),
            ),
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
}
