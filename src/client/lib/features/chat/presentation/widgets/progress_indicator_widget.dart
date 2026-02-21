import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../project_shell/domain/models/project_phase.dart';
import '../../../project_shell/presentation/providers/project_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class ProgressIndicatorWidget extends ConsumerStatefulWidget {
  const ProgressIndicatorWidget({
    required this.projectPath,
    // Deprecated: estos parámetros ya no se usan (se leen de status.json)
    this.documentsCreated = 0,
    this.currentPhase = '',
    super.key,
  });

  final String? projectPath;
  @Deprecated('Use projectStatusProvider instead')
  final int documentsCreated;
  @Deprecated('Use projectStatusProvider instead')
  final String currentPhase;

  @override
  ConsumerState<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState
    extends ConsumerState<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController;

  late int _totalFiles;

  @override
  void initState() {
    super.initState();
    _totalFiles = ProjectPhase.totalFileCount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enableAnimations = ref.watch(enableAnimationsProvider);
    _updateAnimationController(enableAnimations);
  }

  void _updateAnimationController(bool enableAnimations) {
    if (enableAnimations && _shimmerController == null) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
    } else if (!enableAnimations && _shimmerController != null) {
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
    final enableAnimations = ref.watch(enableAnimationsProvider);

    // If no projectPath, show initial state
    if (widget.projectPath == null || widget.projectPath!.isEmpty) {
      return _buildEmptyState();
    }

    // Watch the project status provider
    final statusAsync = ref.watch(projectStatusProvider(widget.projectPath!));

    return statusAsync.when(
      data: (progress) {
        final documentsCreated = progress.documentosCreados;
        final currentPhase = progress.faseActual;
        final progressPercent = progress.porcentajeCompletado;

        return _buildProgressBar(
          enableAnimations: enableAnimations,
          documentsCreated: documentsCreated,
          currentPhase: currentPhase,
          progressPercent: progressPercent,
        );
      },
      loading: _buildLoadingState,
      error: (error, stack) {
        debugPrint('⚠️ Error loading project status: $error');
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generating: Root',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '0%',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 8,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '0 / $_totalFiles docs',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildLoadingState() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: const BoxDecoration(
      color: AppColors.surfaceLight,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: const Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  Widget _buildProgressBar({
    required bool enableAnimations,
    required int documentsCreated,
    required String currentPhase,
    required double progressPercent,
  }) {
    final globalPercentage = (progressPercent / 100).clamp(0.0, 1.0);

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
                          value: enableAnimations ? null : 0.0,
                        ),
                      ),
                    ),
                  Text(
                    'Generating: $currentPhase',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${progressPercent.toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Segmented Progress Bar
          SizedBox(
            height: 8,
            child: Row(
              children: _buildSegments(enableAnimations, documentsCreated),
            ),
          ),

          const SizedBox(height: 4),

          // Document Count Subtitle
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$documentsCreated / $_totalFiles docs',
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

  List<Widget> _buildSegments(bool enableAnimations, int documentsCreated) {
    final segments = <Widget>[];
    var accumulator = 0;

    for (var i = 0; i < ProjectPhase.all.length; i++) {
      final phase = ProjectPhase.all[i];
      final startRange = accumulator;
      final endRange = accumulator + phase.fileCount;

      var isCompleted = documentsCreated >= endRange;
      var isActive =
          documentsCreated > startRange && documentsCreated < endRange;

      if (documentsCreated == startRange && phase.fileCount > 0) {
        isActive = true;
        isCompleted = false;
      }

      var localProgress = 0.0;
      if (isCompleted) {
        localProgress = 1.0;
      } else if (isActive) {
        final filesDoneInPhase = documentsCreated - startRange;
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
            isLast: i == ProjectPhase.all.length - 1,
          ),
        ),
      );

      if (i < ProjectPhase.all.length - 1) {
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

    const backgroundColor = AppColors.surfaceBg;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Container(color: backgroundColor),
          FractionallySizedBox(
            widthFactor: localProgress.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(color: color),
          ),
          if (isActive && enableAnimations && shimmerController != null)
            AnimatedBuilder(
              animation: shimmerController!,
              builder: (context, child) {
                final start = -1.5 + (shimmerController!.value * 3.5);
                final end = start + 1.5;
                final shimmerColor = Theme.of(context).colorScheme.onSurface;

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        shimmerColor.withValues(alpha: 0.6),
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
