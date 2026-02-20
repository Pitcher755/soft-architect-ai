import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../filesystem/presentation/notifiers/file_system_notifier.dart';
import '../../../filesystem/presentation/providers/filesystem_providers.dart';
import '../../../project_shell/core/services/file_system_service.dart';
import '../../../project_shell/infrastructure/services/project_progress_service.dart';
import '../../../project_shell/presentation/providers/project_providers.dart';
import '../notifiers/chat_notifier.dart';
import 'smart_message_renderer.dart';

/// Model for chat messages (use the one from domain)
class ChatMessageUI {
  ChatMessageUI({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
}

class MessageBubbleWidget extends ConsumerWidget {
  const MessageBubbleWidget({
    required this.message,
    super.key,
    this.onLongPress,
    this.messageController,
    this.userName,
    this.onValidate,
    this.isValidated = false,
  });

  final ChatMessageUI message;
  final VoidCallback? onLongPress;
  final TextEditingController? messageController;
  final String? userName;
  final VoidCallback? onValidate;
  final bool isValidated;

  bool get _isUserMessage => message.role == 'user';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isUserMessage) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 64,
            right: 16,
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16, right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Padding ligeramente aumentado
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getUserBubbleColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), // Bordes más suaves
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: AppColors.success, width: 0.5),
                ),
                child: GestureDetector(
                  onLongPress: onLongPress,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: SelectableText(
                              message.content,
                              style: const TextStyle(
                                color:
                                    AppColors.textMain, // Forzamos blanco puro
                                fontSize: 16, // Aumentamos de 14 a 16
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (messageController != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              color: AppColors.textMuted,
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                messageController!.text = message.content;
                              },
                              tooltip: 'Edit message',
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _formatTime(message.timestamp),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.dirContext,
                child: Icon(Icons.person, size: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                foregroundColor: AppColors.primary,
                child: const Icon(
                  Icons.smart_toy_outlined,
                  size: 25,
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: onLongPress,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SmartMessageRenderer(
                          rawContent: message.content,
                          isUser: false,
                          onSaveDocument: (path, cleanContent) async {
                            debugPrint(
                              '📄 Attempting to save document at: $path',
                            );

                            try {
                              // 1. GET THE ROOT (WITH FAILSAFE)
                              var projectRoot = ref.read(projectRootProvider);

                              // If null, search for the most recently opened project
                              if (projectRoot == null || projectRoot.isEmpty) {
                                final projects = ref.read(projectsProvider);
                                final activeProject = projects
                                    .where((p) => !p.path.startsWith('mock://'))
                                    .firstOrNull;
                                if (activeProject != null) {
                                  projectRoot = activeProject.path;
                                } else {
                                  throw Exception(
                                    'No active project configured.',
                                  );
                                }
                              }

                              final normalizedPath = path.startsWith('/')
                                  ? path.substring(1)
                                  : path;

                              // 2. SAVE THE FILE
                              final fsService = FileSystemServiceImpl();
                              await fsService.saveDocument(
                                projectPath: projectRoot,
                                relativePath: normalizedPath,
                                content: cleanContent,
                              );

                              debugPrint('✅ Document saved successfully');

                              // Update project progress
                              try {
                                await ProjectProgressService.updateAfterDocumentSave(
                                  projectRoot,
                                );
                              } on Exception catch (e) {
                                debugPrint('⚠️ Error updating progress: $e');
                              }

                              ref.invalidate(fileSystemNotifierProvider);
                              ref
                                  .read(fileSystemNotifierProvider.notifier)
                                  .refresh();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✅ Document saved successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              if (onValidate != null) {
                                onValidate!();
                              }

                              // 🤖 3. AGENT LOOP (AGENTIC LOOP)
                              final autoPrompt =
                                  'I have validated and saved the document '
                                  'at `$normalizedPath`. '
                                  'Please review the Master Workflow '
                                  'and tell me what the next step is and '
                                  'what document should be created now. '
                                  'Si necesitas contexto para el siguiente '
                                  'documento, hazme las preguntas necesarias.';

                              await ref
                                  .read(chatNotifierProvider.notifier)
                                  .sendMessageStream(autoPrompt);
                            } on Exception catch (e) {
                              debugPrint('❌ Error guardando el documento: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al guardar: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        if (message.isStreaming) const _BlinkingCursor(),
                      ],
                    ),
                  ),
                  if (!message.isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            icon: Icons.copy,
                            tooltip: 'Copiar al portapapeles',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: message.content),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          if (onValidate != null)
                            _ActionButton(
                              icon: isValidated
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              tooltip: isValidated
                                  ? '✅ Documento guardado'
                                  : 'Validar y guardar documento',
                              onPressed: onValidate!,
                              color: isValidated
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _getUserBubbleColor() => AppColors.primaryLight.withValues(alpha: 0.15);

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon),
    iconSize: 16,
    padding: const EdgeInsets.all(4),
    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    color: color ?? AppColors.textMuted,
    hoverColor: (color ?? AppColors.primary).withValues(alpha: 0.1),
    onPressed: onPressed,
    tooltip: tooltip,
  );
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _animation,
    child: Container(
      width: 2,
      height: 16,
      margin: const EdgeInsets.only(left: 2, top: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  );
}
