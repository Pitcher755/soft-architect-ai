import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../../gen/app_localizations.dart';
import '../providers/settings_providers.dart';
import 'settings_card.dart';

/// Profile section widget - manages user profile settings.
///
/// Allows users to change their name and avatar.
class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final currentName =
        ref.read(settingsProvider).value?.userName ?? 'Architect';
    _nameController = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) {
      return const SizedBox.shrink();
    }

    // Update controller if state changes externally
    if (settings.userName != _nameController.text &&
        !_nameController.selection.isValid) {
      _nameController.text = settings.userName;
    }

    final avatarColors = <Color>[
      context.appColors.accentBlue,
      AppColors.success,
      AppColors.iconPurple,
      AppColors.warning,
      AppColors.error,
      AppColors.iconPink,
    ];

    return SettingsCard(
      title: 'Perfil de Usuario',
      icon: Icons.person_outline,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: AVATAR
              Column(
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarPicker(
                      context,
                      ref,
                      avatarColors,
                      settings.avatarIndex,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: avatarColors[settings.avatarIndex],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: avatarColors[settings.avatarIndex].withValues(
                            alpha: 0.3,
                          ),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showAvatarPicker(
                      context,
                      ref,
                      avatarColors,
                      settings.avatarIndex,
                    ),
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Cambiar avatar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // RIGHT COLUMN: TEXT FIELDS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre de usuario',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const ValueKey('userName_field'),
                      controller: _nameController,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateUserName(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Escribe tu nombre',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateUserName(value.trim());
                        }
                      },
                      onEditingComplete: () {
                        final value = _nameController.text;
                        if (value.trim().isNotEmpty) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateUserName(value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este nombre se mostrará en la interfaz',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows avatar picker dialog with predefined colors and custom image option.
  ///
  /// Allows users to select from predefined avatar colors or choose a custom
  /// image from their file system using file_picker.
  void _showAvatarPicker(
    BuildContext context,
    WidgetRef ref,
    List<Color> colors,
    int selectedIndex,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
        title: Text(
          'Elige un avatar',
          style: Theme.of(ctx).textTheme.titleMedium,
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(colors.length, (index) {
                  final isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(settingsProvider.notifier)
                          .updateAvatarIndex(index);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(ctx).colorScheme.onPrimary
                              : colors[index].withValues(alpha: 0.3),
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(ctx).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Divider(color: Theme.of(ctx).colorScheme.outline),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _pickCustomAvatar(context, ref);
                },
                icon: Icon(
                  Icons.image,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                label: Text(
                  'Elegir imagen personalizada',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens file picker for custom avatar image selection.
  ///
  /// Allows users to select an image file from their system to use as avatar.
  /// Supported formats: PNG, JPG, JPEG.
  Future<void> _pickCustomAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final imagePath = result.files.single.path!;
        await ref
            .read(settingsProvider.notifier)
            .updateCustomAvatarPath(imagePath);

        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.avatarUpdated),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } on Object catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarUpdateError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
