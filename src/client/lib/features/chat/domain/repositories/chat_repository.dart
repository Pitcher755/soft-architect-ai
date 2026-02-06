import '../entities/chat_message.dart';
import '../entities/document_proposal.dart';

/// Repository interface for chat operations.
abstract class ChatRepository {
  /// Generates document content using RAG + LLM with SSE streaming.
  ///
  /// Returns a stream of tokens that together form the complete document.
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  );

  /// Saves a document proposal to persistent storage.
  Future<void> saveProposal(DocumentProposal proposal);

  /// Retrieves chat history from storage.
  Future<List<ChatMessage>> getChatHistory(String projectId);

  /// Clears chat history for a project.
  Future<void> clearChatHistory(String projectId);
}
