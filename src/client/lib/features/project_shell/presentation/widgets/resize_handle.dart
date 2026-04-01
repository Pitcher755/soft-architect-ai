import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_colors_extension.dart';

/// Resizable handle for dragging panel boundaries.
///
/// Provides visual feedback on hover and drag, and handles
/// the drag gesture to resize adjacent panels.
class ResizeHandle extends StatefulWidget {
  const ResizeHandle({
    required this.onDragUpdate,
    required this.onDragEnd,
    super.key,
  });

  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  bool _isHovering = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.resizeColumn,
    onEnter: (_) => setState(() => _isHovering = true),
    onExit: (_) => setState(() => _isHovering = false),
    child: GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _isDragging = true),
      onHorizontalDragEnd: (_) {
        setState(() => _isDragging = false);
        widget.onDragEnd();
      },
      onHorizontalDragUpdate: (details) =>
          widget.onDragUpdate(details.delta.dx),
      child: Container(
        width: 12,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 1,
            height: double.infinity,
            color: (_isHovering || _isDragging)
                ? AppColors.primary
                : context.appColors.border,
          ),
        ),
      ),
    ),
  );
}
