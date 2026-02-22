import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../domain/entities/chat_stream_event.dart';
import '../../../../infrastructure/network/sse_client.dart';
import '../../../../services/database_helper.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';

/// Implementation of [ChatRepository] using SSE for streaming
/// and SQLite for persistence.
///
/// This implementation connects to the backend API via
/// Server-Sent Events to stream AI-generated responses
/// token-by-token, and persists chat history to local
/// SQLite database for session recovery.
///
/// Example usage:
/// ```dart
/// final repository = ChatRepositoryImpl(
///   baseUrl: 'http://localhost:8000',
///   apiKey: 'your-api-key',
/// );
///
/// await for (final event in
///     repository.sendMessageStream(message, projectId)) {
///   // Handle streaming events
/// }
/// ```
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.baseUrl,
    required this.apiKey,
    SseClient? sseClient,
    Database? database,
  }) : sseClient = sseClient ?? SseClient(),
       _database = database;

  final String baseUrl;
  final String apiKey;
  final SseClient sseClient;
  Database? _database;

  /// Lazy initialization of database
  Future<Database> get database async {
    _database ??= await DatabaseHelper().database;
    return _database!;
  }

  /// **DEPRECATED:** Not implemented. Use [sendMessageStream] instead.
  ///
  /// This method throws [UnimplementedError]. For document generation,
  /// use [sendMessageStream] which provides SSE streaming functionality.
  @override
  @Deprecated('Not implemented. Use sendMessageStream() instead.')
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) {
    // Not implemented - use sendMessageStream instead
    throw UnimplementedError(
      'generateDocument not yet implemented. '
      'Use sendMessageStream() instead.',
    );
  }

  @override
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId,
  ) async* {
    final url = '$baseUrl/api/v1/chat/stream';

    var historyPayload = <Map<String, String>>[];
    try {
      final chatHistory = await getChatHistory(projectId);

      const maxHistoryMessages = 100;
      final limitedHistory = chatHistory.length > maxHistoryMessages
          ? chatHistory.sublist(chatHistory.length - maxHistoryMessages)
          : chatHistory;

      historyPayload = limitedHistory
          .where((msg) => msg.role.name != 'system')
          .map((msg) => {'role': msg.role.name, 'content': msg.content})
          .toList();
    } on Exception catch (_) {}

    final body = {
      'message': message,
      'project_id': projectId,
      'conversation_id': _generateConversationId(),
      'history': historyPayload,
      'user_name': 'Developer',
    };
    final headers = {'X-API-Key': apiKey};

    try {
      yield* sseClient.connect(url, body, headers: headers);
    } on SseException catch (e) {
      // Transform SSE exception into error event stream
      yield ErrorEvent(
        error: e.message,
        code: 'CONNECTION_ERROR',
        shouldRetry: e.statusCode != 401, // Don't retry auth errors
      );
    }
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    try {
      final db = await database;

      // Save proposal as special chat message with metadata
      final proposalMessage = ChatMessage(
        id: proposal.id,
        role: MessageRole.assistant,
        content: proposal.content,
        timestamp: proposal.createdAt.toIso8601String(),
        metadata: {
          'is_proposal': true,
          'doc_type': proposal.docType,
          'validation_state': proposal.validationState.name,
          ...proposal.metadata,
        },
      );

      await db.insert('chat_messages', {
        'id': proposalMessage.id,
        'project_id': 'proposal', // Special project ID for proposals
        'role': proposalMessage.role.name,
        'content': proposalMessage.content,
        'timestamp': proposalMessage.timestamp,
        'is_streaming': 0,
        'metadata': jsonEncode(proposalMessage.metadata ?? {}),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } on Exception catch (_) {
      // Log error but don't throw - proposal saving is not critical
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'chat_messages',
        where: 'project_id = ?',
        whereArgs: [projectId],
        orderBy: 'timestamp ASC',
      );

      final messages = maps.map((map) {
        final metadata = map['metadata'] as String?;
        return ChatMessage(
          id: map['id'] as String,
          role: MessageRole.values.firstWhere(
            (e) => e.name == map['role'],
            orElse: () => MessageRole.user,
          ),
          content: map['content'] as String,
          timestamp: map['timestamp'] as String,
          isStreaming: (map['is_streaming'] as int) == 1,
          metadata: metadata != null && metadata.isNotEmpty
              ? jsonDecode(metadata) as Map<String, dynamic>
              : null,
        );
      }).toList();
      return messages;
    } on Exception catch (_) {
      rethrow; // Re-throw to propagate error to UI
    }
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    try {
      final db = await database;
      await db.delete(
        'chat_messages',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
    } on Exception catch (_) {
      rethrow; // Re-throw to propagate error
    }
  }

  /// Save a single message to chat history.
  ///
  /// This method saves the message directly to SQLite.
  @override
  Future<void> saveMessage(String projectId, ChatMessage message) async {
    try {
      final db = await database;

      await db.insert('chat_messages', {
        'id': message.id,
        'project_id': projectId,
        'role': message.role.name,
        'content': message.content,
        'timestamp': message.timestamp,
        'is_streaming': message.isStreaming ? 1 : 0,
        'metadata': jsonEncode(message.metadata ?? {}),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow; // Re-throw to propagate error
    }
  }

  /// Generate a UUID v4 for conversation_id (RFC 4122 compliant).
  String _generateConversationId() => UuidGenerator.v4();
}
