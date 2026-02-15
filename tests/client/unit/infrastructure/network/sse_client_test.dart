/// Integration tests for SSE client (HU-4.3 Phase 3).
///
/// This module tests the Flutter SSE client for consuming Server-Sent Events
/// from the backend streaming endpoint. Tests validate SSE parsing, event
/// deserialization, error handling, and timeout behavior.
///
/// Test Coverage:
/// - Token event parsing and emission
/// - Done event parsing with metadata
/// - Error event handling
/// - Multiline data handling
/// - Comment line skipping
/// - HTTP error handling
/// - Timeout handling
/// - JSON deserialization
///
/// TDD Cycle: GREEN Phase (tests should pass now).

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:softarchitect_ai/infrastructure/network/sse_client.dart';
import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';

/// Fake HTTP client for testing (avoids Mockito type issues).
class FakeHttpClient extends http.BaseClient {
  final http.StreamedResponse Function() responseProvider;

  FakeHttpClient(this.responseProvider);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return responseProvider();
  }
}

void main() {
  group('SseClient', () {
    test('connect emits TokenEvent for each token', () async {
      // Arrange
      final sseResponse = '''
event: message
data: {"token":"Hello","is_final":false}

event: message
data: {"token":" world","is_final":false}

event: done
data: {"full_response":"Hello world","sources":[]}

''';

      final fakeClient = FakeHttpClient(() => http.StreamedResponse(
            Stream.value(utf8.encode(sseResponse)),
            200,
            headers: {'content-type': 'text/event-stream'},
          ));

      final sseClient = SseClient(client: fakeClient);

      // Act
      final events = await sseClient
          .connect('http://test/stream', {'message': 'test'})
          .toList();

      // Assert
      expect(events.length, 3); // 2 tokens + 1 done
      expect(events[0], isA<TokenEvent>());
      expect((events[0] as TokenEvent).token, 'Hello');
      expect(events[1], isA<TokenEvent>());
      expect((events[1] as TokenEvent).token, ' world');
      expect(events[2], isA<DoneEvent>());
    });

    test('connect handles multiline data correctly', () async {
      // Arrange
      final sseResponse = '''
event: message
data: {"token":"Line1\\n","is_final":false}

event: message
data: {"token":"Line2","is_final":false}

''';

      final fakeClient = FakeHttpClient(() => http.StreamedResponse(
            Stream.value(utf8.encode(sseResponse)),
            200,
          ));

      final sseClient = SseClient(client: fakeClient);

      // Act
      final events = await sseClient
          .connect('http://test/stream', {'message': 'test'})
          .toList();

      // Assert
      expect(events.length, 2);
      expect((events[0] as TokenEvent).token, 'Line1\n');
    });

    test('connect emits ErrorEvent on stream error', () async {
      // Arrange
      final sseResponse = '''
event: error
data: {"error":"Connection failed","code":"CONNECTION_ERROR","retry":true}

''';

      final fakeClient = FakeHttpClient(() => http.StreamedResponse(
            Stream.value(utf8.encode(sseResponse)),
            200,
          ));

      final sseClient = SseClient(client: fakeClient);

      // Act
      final events = await sseClient
          .connect('http://test/stream', {'message': 'test'})
          .toList();

      // Assert
      expect(events.length, 1);
      expect(events[0], isA<ErrorEvent>());
      expect((events[0] as ErrorEvent).error, 'Connection failed');
      expect((events[0] as ErrorEvent).shouldRetry, true);
    });

    test('connect handles HTTP error status', () async {
      // Arrange
      final fakeClient = FakeHttpClient(() => http.StreamedResponse(
            Stream.value(utf8.encode('Unauthorized')),
            401,
          ));

      final sseClient = SseClient(client: fakeClient);

      // Act & Assert
      expect(
        () => sseClient
            .connect('http://test/stream', {'message': 'test'})
            .toList(),
        throwsA(isA<SseException>()),
      );
    });

    test('connect handles timeout', () async {
      // Arrange
      final fakeClient = FakeHttpClient(() => throw Exception('Timeout'));

      final sseClient = SseClient(client: fakeClient);

      // Act & Assert
      expect(
        () => sseClient
            .connect('http://test/stream', {'message': 'test'})
            .toList(),
        throwsA(isA<SseException>()),
      );
    });

    test('connect skips comment lines (: prefix)', () async {
      // Arrange
      final sseResponse = '''
: heartbeat comment

event: message
data: {"token":"Test","is_final":false}

: another comment

''';

      final fakeClient = FakeHttpClient(() => http.StreamedResponse(
            Stream.value(utf8.encode(sseResponse)),
            200,
          ));

      final sseClient = SseClient(client: fakeClient);

      // Act
      final events = await sseClient
          .connect('http://test/stream', {'message': 'test'})
          .toList();

      // Assert
      expect(events.length, 1); // Only token event, comments skipped
    });

    test('connect parses JSON data correctly', () async {
      // Arrange
      final sseResponse = '''
event: done
data: {"full_response":"Complete","sources":["doc1.md","doc2.md"],"metadata":{"tokens":50}}

''';

      final fakeClient = FakeHttpClient(() => http.StreamedResponse(
            Stream.value(utf8.encode(sseResponse)),
            200,
          ));

      final sseClient = SseClient(client: fakeClient);

      // Act
      final events = await sseClient
          .connect('http://test/stream', {'message': 'test'})
          .toList();

      // Assert
      expect(events.length, 1);
      expect(events[0], isA<DoneEvent>());
      final doneEvent = events[0] as DoneEvent;
      expect(doneEvent.fullResponse, 'Complete');
      expect(doneEvent.sources, ['doc1.md', 'doc2.md']);
      expect(doneEvent.metadata['tokens'], 50);
    });
  });
}
