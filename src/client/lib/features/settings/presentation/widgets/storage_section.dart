import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Storage section widget - manages project directory settings.
///
/// Allows users to configure default project storage location.
class StorageSection extends ConsumerWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SettingsCard(
      title: 'Almacenamiento',
      icon: Icons.folder_special,
      children: [
        SettingItem(
          title: 'Directorio de proyectos',
          subtitle: 'Ubicación por defecto para guardar nuevos proyectos',
          child: Row(
            children: [
              Container(
                width: 220,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  border: Border.all(color: const Color(0xFF30363d)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  settings.projectDirectory ?? '~/Documents/SoftArchitect',
                  style: const TextStyle(
                    color: Color(0xFF8b949e),
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _selectDirectory(context, ref),
                icon: const Icon(Icons.folder_open, size: 20),
                color: const Color(0xFF58A6FF),
                tooltip: 'Cambiar directorio',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF21262D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Color(0xFF30363d)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDirectory(BuildContext context, WidgetRef ref) async {
    // TODO: Implement file_picker when package is added
    // For now, show a dialog to manually enter path
    final controller = TextEditingController(
      text:
          ref.read(settingsProvider).projectDirectory ??
          '~/Documents/SoftArchitect',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Configurar directorio de proyectos',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFFE6EDF3)),
          decoration: InputDecoration(
            hintText: 'Ruta del directorio',
            hintStyle: const TextStyle(color: Color(0xFF8b949e)),
            filled: true,
            fillColor: const Color(0xFF0D1117),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF30363d)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF8b949e)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Color(0xFF58A6FF)),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      ref.read(settingsProvider.notifier).updateProjectDirectory(result.trim());
    }
  }
}
