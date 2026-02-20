import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen/app_localizations.dart';

/// Directory path picker field widget
/// Allows the user to select a folder using a native dialog
class PathPickerField extends StatelessWidget {
  const PathPickerField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.helpText,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final String helpText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textMain,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: _buildInputDecoration(hint),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _pickDirectory,
            icon: const Icon(Icons.folder_open, size: 18),
            label: Text(AppLocalizations.of(context).browse),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textMain,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        helpText,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    ],
  );

  Future<void> _pickDirectory() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Seleccionar carpeta contenedora',
      lockParentWindow: true,
    );

    if (selectedDirectory != null) {
      controller.text = selectedDirectory;
    }
  }

  InputDecoration _buildInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
    filled: true,
    fillColor: AppColors.mainBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
