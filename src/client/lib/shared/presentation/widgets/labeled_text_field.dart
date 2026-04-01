import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';

/// Reusable labeled text field widget
/// Includes label, hint, help text, and basic validation
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.helpText,
    super.key,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final String helpText;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;

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
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: _buildInputDecoration(hint, c),
          style: TextStyle(color: c.textMain),
        ),
        const SizedBox(height: 4),
        Text(
          helpText,
          style: TextStyle(fontSize: 11, color: c.textSecondary),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    AppColorsExtension c,
  ) => InputDecoration(
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
