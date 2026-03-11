import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                // 🎯 CAMBIO: Ahora delegamos toda la magia
                // (rutas, guardado y avance) al ChatNotifier.
                // Ya no hay que adivinar la ruta ni inyectar
                // servicios manualmente aquí.
                onSaveDocument: () async {
                  await ref
                      .read(chatNotifierProvider.notifier)
                      .validateProposal();
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
