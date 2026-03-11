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
  /// Se añade el parámetro opcional [history] para enviar el contexto filtrado.
  Stream<ChatStreamEvent> sendMessageStream(
    String message,
    String projectId, {
    String? docType,
    String? userName,
    List<ChatMessage>? history, // 🎯 Parámetro para evitar errores 422
  });

  Future<void> saveProposal(DocumentProposal proposal);
  Future<List<ChatMessage>> getChatHistory(String projectId);
  Future<void> saveMessage(String projectId, ChatMessage message);
  Future<void> clearChatHistory(String projectId);
}
