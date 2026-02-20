import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../domain/entities/chat_stream_event.dart';

/// Exception thrown when SSE connection fails.
///
/// This exception wraps HTTP errors, timeouts, and connection failures
/// that occur during SSE streaming.
///
/// Example:
/// ```dart
/// try {
///   await for (final event in sseClient.connect(url, body)) {
///     // Handle events
///   }
/// } on SseException catch (e) {
///   print('SSE failed: ${e.message} (status: ${e.statusCode})');
/// }
/// ```
class SseException implements Exception {
  SseException(this.message, {this.statusCode});

  /// Human-readable error message.
  final String message;

  /// HTTP status code (null for non-HTTP errors like timeouts).
  final int? statusCode;

  @override
  String toString() => 'SseException: $message (status: $statusCode)';
}

/// Client for consuming Server-Sent Events (SSE) from backend.
///
/// This client implements the W3C Server-Sent Events specification for
/// consuming real-time event streams from HTTP endpoints.
///
/// Features:
/// - Automatic event parsing (event: + data: format)
/// - JSON deserialization to [ChatStreamEvent] hierarchy
/// - Comment line filtering (: prefix)
/// - Timeout handling
/// - HTTP error handling
///
/// Example:
/// ```dart
/// final sseClient = SseClient();
/// try {
///   await for (final event in sseClient.connect(url, body)) {
///     if (event is TokenEvent) {
///       print('Token: ${event.token}');
///     } else if (event is DoneEvent) {
///       print('Complete: ${event.fullResponse}');
///     }
///   }
/// } finally {
///   sseClient.close();
/// }
/// ```
class SseClient {
  SseClient({http.Client? client, this.timeout = const Duration(seconds: 30)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  /// Connect to SSE endpoint and stream events.
  ///
  /// Opens an HTTP POST connection to the specified URL with the given body
  /// and streams [ChatStreamEvent] objects as they are received.
  ///
  /// Parameters:
  /// - [url]: SSE endpoint URL
  ///   (e.g., "http://localhost:8000/api/v1/chat/stream")
  /// - [body]: Request body (JSON encoded automatically)
  /// - [headers]: Optional additional headers
  ///   (Content-Type and Accept are set automatically)
  ///
  /// Returns a stream of [ChatStreamEvent]
  /// (TokenEvent, DoneEvent, ErrorEvent).
  ///
  /// Throws [SseException] if:
  /// - Connection fails or times out
  /// - HTTP status code is not 200
  /// - Network error occurs
  ///
  /// Example:
  /// ```dart
  /// final events = sseClient.connect(
  ///   'http://localhost:8000/api/v1/chat/stream',
  ///   {'message': 'Why is the sky blue?', 'project_id': 'uuid'},
  ///   headers: {'X-API-Key': 'your-api-key'},
  /// );
  ///
  /// await for (final event in events) {
  ///   if (event is TokenEvent) {
  ///     // Append token to UI
  ///   } else if (event is DoneEvent) {
  ///     // Show complete message
  ///   } else if (event is ErrorEvent) {
  ///     // Handle error
  ///   }
  /// }
  /// ```
  Stream<ChatStreamEvent> connect(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async* {
    // Prepare request
    final request = http.Request('POST', Uri.parse(url))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        ...?headers,
      })
      ..body = jsonEncode(body);

    // Send request and get streamed response
    http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(timeout);
    } on TimeoutException catch (e) {
      throw SseException('Request timeout after ${timeout.inSeconds}s: $e');
    } catch (e) {
      throw SseException('Connection failed: $e');
    }

    // Check status code
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw SseException(
        'HTTP ${response.statusCode}: $body',
        statusCode: response.statusCode,
      );
    }

    // Parse SSE stream
    final buffer = StringBuffer();
    String? currentEvent;

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      buffer.write(chunk);

      // Process complete lines (terminated by \n)
      while (buffer.toString().contains('\n')) {
        final bufferStr = buffer.toString();
        final lineEnd = bufferStr.indexOf('\n');
        final line = bufferStr.substring(0, lineEnd).trim();
        buffer
          ..clear()
          ..write(bufferStr.substring(lineEnd + 1));

        // Skip empty lines (event separator)
        if (line.isEmpty) {
          currentEvent = null;
          continue;
        }

        // Skip comments (lines starting with :)
        if (line.startsWith(':')) {
          continue;
        }

        // Parse event: line
        if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
          continue;
        }

        // Parse data: line
        if (line.startsWith('data:')) {
          final dataStr = line.substring(5).trim();

          try {
            final data = jsonDecode(dataStr) as Map<String, dynamic>;
            final event = _parseEvent(currentEvent ?? 'message', data);
            if (event != null) {
              yield event;
            }
          } on FormatException catch (e) {
            // Log JSON parse error but continue streaming
            developer.log(
              'Warning: Failed to parse SSE data: $dataStr',
              name: 'SSEClient',
              error: e,
            );
          }
        }
      }
    }
  }

  /// Parse SSE event data into ChatStreamEvent.
  ///
  /// Converts raw JSON data into typed event objects based on event type.
  ///
  /// Supported event types:
  /// - `message`: Token events
  /// - `done`: Done events
  /// - `error`: Error events
  ///
  /// Unknown event types are logged and ignored.
  ChatStreamEvent? _parseEvent(String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'message':
        return TokenEvent.fromJson(data);
      case 'done':
        return DoneEvent.fromJson(data);
      case 'error':
        return ErrorEvent.fromJson(data);
      default:
        developer.log(
          'Warning: Unknown SSE event type: $eventType',
          name: 'SSEClient',
        );
        return null;
    }
  }

  /// Close HTTP client and release resources.
  ///
  /// Should be called when the SSE client is no longer needed to prevent
  /// resource leaks.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await for (final event in sseClient.connect(url, body)) {
  ///     // Handle events
  ///   }
  /// } finally {
  ///   sseClient.close();
  /// }
  /// ```
  void close() {
    _client.close();
  }
}
