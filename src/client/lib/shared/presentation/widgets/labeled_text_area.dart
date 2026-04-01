import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';

/// Reusable labeled multiline text field widget
/// Specifically for text areas with multiple lines
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
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.textMain,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: _buildInputDecoration(hint, c),
          style: TextStyle(color: c.textMain),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, AppColorsExtension c) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary.withValues(alpha: 0.5)),
        filled: true,
        fillColor: c.mainBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );
}
