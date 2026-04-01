import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../gen/app_localizations.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../providers/settings_providers.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Storage section widget - manages project directory settings.
///
/// Allows users to configure default project storage location.
/// Uses native file_picker for folder selection dialog.
class StorageSection extends ConsumerWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) {
      return const SizedBox.shrink();
    }

    return SettingsCard(
      title: l10n.storageTitle,
      icon: Icons.folder_special,
      children: [
        SettingItem(
          title: l10n.storageProjectDirTitle,
          subtitle: l10n.storageProjectDirSubtitle,
          child: Row(
            children: [
              Container(
                width: 220,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: context.appColors.cardBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  settings.storagePath.isEmpty
                      ? '~/Documents/SoftArchitect'
                      : settings.storagePath,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
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
                color: context.appColors.accentBlue,
                tooltip: l10n.changeDirectory,
                style: IconButton.styleFrom(
                  backgroundColor: context.appColors.actionBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: context.appColors.cardBorder),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Opens native folder picker dialog and updates storage path.
  ///
  /// Uses file_picker package for platform-native folder selection.
  Future<void> _selectDirectory(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Open native folder picker dialog
      final selectedPath = await FilePicker.platform.getDirectoryPath();

      // User cancelled selection
      if (selectedPath == null) {
        return;
      }

      // Update storage path via notifier (auto-persists)
      await ref.read(settingsProvider.notifier).updateStoragePath(selectedPath);

      // Show success feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.directoryUpdated(selectedPath)),
            backgroundColor: context.appColors.successBg,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on Object catch (e) {
      // Show error feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSelectingDirectory(e.toString())),
            backgroundColor: context.appColors.dangerBg,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
