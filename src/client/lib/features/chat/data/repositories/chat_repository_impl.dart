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
    // Existing implementation (stub for now)
    throw UnimplementedError('getChatHistory not yet implemented');
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    // Existing implementation (stub for now)
    throw UnimplementedError('clearChatHistory not yet implemented');
  }

  /// Generate a UUID v4 for conversation_id (simple implementation).
  ///
  /// In production, use the `uuid` package for proper UUID generation.
  String _generateConversationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return '$timestamp-$random';
  }
}
