// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../filesystem/presentation/providers/filesystem_providers.dart';
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

/// Widget que renderiza mensajes de chat con estilo dark theme
/// - Mensajes del usuario: burbuja alineada a la derecha con botón editar
/// - Mensajes del asistente: burbuja alineada a la izquierda con Markdown y botones de acción
///
/// Transformado a ConsumerWidget para poder guardar archivos en el FileSystem.
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
    // For user messages: keep the old bubble design
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
              // Message bubble
              Container(
                margin: const EdgeInsets.only(top: 16, right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _getUserBubbleColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: AppColors.success, width: 0.5),
                ),
                child: GestureDetector(
                  onLongPress: onLongPress,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message content with edit button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: SelectableText(
                              message.content,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          // Edit button for user messages
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
                              tooltip: 'Editar mensaje',
                            ),
                        ],
                      ),
                      // Timestamp
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

              // Avatar in top right corner for user
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
      // For assistant messages: Professional IDE style (no bubble, full width)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar on the left
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
            // Full-width content area (no bubble)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Content without background
                  GestureDetector(
                    onLongPress: onLongPress,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Smart message renderer with document parsing
                        SmartMessageRenderer(
                          rawContent: message.content,
                          isUser: false,
                          onSaveDocument: (path, cleanContent) async {
                            // ✅ IMPLEMENTACIÓN REAL DEL GUARDADO
                            debugPrint('📄 Intentando guardar documento en: $path');

                            try {
                              // Obtenemos el repository del filesystem
                              final repository =
                                  ref.read(fileSystemRepositoryProvider);

                              if (repository == null) {
                                throw Exception(
                                  'FileSystem no disponible. Abre un proyecto primero.',
                                );
                              }

                              // Normalizamos la ruta (removemos / inicial si existe)
                              final normalizedPath =
                                  path.startsWith('/') ? path.substring(1) : path;

                              // Llamamos al método saveFile del repository
                              await repository.saveFile(
                                relativePath: normalizedPath,
                                content: cleanContent,
                              );

                              debugPrint('✅ Documento guardado con éxito');

                              // Disparamos el callback opcional de validación del Chat
                              if (onValidate != null) {
                                onValidate!();
                              }
                            } catch (e) {
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
                        // Show blinking cursor only for streaming messages
                        if (message.isStreaming) const _BlinkingCursor(),
                      ],
                    ),
                  ),

                  // Action buttons for assistant messages
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

                  // Timestamp
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

/// Small action button for assistant messages.
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

/// Animated blinking cursor widget for streaming messages.
/// Uses FadeTransition with AnimationController for smooth 60 FPS animation.
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
      duration: const Duration(milliseconds: 530), // Standard cursor blink rate
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
