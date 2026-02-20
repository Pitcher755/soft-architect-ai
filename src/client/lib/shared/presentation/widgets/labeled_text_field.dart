import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: _buildInputDecoration(hint),
        style: const TextStyle(color: AppColors.textMain),
      ),
      const SizedBox(height: 4),
      Text(
        helpText,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
