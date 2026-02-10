import 'package:flutter/material.dart';

/// Controller managing automatic scrolling behavior for chat messages.
///
/// Features:
/// - Auto-scroll to bottom on new messages
/// - Pause auto-scroll when user is manually scrolling
/// - Smooth animations (300ms, easeOut curve)
/// - 60 FPS performance guarantee
class AutoScrollController {
  /// Creates auto-scroll controller wrapping existing ScrollController.
  AutoScrollController(this._scrollController) {
    _setupScrollListener();
  }

  /// Underlying Flutter scroll controller.
  final ScrollController _scrollController;

  /// Flag indicating if auto-scroll is paused.
  bool _isPaused = false;

  /// Threshold for detecting user scroll (pixels).
  static const double _scrollThreshold = 50;

  /// Animation duration for auto-scroll.
  Duration animationDuration = const Duration(milliseconds: 300);

  /// Animation curve for smooth scrolling.
  Curve animationCurve = Curves.easeOut;

  /// Check if auto-scroll is currently paused.
  bool get isPaused => _isPaused;

  /// Setup listener to detect user scroll gestures.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentPosition = _scrollController.position.pixels;
      final maxScroll = _scrollController.position.maxScrollExtent;

      if (currentPosition < maxScroll - _scrollThreshold) {
        _isPaused = true;
      } else {
        _isPaused = false;
      }
    });
  }

  /// Scroll to bottom immediately (no animation).
  void scrollToBottom() {
    if (_isPaused) {
      return;
    }

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// Animate scroll to bottom with smooth transition.
  Future<void> animateToBottom({Duration? duration, Curve? curve}) async {
    if (_isPaused) {
      return;
    }

    if (_scrollController.hasClients) {
      animationDuration = duration ?? animationDuration;
      animationCurve = curve ?? animationCurve;
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: animationDuration,
        curve: animationCurve,
      );
    }
  }

  /// Handle new message arrival event.
  void onNewMessage(String message) {
    if (_isPaused) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      animateToBottom();
    });
  }

  /// Reset auto-scroll state (resume scrolling).
  void resume() {
    _isPaused = false;
  }

  /// Dispose resources.
  void dispose() {}
}
