import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../domain/entities/chat_stream_event.dart';
import '../../../../infrastructure/network/sse_client.dart';
import '../../../../services/database_helper.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';

/// Implementation of [ChatRepository] using SSE for streaming and SQLite for persistence.
///
/// This implementation connects to the backend API via Server-Sent Events
/// to stream AI-generated responses token-by-token, and persists chat history
/// to local SQLite database for session recovery.
///
/// Example usage:
/// ```dart
/// final repository = ChatRepositoryImpl(
///   baseUrl: 'http://localhost:8000',
///   apiKey: 'your-api-key',
/// );
///
/// await for (final event in repository.sendMessageStream(message, projectId)) {
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
    // TODO: Implement proposal persistence
    // Note: Proposals are different from regular chat messages
    // They may need a separate table or different storage mechanism
    // For now, proposals are handled in-memory by ChatNotifier
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

      // ignore: avoid_print
      print('✅ Loaded ${messages.length} messages for project: $projectId');
      return messages;
    } on Exception catch (e) {
      // ignore: avoid_print
      print('🔥 ERROR SQL (getChatHistory): $e');
      rethrow; // Re-throw to propagate error to UI
    }
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    try {
      final db = await database;
      final deletedRows = await db.delete(
        'chat_messages',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      // ignore: avoid_print
      print('✅ Cleared $deletedRows messages for project: $projectId');
    } on Exception catch (e) {
      // ignore: avoid_print
      print('🔥 ERROR SQL (clearChatHistory): $e');
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

      // ignore: avoid_print
      print(
        '✅ Message saved: ${message.id} (${message.role.name}) for project: $projectId',
      );
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('🔥 ERROR SQL (saveMessage): $e');
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
      rethrow; // Re-throw to propagate error
    }
  }

  /// Generate a UUID v4 for conversation_id (RFC 4122 compliant).
  String _generateConversationId() => UuidGenerator.v4();
}
