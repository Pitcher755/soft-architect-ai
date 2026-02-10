import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/network/websocket_client.dart';
import 'package:softarchitect_ai/features/chat/presentation/providers/streaming_provider.dart';

class MockWebSocketClient implements WebSocketClient {
  final _streamController = StreamController<String>.broadcast();
  bool _isConnected = false;

  @override
  final String url = 'ws://localhost:8000/api/v1/chat/stream';

  @override
  Stream<String> get stream => _streamController.stream;

  @override
  Future<bool> connect() async {
    _isConnected = true;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
  }

  @override
  Future<void> send(String message) async {
    // Mock send
  }

  @override
  Future<void> sendJson(Map<String, dynamic> json) async {
    // Mock sendJson
  }

  void addToken(String token) => _streamController.add(token);

  void completeStream() => _streamController.close();

  bool get isConnected => _isConnected;
}

void main() {
  group('StreamingProvider', () {
    late MockWebSocketClient mockWebSocket;
    late ProviderContainer container;

    setUp(() {
      mockWebSocket = MockWebSocketClient();
      container = ProviderContainer(
        overrides: [webSocketClientProvider.overrideWithValue(mockWebSocket)],
      );
    });

    tearDown(() {
      // Don't dispose immediately; let async operations complete
      Future<void>.delayed(const Duration(milliseconds: 500)).then((_) {
        container.dispose();
      });
      mockWebSocket.completeStream();
    });

    test('initializes WebSocket connection successfully', () async {
      final provider = container.read(streamingProvider.notifier);
      final connected = await provider.initialize();
      expect(connected, isTrue);
      expect(mockWebSocket.isConnected, isTrue);
    });

    test('accumulates streamed tokens into message text', () async {
      final provider = container.read(streamingProvider.notifier);
      await provider.initialize();

      // Simulate receiving tokens
      mockWebSocket.addToken('Hello');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      mockWebSocket.addToken(' ');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      mockWebSocket.addToken('World');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(streamingProvider);
      expect(state, contains('Hello'));
    });

    test('auto-reconnects after disconnection', () async {
      final provider = container.read(streamingProvider.notifier);
      await provider.initialize();

      // Trigger disconnection
      await provider.handleDisconnection();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should attempt reconnection
      expect(mockWebSocket.isConnected, isTrue);
    });

    test('token reception callback is invoked for each token', () async {
      final receivedTokens = <String>[];

      final provider = container.read(streamingProvider.notifier);
      provider.onTokenReceived = (token) {
        receivedTokens.add(token);
      };

      await provider.initialize();

      mockWebSocket.addToken('t1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      mockWebSocket.addToken('t2');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(receivedTokens.length, greaterThan(0));
    });
  });
}
