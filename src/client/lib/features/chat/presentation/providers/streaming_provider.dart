import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/error_handling/error_mapper.dart';
import '../../../../core/network/websocket_client.dart';

/// Provider for WebSocket client instance.
final webSocketClientProvider = Provider<WebSocketClient>(
  (ref) => WebSocketClient(url: 'ws://localhost:8000/api/v1/chat/stream'),
);

/// Provider for streaming chat messages with real-time token delivery.
final streamingProvider = StateNotifierProvider<StreamingNotifier, String>((
  ref,
) {
  final webSocketClient = ref.watch(webSocketClientProvider);
  return StreamingNotifier(webSocketClient);
});

/// Notifier managing streaming state and WebSocket connection.
class StreamingNotifier extends StateNotifier<String> {
  StreamingNotifier(this._webSocket) : super('');

  /// WebSocket client for real-time communication.
  final WebSocketClient _webSocket;

  /// Callback invoked when new token is received.
  void Function(String)? onTokenReceived;

  /// Flag indicating if reconnection is in progress.
  bool _isReconnecting = false;

  /// Accumulated message text from streamed tokens.
  String _accumulatedText = '';

  /// Initialize WebSocket connection.
  Future<bool> initialize() async {
    try {
      final connected = await _webSocket.connect();
      if (connected) {
        _setupMessageListener();
      }
      return connected;
    } on Exception catch (_) {
      state = ErrorMapper.getUserMessage('WS_CONNECTION_FAILED');
      return false;
    }
  }

  /// Start streaming tokens for given query.
  Future<void> startStreaming(String query) async {
    _accumulatedText = '';
    state = '';

    try {
      final payload = jsonEncode({
        'type': 'query',
        'content': query,
        'session_id': 'local-session',
      });
      _webSocket.send(payload);
    } on Exception catch (_) {
      state = ErrorMapper.getUserMessage('WS_STREAM_FAILED');
    }
  }

  /// Handle WebSocket disconnection event with exponential backoff.
  Future<void> handleDisconnection() async {
    if (_isReconnecting) {
      return;
    }

    _isReconnecting = true;
    state = 'Reconectando...';

    const baseDelayMs = 200;
    for (var attempt = 1; attempt <= 3; attempt++) {
      final delay = Duration(milliseconds: baseDelayMs * (1 << (attempt - 1)));
      await Future.delayed(delay);

      final reconnected = await _webSocket.connect();
      if (reconnected) {
        _isReconnecting = false;
        state = 'Reconectado ✅';
        _setupMessageListener();
        return;
      }
    }

    _isReconnecting = false;
    state = ErrorMapper.getUserMessage('WS_RECONNECTION_FAILED');
  }

  void _setupMessageListener() {
    _webSocket.stream?.listen(
      (token) {
        _accumulatedText += token;
        state = _accumulatedText;
        onTokenReceived?.call(token);
      },
      onError: (_) {
        state = ErrorMapper.getUserMessage('WS_STREAM_ERROR');
      },
      onDone: handleDisconnection,
    );
  }

  @override
  void dispose() {
    _webSocket.disconnect();
    super.dispose();
  }
}
