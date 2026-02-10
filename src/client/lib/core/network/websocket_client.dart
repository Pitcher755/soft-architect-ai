import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket client wrapper for streaming tokens.
class WebSocketClient {
  WebSocketClient({required this.url});
  final String url;
  WebSocketChannel? _channel;
  StreamController<String>? _messageController;
  bool _isConnected = false;

  /// Whether the WebSocket is connected.
  bool get isConnected => _isConnected;

  /// Stream of token messages.
  Stream<String>? get stream => _messageController?.stream;

  /// Connect to WebSocket endpoint.
  Future<bool> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _messageController = StreamController<String>.broadcast();
      _isConnected = true;

      _channel!.stream.listen(
        _handleIncoming,
        onError: (Object error) {
          _messageController?.addError(error);
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
          _messageController?.close();
        },
      );

      return true;
    } on Exception catch (_) {
      _isConnected = false;
      return false;
    }
  }

  /// Send a message to the server.
  void send(String message) {
    _channel?.sink.add(message);
  }

  /// Send a JSON payload.
  void sendJson(Map<String, dynamic> payload) {
    send(jsonEncode(payload));
  }

  /// Disconnect from the WebSocket.
  Future<void> disconnect() async {
    _isConnected = false;
    await _channel?.sink.close();
    await _messageController?.close();
  }

  void _handleIncoming(dynamic event) {
    if (event is! String) {
      return;
    }

    final token = _extractToken(event);
    if (token != null) {
      _messageController?.add(token);
    }
  }

  String? _extractToken(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type'] as String?;
        if (type == 'token') {
          return decoded['content'] as String? ?? '';
        }
        if (type == 'ping') {
          sendJson({'type': 'pong'});
          return null;
        }
        return null;
      }
    } on FormatException catch (_) {
      return message;
    }
    return null;
  }
}
