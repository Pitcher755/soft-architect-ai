import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Campo de texto multilínea etiquetado reutilizable
/// Específicamente para áreas de texto con múltiples líneas
class LabeledTextArea extends StatelessWidget {
  const LabeledTextArea({
    required this.label,
    required this.controller,
    required this.hint,
    super.key,
    this.maxLines = 3,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

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
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: _buildInputDecoration(hint),
        style: const TextStyle(color: AppColors.textMain),
      ),
    ],
  );

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
