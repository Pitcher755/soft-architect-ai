/// Base class for streaming events.
abstract class StreamEvent {
  const StreamEvent();

  /// Parse event from JSON payload.
  factory StreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'unknown';
    switch (type) {
      case 'token':
        return TokenEvent(
          content: json['content'] as String? ?? '',
          timestamp: json['timestamp'] as String? ?? '',
        );
      case 'ping':
        return const PingEvent();
      case 'pong':
        return const PongEvent();
      case 'done':
        return DoneEvent(
          totalTokens: json['total_tokens'] as int? ?? 0,
          latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 0.0,
        );
      case 'error':
        return ErrorEvent(
          code: json['code'] as String? ?? 'UNKNOWN',
          message: json['message'] as String? ?? 'Unknown error',
        );
      default:
        return UnknownEvent(rawType: type, payload: json);
    }
  }
}

/// Token event emitted by the server.
class TokenEvent extends StreamEvent {
  const TokenEvent({required this.content, required this.timestamp});
  final String content;
  final String timestamp;
}

/// Heartbeat ping event.
class PingEvent extends StreamEvent {
  const PingEvent();
}

/// Heartbeat pong event.
class PongEvent extends StreamEvent {
  const PongEvent();
}

/// Stream completion event.
class DoneEvent extends StreamEvent {
  const DoneEvent({required this.totalTokens, required this.latencyMs});
  final int totalTokens;
  final double latencyMs;
}

/// Error event from server.
class ErrorEvent extends StreamEvent {
  const ErrorEvent({required this.code, required this.message});
  final String code;
  final String message;
}

/// Unknown event type.
class UnknownEvent extends StreamEvent {
  const UnknownEvent({required this.rawType, required this.payload});
  final String rawType;
  final Map<String, dynamic> payload;
}
