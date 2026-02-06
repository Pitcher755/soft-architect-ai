import 'package:flutter/material.dart';

/// Widget que muestra el progreso de streaming en tiempo real durante la generación de documentos
class StreamingIndicatorWidget extends StatefulWidget {
  final double progress;
  final int documentIndex;
  final int totalDocuments;

  const StreamingIndicatorWidget({
    Key? key,
    required this.progress,
    required this.documentIndex,
    required this.totalDocuments,
  }) : super(key: key);

  @override
  State<StreamingIndicatorWidget> createState() =>
      _StreamingIndicatorWidgetState();
}

class _StreamingIndicatorWidgetState extends State<StreamingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(StreamingIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _updateAnimation();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0)).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animationController.forward();
  }

  void _updateAnimation() {
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), // GitHub dark surface
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF30363D), // GitHub dark border
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with document counter and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Document ${widget.documentIndex}/${widget.totalDocuments}',
                style: const TextStyle(
                  color: Color(0xFF8B949E), // GitHub dark secondary text
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                      color: Color(0xFF238636), // GitHub dark success green
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 8,
                  backgroundColor: const Color(
                    0xFF0D1117,
                  ), // GitHub dark main bg
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(_progressAnimation.value),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Status text
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final status = _getStatusText(_progressAnimation.value);
              return Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF6E7681), // GitHub dark muted text
                  fontSize: 12,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Returns color based on progress stage
  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      return const Color(0xFF1F6FEB); // GitHub blue
    } else if (progress < 0.66) {
      return const Color(0xFF3FB950); // GitHub green
    } else {
      return const Color(0xFF238636); // GitHub dark success green
    }
  }

  /// Returns status text based on progress
  String _getStatusText(double progress) {
    if (progress == 0) {
      return 'Initiating document processing...';
    } else if (progress < 0.5) {
      return 'Processing document content...';
    } else if (progress < 1.0) {
      return 'Finalizing document...';
    } else {
      return 'Document processing completed!';
    }
  }
}
