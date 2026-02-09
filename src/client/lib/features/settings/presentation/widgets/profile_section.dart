import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
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
    final currentName = ref.read(settingsProvider).userName;
    _nameController = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Update controller if state changes externally
    if (settings.userName != _nameController.text &&
        !_nameController.selection.isValid) {
      _nameController.text = settings.userName;
    }

    final avatarColors = <Color>[
      const Color(0xFF58A6FF), // Blue (Default)
      const Color(0xFF238636), // Green
      const Color(0xFFA371F7), // Purple
      const Color(0xFFD29922), // Orange
      const Color(0xFFF85149), // Red
      const Color(0xFFEC4899), // Pink
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
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
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
                    icon: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFF58A6FF),
                    ),
                    label: const Text(
                      'Cambiar avatar',
                      style: TextStyle(color: Color(0xFF58A6FF), fontSize: 12),
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
                    const Text(
                      'Nombre de usuario',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE6EDF3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Color(0xFFE6EDF3),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu nombre',
                        hintStyle: const TextStyle(color: Color(0xFF8b949e)),
                        filled: true,
                        fillColor: const Color(0xFF0D1117),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF30363d),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF30363d),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF58A6FF),
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
                        color: const Color(0xFF8b949e).withValues(alpha: 0.7),
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

  void _showAvatarPicker(
    BuildContext context,
    WidgetRef ref,
    List<Color> colors,
    int selectedIndex,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Elige un avatar',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(colors.length, (index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  ref.read(settingsProvider.notifier).updateAvatarIndex(index);
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
                          ? Colors.white
                          : colors[index].withValues(alpha: 0.3),
                      width: isSelected ? 3 : 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
