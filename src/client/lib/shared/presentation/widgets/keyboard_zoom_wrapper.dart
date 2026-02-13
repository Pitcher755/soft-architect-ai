import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/presentation/providers/settings_providers.dart';

class KeyboardZoomWrapper extends ConsumerWidget {
  const KeyboardZoomWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalZoom = ref.watch(globalZoomProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return CallbackShortcuts(
      bindings: {
        // Ctrl + '+' (Numpad y Teclado estándar)
        const SingleActivator(LogicalKeyboardKey.add, control: true): () =>
            notifier.updateGlobalZoom((globalZoom + 0.1).clamp(0.5, 2.0)),
        const SingleActivator(LogicalKeyboardKey.equal, control: true): () =>
            notifier.updateGlobalZoom((globalZoom + 0.1).clamp(0.5, 2.0)),

        // Ctrl + '-'
        const SingleActivator(LogicalKeyboardKey.minus, control: true): () =>
            notifier.updateGlobalZoom((globalZoom - 0.1).clamp(0.5, 2.0)),

        // Ctrl + '0' (Resetear Zoom)
        const SingleActivator(LogicalKeyboardKey.digit0, control: true): () =>
            notifier.updateGlobalZoom(1),
      },
      child: Focus(
        autofocus: true,
        child: MediaQuery(
          // La magia del Zoom: Escala todo el texto de la app
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(globalZoom)),
          child: child,
        ),
      ),
    );
  }
}
