import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../filesystem/presentation/providers/filesystem_providers.dart';
import 'smart_message_renderer.dart';

/// Optimized widget for rendering streaming messages.
///
/// Performance optimizations:
/// - RepaintBoundary to isolate repaints
/// - Minimal widget rebuilds
///
/// Transformado a ConsumerWidget para integración con FileSystem.
class StreamingMessageWidget extends ConsumerWidget {
  const StreamingMessageWidget({
    required this.text,
    super.key,
    this.isStreaming = false,
  });

  /// Message text content.
  final String text;

  /// Flag indicating if message is still streaming.
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
                  // ✅ IMPLEMENTACIÓN REAL DEL GUARDADO
                  debugPrint('📄 Intentando guardar documento en: $path');

                  try {
                    // Obtenemos el repository del filesystem
                    final repository = ref.read(fileSystemRepositoryProvider);

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
