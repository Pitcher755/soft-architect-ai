import '../../../../domain/entities/chat_stream_event.dart';
import '../entities/chat_message.dart';
import '../entities/document_proposal.dart';

/// Repository interface for chat operations.
abstract class ChatRepository {
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  );

  /// Send message and get streaming response.
  ///
  /// Parameters:
  /// - [message]: User's input message
  /// - [projectId]: Unique project identifier
  /// - [docType]: Current document type being generated (optional)
  /// - [userName]: User's name for personalization (optional)
  /// - [history]: Previous chat messages for context (optional)
  /// - [projectContext]: Complete project context (.md/.json files)
  ///   for AI injection (optional)
  ///
  /// The [projectContext] map contains file paths as keys and content
  /// as values, preventing LLM amnesia by providing full project
  /// context with every request.
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId, {
    String? docType,
    String? userName,
    List<ChatMessage>? history,
    Map<String, String>? projectContext,
  });

  Future<void> saveProposal(DocumentProposal proposal);
  Future<List<ChatMessage>> getChatHistory(String projectId);
  Future<void> saveMessage(String projectId, ChatMessage message);
  Future<void> clearChatHistory(String projectId);
}
