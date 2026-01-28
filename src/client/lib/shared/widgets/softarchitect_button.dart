import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, ghost }

/// Shared button component following the Design System.
class SoftArchitectButton extends StatelessWidget {
  const SoftArchitectButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ButtonVariant.primary => _buildPrimary(context),
      ButtonVariant.secondary => _buildSecondary(context),
      ButtonVariant.ghost => _buildGhost(context),
    };
  }

  Widget _buildPrimary(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }

  Widget _buildSecondary(BuildContext context) {
    return OutlinedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }

  Widget _buildGhost(BuildContext context) {
    return TextButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: Text(label),
    );
  }
}
