import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../domain/entities/chat_stream_event.dart';
import '../../../../infrastructure/network/sse_client.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';

/// Implementation of [ChatRepository] using SSE for real-time streaming.
///
/// This implementation connects to the backend API via Server-Sent Events
/// to stream AI-generated responses token-by-token.
///
/// Example usage:
/// ```dart
/// final repository = ChatRepositoryImpl(
///   baseUrl: 'http://localhost:8000',
///   apiKey: 'your-api-key',
/// );
///
/// await for (final event in repository.sendMessageStream(message, projectId)) {///   // Handle streaming events
/// }
/// ```
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.baseUrl,
    required this.apiKey,
    SseClient? sseClient,
  }) : sseClient = sseClient ?? SseClient();
  final String baseUrl;
  final String apiKey;
  final SseClient sseClient;

  @override
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) {
    // Existing implementation (stub for now)
    throw UnimplementedError('generateDocument not yet implemented');
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(String message, String projectId) {
    final url = '$baseUrl/api/v1/chat/stream';
    final body = {
      'message': message,
      'project_id': projectId,
      'conversation_id': _generateConversationId(), // Generate UUID
    };
    final headers = {'X-API-Key': apiKey};

    try {
      return sseClient.connect(url, body, headers: headers);
    } on SseException catch (e) {
      // Transform SSE exception into error event stream
      return Stream.value(
        ErrorEvent(
          error: e.message,
          code: 'CONNECTION_ERROR',
          shouldRetry: e.statusCode != 401, // Don't retry auth errors
        ),
      );
    }
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    // Existing implementation (stub for now)
    throw UnimplementedError('saveProposal not yet implemented');
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getChatHistoryKey(projectId);
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Exception {
      // Return empty list on error to avoid app crash
      return [];
    }
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getChatHistoryKey(projectId);
      await prefs.remove(key);
    } on Exception {
      // Silently fail, user can retry
    }
  }

  /// Save a single message to chat history.
  ///
  /// This method loads existing history, appends the new message,
  /// and saves back to SharedPreferences.
  @override
  Future<void> saveMessage(String projectId, ChatMessage message) async {
    try {
      final history = await getChatHistory(projectId);
      history.add(message);

      final prefs = await SharedPreferences.getInstance();
      final key = _getChatHistoryKey(projectId);
      final jsonList = history.map((msg) => msg.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(key, jsonString);
    } on Exception {
      // Silently fail, history won't persist but app continues
    }
  }

  /// Generate SharedPreferences key for project-specific chat history.
  String _getChatHistoryKey(String projectId) => 'chat_history_$projectId';

  /// Generate a UUID v4 for conversation_id (RFC 4122 compliant).
  String _generateConversationId() => UuidGenerator.v4();
}
