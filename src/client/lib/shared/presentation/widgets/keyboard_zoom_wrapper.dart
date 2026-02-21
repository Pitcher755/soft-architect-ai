import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/presentation/providers/settings_providers.dart';

/// Keyboard zoom wrapper with comprehensive keyboard support.
///
/// Supports all keyboard layouts (ISO/ANSI/Spanish/English):
/// - Ctrl/Cmd + Plus/Equal (Zoom In)
/// - Ctrl/Cmd + Minus (Zoom Out)
/// - Ctrl/Cmd + 0 (Reset)
///
/// CRITICAL: Does NOT rebuild router or navigation.
class KeyboardZoomWrapper extends ConsumerWidget {
  const KeyboardZoomWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Focus(
    autofocus: true,
    canRequestFocus: false,
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        final isControlPressed =
            HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed;

        if (isControlPressed) {
          final key = event.logicalKey;

          // ZOOM IN: Ctrl + Plus/Equal (ISO/ANSI keyboards)
          if (key == LogicalKeyboardKey.add ||
              key == LogicalKeyboardKey.numpadAdd ||
              key == LogicalKeyboardKey.equal) {
            ref.read(settingsProvider.notifier).increaseZoom();
            return KeyEventResult.handled;
          }

          // ZOOM OUT: Ctrl + Minus
          if (key == LogicalKeyboardKey.minus ||
              key == LogicalKeyboardKey.numpadSubtract) {
            ref.read(settingsProvider.notifier).decreaseZoom();
            return KeyEventResult.handled;
          }

          // RESET ZOOM: Ctrl + 0
          if (key == LogicalKeyboardKey.digit0 ||
              key == LogicalKeyboardKey.numpad0) {
            ref.read(settingsProvider.notifier).resetZoom();
            return KeyEventResult.handled;
          }
        }
      }
      return KeyEventResult.ignored;
    },
    child: child,
  );
}
