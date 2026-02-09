import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class _PhaseDef {
  const _PhaseDef(this.id, this.fileCount, this.color);
  final String id;
  final int fileCount;
  final Color color;
}

class ProgressIndicatorWidget extends ConsumerStatefulWidget {
  const ProgressIndicatorWidget({
    required this.documentsCreated,
    required this.currentPhase,
    super.key,
  });

  final int documentsCreated;
  final String currentPhase;

  @override
  ConsumerState<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends ConsumerState<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController;

  final List<_PhaseDef> _phases = const [
    _PhaseDef('ROOT', 4, AppColors.dirRoot),
    _PhaseDef('CONTEXT', 3, AppColors.dirContext),
    _PhaseDef('REQUIREMENTS', 4, AppColors.dirRequirements),
    _PhaseDef('ARCHITECTURE', 6, AppColors.dirArchitecture),
    _PhaseDef('UI_UX', 3, AppColors.dirUiUx),
    _PhaseDef('PLANNING', 4, AppColors.dirPlanning),
    _PhaseDef('META', 1, AppColors.dirMeta),
  ];

  late int _totalFiles;

  @override
  void initState() {
    super.initState();
    _totalFiles = _phases.fold(0, (sum, p) => sum + p.fileCount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = ref.watch(settingsProvider);
    _updateAnimationController(settings.enableAnimations);
  }

  void _updateAnimationController(bool enableAnimations) {
    if (enableAnimations && _shimmerController == null) {
      // Inicializar animación si está habilitada y no existe
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
    } else if (!enableAnimations && _shimmerController != null) {
      // Detener y liberar animación si está deshabilitada
      _shimmerController!.dispose();
      _shimmerController = null;
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final globalPercentage = (widget.documentsCreated / _totalFiles).clamp(
      0.0,
      1.0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (globalPercentage < 1.0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                          // Solo animar si las animaciones están habilitadas
                          value: settings.enableAnimations ? null : 0.0,
                        ),
                      ),
                    ),
                  Text(
                    'Generando: ${widget.currentPhase}',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${(globalPercentage * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Barra Segmentada
          SizedBox(
            height: 8,
            child: Row(children: _buildSegments(settings.enableAnimations)),
          ),

          const SizedBox(height: 4),

          // Subtítulo
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.documentsCreated} / $_totalFiles docs',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSegments(bool enableAnimations) {
    final segments = <Widget>[];
    var accumulator = 0;

    for (var i = 0; i < _phases.length; i++) {
      final phase = _phases[i];
      final startRange = accumulator;
      final endRange = accumulator + phase.fileCount;

      var isCompleted = widget.documentsCreated >= endRange;
      var isActive =
          widget.documentsCreated > startRange &&
          widget.documentsCreated < endRange;

      if (widget.documentsCreated == startRange && phase.fileCount > 0) {
        isActive = true;
        isCompleted = false;
      }

      var localProgress = 0.0;
      if (isCompleted) {
        localProgress = 1.0;
      } else if (isActive) {
        final filesDoneInPhase = widget.documentsCreated - startRange;
        localProgress = filesDoneInPhase / phase.fileCount;
      }

      segments.add(
        Expanded(
          flex: phase.fileCount,
          child: _PhaseSegment(
            color: phase.color,
            isCompleted: isCompleted,
            isActive: isActive,
            localProgress: localProgress,
            shimmerController: _shimmerController,
            enableAnimations: enableAnimations,
            isFirst: i == 0,
            isLast: i == _phases.length - 1,
          ),
        ),
      );

      if (i < _phases.length - 1) {
        segments.add(const SizedBox(width: 3));
      }

      accumulator += phase.fileCount;
    }
    return segments;
  }
}

class _PhaseSegment extends StatelessWidget {
  const _PhaseSegment({
    required this.color,
    required this.isCompleted,
    required this.isActive,
    required this.localProgress,
    required this.shimmerController,
    required this.enableAnimations,
    this.isFirst = false,
    this.isLast = false,
  });

  final Color color;
  final bool isCompleted;
  final bool isActive;
  final double localProgress;
  final AnimationController? shimmerController;
  final bool enableAnimations;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.horizontal(
      left: isFirst ? const Radius.circular(4) : Radius.zero,
      right: isLast ? const Radius.circular(4) : Radius.zero,
    );

    // Fondo gris oscuro para la parte vacía
    const backgroundColor = AppColors.surfaceBg;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          // 1. Fondo (Base vacía)
          Container(color: backgroundColor),

          // 2. Progreso de Relleno (Fill Color)
          FractionallySizedBox(
            widthFactor: localProgress.clamp(0.0, 1.0),
            child: Container(color: color),
          ),

          // 3. Efecto Shimmer - Solo si animaciones están habilitadas
          if (isActive && enableAnimations && shimmerController != null)
            AnimatedBuilder(
              animation: shimmerController!,
              builder: (context, child) {
                // Movemos el gradiente de izquierda a derecha
                // Valores ajustados para asegurar que el
                //brillo cruce toda la barra
                final start = -1.5 + (shimmerController!.value * 3.5);
                final end = start + 1.5;

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.6), // Blanco fuerte
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment(start, 0),
                      end: Alignment(end, 0),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
