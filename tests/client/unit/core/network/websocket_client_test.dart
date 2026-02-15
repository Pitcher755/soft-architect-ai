import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/network/websocket_client.dart';

void main() {
  group('WebSocketClient', () {
    test('initial state is disconnected and stream is null', () {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      expect(client.isConnected, isFalse);
      expect(client.stream, isNull);
    });

    test('connect returns false for malformed URL', () async {
      final client = WebSocketClient(url: '://not-a-valid-url');

      final result = await client.connect();

      expect(result, isFalse);
      expect(client.isConnected, isFalse);
    });

    test('send and sendJson are no-op when not connected', () {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      expect(() => client.send('ping'), returnsNormally);
      expect(
        () =>
            client.sendJson(<String, dynamic>{'type': 'token', 'content': 'x'}),
        returnsNormally,
      );
    });

    test('disconnect can be called safely when not connected', () async {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      await client.disconnect();

      expect(client.isConnected, isFalse);
    });

    test('testExtractToken returns token content for token payload', () {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      final token = client.testExtractToken('{"type":"token","content":"abc"}');

      expect(token, 'abc');
    });

    test(
      'testExtractToken returns empty string when token content missing',
      () {
        final client = WebSocketClient(url: 'ws://localhost:9999/ws');

        final token = client.testExtractToken('{"type":"token"}');

        expect(token, '');
      },
    );

    test('testExtractToken handles ping and unknown message types', () {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      expect(client.testExtractToken('{"type":"ping"}'), isNull);
      expect(client.testExtractToken('{"type":"other"}'), isNull);
      expect(client.testExtractToken('{"x":1}'), isNull);
    });

    test('testExtractToken returns raw message when input is not JSON', () {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      expect(client.testExtractToken('plain-token'), 'plain-token');
    });

    test('testHandleIncoming ignores non-string events safely', () {
      final client = WebSocketClient(url: 'ws://localhost:9999/ws');

      expect(() => client.testHandleIncoming(123), returnsNormally);
      expect(
        () => client.testHandleIncoming({'type': 'token'}),
        returnsNormally,
      );
    });
  });
}
