/// Mock SSE Server for Flutter Tests (HU-4.3)
///
/// This fixture simulates Server-Sent Events (SSE) responses for testing
/// the SSE client and chat streaming features without requiring a real server.
///
/// Example usage:
/// ```dart
/// final mockServer = MockSseServer();
/// await for (final event in mockServer.streamEvents()) {
///   print(event); // "event: message\ndata: {...}\n\n"
/// }
/// ```
library;

/// Mock SSE server that emits realistic SSE event streams for testing.
///
/// Simulates the W3C Server-Sent Events format with proper event types,
/// data payloads, and double-newline delimiters.
class MockSseServer {
  /// Duration between emitted events (simulates network latency).
  final Duration eventDelay;

  /// Whether to include heartbeat comments in the stream.
  final bool includeHeartbeats;

  /// Creates a mock SSE server with configurable timing.
  ///
  /// - [eventDelay]: Delay between events (default: 50ms).
  /// - [includeHeartbeats]: Whether to emit `: heartbeat` comments.
  MockSseServer({
    this.eventDelay = const Duration(milliseconds: 50),
    this.includeHeartbeats = false,
  });

  /// Streams a sequence of SSE events simulating AI token streaming.
  ///
  /// The stream emits:
  /// 1. Multiple `message` events with progressive tokens
  /// 2. A `done` event with full response and metadata
  ///
  /// Each event follows W3C SSE format:
  /// ```
  /// event: <type>\n
  /// data: <json>\n
  /// \n
  /// ```
  Stream<String> streamEvents() async* {
    // Heartbeat (if enabled)
    if (includeHeartbeats) {
      yield ': heartbeat\n\n';
      await Future.delayed(eventDelay);
    }

    // Token 1
    yield 'event: message\n'
        'data: {"token":"Hello","is_final":false}\n'
        '\n';
    await Future.delayed(eventDelay);

    // Token 2
    yield 'event: message\n'
        'data: {"token":" world","is_final":false}\n'
        '\n';
    await Future.delayed(eventDelay);

    // Token 3
    yield 'event: message\n'
        'data: {"token":"!","is_final":false}\n'
        '\n';
    await Future.delayed(eventDelay);

    // Done event with metadata
    yield 'event: done\n'
        'data: {"full_response":"Hello world!","sources":["mock_doc.md"],"metadata":{"model":"llama3","tokens":3}}\n'
        '\n';
  }

  /// Streams a sequence of SSE events simulating an error scenario.
  ///
  /// Emits a few tokens followed by an `error` event.
  Stream<String> streamEventsWithError() async* {
    // Token 1
    yield 'event: message\n'
        'data: {"token":"Starting","is_final":false}\n'
        '\n';
    await Future.delayed(eventDelay);

    // Error event
    yield 'event: error\n'
        'data: {"error":"Connection timeout","code":"TIMEOUT_ERROR","retry":true}\n'
        '\n';
  }

  /// Streams an empty response (only done event, no tokens).
  ///
  /// Useful for testing edge cases where AI returns no content.
  Stream<String> streamEmptyResponse() async* {
    yield 'event: done\n'
        'data: {"full_response":"","sources":[],"metadata":{"model":"llama3","tokens":0}}\n'
        '\n';
  }

  /// Streams a long response with many tokens.
  ///
  /// Useful for testing performance and UI auto-scroll behavior.
  Stream<String> streamLongResponse({int tokenCount = 20}) async* {
    for (var i = 0; i < tokenCount; i++) {
      yield 'event: message\n'
          'data: {"token":"Token$i ","is_final":false}\n'
          '\n';
      await Future.delayed(eventDelay);
    }

    // Build full response
    final fullResponse = List.generate(tokenCount, (i) => 'Token$i').join(' ');

    yield 'event: done\n'
        'data: {"full_response":"$fullResponse","sources":[],"metadata":{"model":"llama3","tokens":$tokenCount}}\n'
        '\n';
  }
}
