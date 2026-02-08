import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget que muestra el progreso de generación de documentos por fase
///
/// Estructura de fases y archivos:
/// - 00-ROOT: 4 archivos
/// - 10-CONTEXT: 3 archivos
/// - 20-REQUIREMENTS: 4 archivos
/// - 30-ARCHITECTURE: 6 archivos
/// - 35-UI_UX: 3 archivos
/// - 40-PLANNING: 4 archivos
/// - 99-META: 1 archivo
/// Total: 25 archivos
class ProgressIndicatorWidget extends StatefulWidget {
  const ProgressIndicatorWidget({
    required this.documentsCreated,
    required this.currentPhase,
    super.key,
  });

  /// Number of documents created so far
  final int documentsCreated;

  /// Current phase being processed (e.g., "10-CONTEXT")
  final String currentPhase;

  /// Total number of documents to be created
  static const int totalDocuments = 25;

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentsCreated != widget.documentsCreated) {
      _updateAnimation();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(
          begin: 0,
          end: widget.documentsCreated / ProgressIndicatorWidget.totalDocuments,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animationController.forward();
  }

  void _updateAnimation() {
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact header with counter and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generando Documento ${widget.documentsCreated}/${ProgressIndicatorWidget.totalDocuments}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final percentage = (_progressAnimation.value * 100)
                    .toStringAsFixed(0);
                return Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Animated progress bar with phase colors
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 6,
                  color: AppColors.mainBg,
                ),
                // Progress bar with phase colors
                CustomPaint(
                  size: const Size.fromHeight(6),
                  painter: PhaseProgressPainter(
                    progress: _progressAnimation.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

}

/// Custom painter for phase-colored progress bar
class PhaseProgressPainter extends CustomPainter {

  PhaseProgressPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Phase definitions: (start%, end%, color)
    final phases = [
      (0.0, 0.16, AppColors.dirRoot),        // ROOT: 4/25 docs
      (0.16, 0.28, AppColors.dirContext),    // CONTEXT: 7/25 docs
      (0.28, 0.44, AppColors.dirRequirements), // REQUIREMENTS: 11/25 docs
      (0.44, 0.68, AppColors.dirArchitecture), // ARCHITECTURE: 17/25 docs
      (0.68, 0.80, AppColors.dirUiUx),       // UI_UX: 20/25 docs
      (0.80, 0.96, AppColors.dirPlanning),   // PLANNING: 24/25 docs
      (0.96, 1.0, AppColors.dirMeta),        // META: 25/25 docs
    ];

    for (final (start, end, color) in phases) {
      if (progress >= start) {
        final fillProgress = ((progress - start) / (end - start)).clamp(0.0, 1.0);
        final width = size.width * (end - start) * fillProgress;
        final offset = size.width * start;

        canvas.drawRect(
          Rect.fromLTWH(offset, 0, width, size.height),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PhaseProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
